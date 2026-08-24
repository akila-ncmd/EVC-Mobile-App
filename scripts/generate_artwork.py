#!/usr/bin/env python3
"""Generate EVC's placeholder artwork.

The original mockups were illustrated with copyrighted film posters, album
covers and photographs of real people. Those cannot ship, so every image in
`assets/images/` is generated here instead: original abstract compositions,
deterministic from the filename, owned outright by this repository.

Nothing is downloaded and nothing is traced from an existing work. Each image
is a mesh gradient in the EVC burgundy palette with one geometric motif drawn
over it, so posters stay distinguishable at 80px in a rail and still hold up
as a full-width hero.

    python scripts/generate_artwork.py [--out assets/images]

Re-running reproduces the same 30 files byte for byte.
"""

from __future__ import annotations

import argparse
import hashlib
import math
import os
import random

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

# Drawing happens at this multiple of the target size and is scaled back down,
# which is the cheapest anti-aliasing available in pure PIL.
SUPERSAMPLE = 2


# --------------------------------------------------------------------------
# Palette
# --------------------------------------------------------------------------

# Every family starts from the EVC burgundy and moves one direction in hue, so
# the catalogue reads as a set rather than a random assortment. `deep` anchors
# the shadows, `mid` carries the gradient, `lift` is the highlight a motif is
# drawn in.
FAMILIES = {
    "burgundy": dict(deep=(0x3A, 0x04, 0x11), mid=(0x79, 0x05, 0x20), lift=(0xE8, 0xBF, 0xC7)),
    "rose": dict(deep=(0x4A, 0x06, 0x22), mid=(0xC9, 0x40, 0x60), lift=(0xF6, 0xD8, 0xDE)),
    "ember": dict(deep=(0x3F, 0x0D, 0x08), mid=(0xC0, 0x5A, 0x2A), lift=(0xF5, 0xD2, 0xA6)),
    "plum": dict(deep=(0x2E, 0x08, 0x30), mid=(0x76, 0x2C, 0x8A), lift=(0xE2, 0xC8, 0xF0)),
    "indigo": dict(deep=(0x14, 0x0C, 0x38), mid=(0x3C, 0x35, 0x8C), lift=(0xC8, 0xCC, 0xF2)),
    "teal": dict(deep=(0x04, 0x24, 0x2A), mid=(0x1E, 0x6E, 0x74), lift=(0xBF, 0xE8, 0xE4)),
    "gold": dict(deep=(0x3A, 0x24, 0x04), mid=(0xB0, 0x82, 0x1E), lift=(0xF4, 0xE4, 0xB4)),
    "slate": dict(deep=(0x14, 0x16, 0x1E), mid=(0x45, 0x4C, 0x60), lift=(0xD6, 0xDC, 0xE8)),
}

FAMILY_NAMES = sorted(FAMILIES)


def seeded(name: str) -> random.Random:
    """A generator keyed to the filename, so output never shifts between runs."""
    digest = hashlib.sha256(name.encode("utf-8")).hexdigest()
    return random.Random(int(digest[:16], 16))


def pick_family(rng: random.Random, bias: str | None = None) -> dict:
    if bias is not None:
        return FAMILIES[bias]
    return FAMILIES[rng.choice(FAMILY_NAMES)]


def mix(a: tuple, b: tuple, t: float) -> tuple:
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def ramp(family: dict, t: float) -> tuple:
    """Sample the family as a three-stop ramp: deep → mid → lift.

    Going through `mid` rather than straight from deep to lift is what keeps
    the hue intact — a direct blend desaturates through the middle and lands
    on the muddy brown that made the first pass unusable.
    """
    t = min(1.0, max(0.0, t))
    if t < 0.5:
        return mix(family["deep"], family["mid"], t * 2)
    return mix(family["mid"], family["lift"], (t - 0.5) * 2)


# --------------------------------------------------------------------------
# Grounds
# --------------------------------------------------------------------------


def mesh(size: tuple[int, int], family: dict, rng: random.Random, cells: int = 4) -> Image.Image:
    """A smooth multi-point gradient.

    A tiny grid of ramp samples upscaled with bicubic interpolation gives the
    mesh-gradient look without needing a real mesh solver. Tone is biased
    bright at one edge and dark at the other so every image has a built-in
    light direction; pure noise reads as fog.
    """
    top_light = rng.random() < 0.7
    # Hold the ground in the deep→mid half of the ramp and let the motif own
    # the highlights. Running it to the top of the ramp washed the burgundy
    # families out to pale pink, which left the featured hero the weakest
    # image in the set.
    lo, hi = rng.uniform(0.10, 0.24), rng.uniform(0.55, 0.82)
    small = Image.new("RGB", (cells, cells))
    for x in range(cells):
        for y in range(cells):
            v = y / max(1, cells - 1)
            if top_light:
                v = 1 - v
            t = lo + (hi - lo) * v + rng.uniform(-0.18, 0.18)
            small.putpixel((x, y), ramp(family, t))
    return small.resize(size, Image.BICUBIC)


def radial_mask(size: tuple[int, int], center: tuple[float, float], radius: float) -> Image.Image:
    """White at `center` fading to black at `radius`, in fractions of width."""
    w, h = size
    small = Image.new("L", (64, 64), 0)
    d = ImageDraw.Draw(small)
    cx, cy = center[0] * 64, center[1] * 64
    steps = 28
    for i in range(steps, 0, -1):
        r = radius * 64 * i / steps
        v = round(255 * (1 - i / steps) ** 1.4)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=v)
    return small.resize(size, Image.BICUBIC)


def glow(img: Image.Image, family: dict, rng: random.Random) -> Image.Image:
    """A soft off-center light source, which is what stops these reading flat."""
    center = (rng.uniform(0.25, 0.75), rng.uniform(0.2, 0.6))
    mask = radial_mask(img.size, center, rng.uniform(0.45, 0.8))
    tint = Image.new("RGB", img.size, mix(family["mid"], family["lift"], rng.uniform(0.3, 0.6)))
    return Image.composite(tint, img, mask.point(lambda v: round(v * 0.55)))


def vignette(img: Image.Image, strength: float = 0.25) -> Image.Image:
    """Darken the corners.

    `Image.composite(dark, img, mask)` takes `dark` where the mask is white, so
    the mask has to be near-black at the centre and rise toward the edges —
    the inverse of what `radial_mask` returns.
    """
    mask = radial_mask(img.size, (0.5, 0.5), 0.95).point(
        lambda v: round((255 - v) * strength))
    dark = Image.new("RGB", img.size, (0, 0, 0))
    return Image.composite(dark, img, mask)


def grain(img: Image.Image, sigma: float = 5.0, alpha: float = 0.04) -> Image.Image:
    """Light film grain, enough to stop the gradients banding.

    Deliberately faint: noise is close to incompressible, and at 0.10 it more
    than doubled the weight of the asset folder for a texture nobody sees."""
    noise = Image.effect_noise(img.size, sigma).convert("RGB")
    return Image.blend(img, Image.blend(img, noise, 0.5), alpha)


def ink(family: dict, rng: random.Random) -> tuple:
    """The color a motif is drawn in.

    Either the near-white highlight or the near-black shadow — the two ends of
    the family. Anything in between disappears against the ground at thumbnail
    size, which is the only size most of these are ever seen at.
    """
    return family["lift"] if rng.random() < 0.62 else family["deep"]


def finish(img: Image.Image) -> Image.Image:
    """Final grade.

    Mesh gradients come out of bicubic interpolation flat and slightly washed;
    a modest contrast and saturation push is what makes them read as artwork
    rather than as a blurred background.
    """
    img = ImageEnhance.Color(img).enhance(1.06)
    return ImageEnhance.Contrast(img).enhance(1.10)


def layer(base: Image.Image, draw_fn) -> Image.Image:
    """Composite one translucent shape group over `base`."""
    overlay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw_fn(ImageDraw.Draw(overlay))
    return Image.alpha_composite(base.convert("RGBA"), overlay).convert("RGB")


# --------------------------------------------------------------------------
# Motifs
#
# Each takes the ground and returns it with one geometric idea drawn over.
# They are deliberately simple: at rail-thumbnail size only the silhouette
# survives, so the silhouette has to carry the difference between titles.
# --------------------------------------------------------------------------


def motif_rings(img, family, rng):
    # Concentric outlines never overlap each other, so one overlay is enough.
    w, h = img.size
    cx, cy = w * rng.uniform(0.3, 0.7), h * rng.uniform(0.3, 0.7)
    color = ink(family, rng)
    specs = []
    for i in range(rng.randint(5, 9)):
        specs.append((w * (0.10 + i * rng.uniform(0.07, 0.10)),
                      max(2, round(w * rng.uniform(0.004, 0.014))),
                      rng.randint(95, 205)))

    def paint(d):
        for r, width, a in specs:
            d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=color + (a,), width=width)

    return layer(img, paint)


def motif_waveform(img, family, rng):
    w, h = img.size
    bars = rng.randint(14, 26)
    gap = w / bars
    bw = gap * rng.uniform(0.35, 0.55)
    phase = rng.uniform(0, math.pi * 2)
    freq = rng.uniform(2, 4)
    color = ink(family, rng)
    specs = []
    for i in range(bars):
        t = i / bars
        amp = 0.12 + (math.sin(phase + t * math.pi * freq) * 0.5 + 0.5) * 0.62
        bh = h * amp
        x = i * gap + (gap - bw) / 2
        specs.append((x, h * 0.88 - bh, h * 0.88, rng.randint(130, 235)))

    def paint(d):
        for x, y0, y1, a in specs:
            d.rounded_rectangle([x, y0, x + bw, y1], radius=bw / 2, fill=color + (a,))

    return layer(img, paint)


def motif_arcs(img, family, rng):
    w, h = img.size
    color = ink(family, rng)
    # Anchor the sweep just off one edge so it always crosses the frame.
    cx = w * rng.choice([-0.15, 1.15])
    cy = h * rng.uniform(0.1, 0.9)
    for i in range(rng.randint(3, 5)):
        r = w * (0.55 + i * rng.uniform(0.12, 0.20))
        # Aim the sweep back across the canvas. PIL measures from 3 o'clock
        # clockwise, so a centre off the left edge wants angles around 0 and
        # one off the right edge wants angles around 180; a random start
        # leaves the arc facing into empty space about half the time.
        start = (0 if cx < 0 else 180) + rng.uniform(-70, 10)
        extent = rng.uniform(70, 140)
        width = max(4, round(w * rng.uniform(0.018, 0.055)))
        a = rng.randint(120, 215)
        img = layer(img, lambda d, r=r, cx=cx, cy=cy, start=start, extent=extent, width=width, a=a: d.arc(
            [cx - r, cy - r, cx + r, cy + r], start, start + extent, fill=color + (a,), width=width))
    return img


def motif_stripes(img, family, rng):
    w, h = img.size
    color = ink(family, rng)
    angle = rng.choice([-1, 1])
    count = rng.randint(6, 12)
    for i in range(count):
        t = (i + rng.uniform(-0.2, 0.2)) / count
        x = w * (t * 1.6 - 0.3)
        bw = w * rng.uniform(0.02, 0.07)
        a = rng.randint(80, 165)
        pts = [(x, -h * 0.1), (x + bw, -h * 0.1),
               (x + bw + angle * w * 0.5, h * 1.1), (x + angle * w * 0.5, h * 1.1)]
        img = layer(img, lambda d, pts=pts, a=a: d.polygon(pts, fill=color + (a,)))
    return img


def motif_sunburst(img, family, rng):
    w, h = img.size
    cx, cy = w * rng.uniform(0.35, 0.65), h * rng.uniform(0.55, 0.85)
    rays = rng.randint(10, 18)
    color = ink(family, rng)
    span = math.pi * 2 / rays
    for i in range(rays):
        a0 = i * span + rng.uniform(-0.05, 0.05)
        a1 = a0 + span * rng.uniform(0.3, 0.6)
        far = w * 1.6
        pts = [(cx, cy),
               (cx + math.cos(a0) * far, cy + math.sin(a0) * far),
               (cx + math.cos(a1) * far, cy + math.sin(a1) * far)]
        alpha = rng.randint(55, 125)
        img = layer(img, lambda d, pts=pts, alpha=alpha: d.polygon(pts, fill=color + (alpha,)))
    return img


def motif_orbs(img, family, rng):
    w, h = img.size
    for _ in range(rng.randint(5, 10)):
        r = w * rng.uniform(0.08, 0.34)
        cx, cy = w * rng.uniform(0, 1), h * rng.uniform(0, 1)
        color = mix(family["mid"], family["lift"], rng.uniform(0.1, 0.9))
        a = rng.randint(70, 150)
        img = layer(img, lambda d, r=r, cx=cx, cy=cy, color=color, a=a: d.ellipse(
            [cx - r, cy - r, cx + r, cy + r], fill=color + (a,)))
    return img


def motif_frames(img, family, rng):
    w, h = img.size
    color = ink(family, rng)
    inset = w * rng.uniform(0.06, 0.12)
    step = w * rng.uniform(0.06, 0.10)
    # Stop before the insets cross the centre — on the wide canvases the short
    # axis runs out first, which is what an unclamped loop trips over.
    limit = min(w, h) * 0.45
    specs = []
    for i in range(rng.randint(3, 6)):
        o = inset + i * step
        if o >= limit:
            break
        specs.append((o, max(2, round(w * rng.uniform(0.004, 0.012))), rng.randint(95, 195)))

    def paint(d):
        for o, width, a in specs:
            d.rounded_rectangle([o, o, w - o, h - o], radius=w * 0.04,
                                outline=color + (a,), width=width)

    return layer(img, paint)


def motif_peaks(img, family, rng):
    w, h = img.size
    layers = rng.randint(3, 5)
    for i in range(layers):
        t = i / max(1, layers - 1)
        base_y = h * (0.55 + t * 0.4)
        color = mix(family["deep"], family["mid"], 0.10 + t * 0.85)
        pts = [(-w * 0.1, h * 1.1)]
        x = -w * 0.1
        while x < w * 1.1:
            step = w * rng.uniform(0.18, 0.42)
            pts.append((x + step / 2, base_y - h * rng.uniform(0.05, 0.28)))
            x += step
        pts.append((w * 1.1, h * 1.1))
        a = rng.randint(165, 240)
        img = layer(img, lambda d, pts=pts, color=color, a=a: d.polygon(pts, fill=color + (a,)))
    return img


def motif_dots(img, family, rng):
    w, h = img.size
    cols = rng.randint(7, 12)
    gap = w / cols
    color = ink(family, rng)
    fx, fy = rng.uniform(0.2, 0.8), rng.uniform(0.2, 0.8)
    specs = []
    for ix in range(cols):
        for iy in range(round(h / gap)):
            cx, cy = (ix + 0.5) * gap, (iy + 0.5) * gap
            dist = math.hypot(cx / w - fx, cy / h - fy)
            r = gap * 0.44 * max(0.0, 1 - dist * 1.5)
            if r < 0.8:
                continue
            specs.append((cx, cy, r, round(95 + 160 * max(0.0, 1 - dist * 1.6))))

    def paint(d):
        for cx, cy, r, a in specs:
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color + (a,))

    return layer(img, paint)


def motif_prism(img, family, rng):
    w, h = img.size
    for _ in range(rng.randint(3, 6)):
        color = mix(family["mid"], family["lift"], rng.uniform(0.2, 1.0))
        x0 = w * rng.uniform(-0.2, 0.9)
        bw = w * rng.uniform(0.10, 0.30)
        skew = w * rng.uniform(-0.5, 0.5)
        a = rng.randint(70, 150)
        pts = [(x0, -h * 0.1), (x0 + bw, -h * 0.1),
               (x0 + bw + skew, h * 1.1), (x0 + skew, h * 1.1)]
        img = layer(img, lambda d, pts=pts, color=color, a=a: d.polygon(pts, fill=color + (a,)))
    return img


MOTIFS = {
    "rings": motif_rings,
    "waveform": motif_waveform,
    "arcs": motif_arcs,
    "stripes": motif_stripes,
    "sunburst": motif_sunburst,
    "orbs": motif_orbs,
    "frames": motif_frames,
    "peaks": motif_peaks,
    "dots": motif_dots,
    "prism": motif_prism,
}


# --------------------------------------------------------------------------
# Compositions
# --------------------------------------------------------------------------


def poster(name, size, family, motif):
    rng = seeded(name)
    big = (size[0] * SUPERSAMPLE, size[1] * SUPERSAMPLE)
    fam = FAMILIES[family]

    img = mesh(big, fam, rng, cells=rng.randint(3, 5))
    img = glow(img, fam, rng)
    img = MOTIFS[motif](img, fam, rng)
    img = vignette(img, rng.uniform(0.12, 0.26))
    img = img.resize(size, Image.LANCZOS)
    return finish(grain(img))


def avatar(name, family, motif, size=280):
    """Abstract profile art.

    Displayed inside a circle, so the composition is centred and the motif is
    kept away from the corners that get clipped. Softer and lower-contrast
    than a poster — an avatar sits directly beside a name and must not
    out-shout it.
    """
    rng = seeded(name)
    big = (size * SUPERSAMPLE, size * SUPERSAMPLE)
    fam = FAMILIES[family]

    img = mesh(big, fam, rng, cells=3)
    img = glow(img, fam, rng)
    img = MOTIFS[motif](img, fam, rng)
    img = img.filter(ImageFilter.GaussianBlur(big[0] * 0.004))
    img = vignette(img, 0.18)
    return finish(grain(img.resize((size, size), Image.LANCZOS)))


def backdrop(name, size, family):
    """Full-bleed background. Sits under a heavy gradient scrim, so it stays
    soft and low-contrast rather than competing with the copy on top."""
    rng = seeded(name)
    big = (size[0] * SUPERSAMPLE, size[1] * SUPERSAMPLE)
    fam = FAMILIES[family]

    img = mesh(big, fam, rng, cells=4)
    img = glow(img, fam, rng)
    img = motif_orbs(img, fam, rng)
    img = img.filter(ImageFilter.GaussianBlur(big[0] * 0.012))
    img = vignette(img, 0.3)
    return grain(img.resize(size, Image.LANCZOS))


def illustration(name, size, family, motifs):
    """Onboarding art.

    These are laid out with `BoxFit.contain`, so the image's own edges show.
    Rounding the corners against transparency keeps that looking intentional
    instead of like a photo that failed to fill its box.
    """
    rng = seeded(name)
    big = (size[0] * SUPERSAMPLE, size[1] * SUPERSAMPLE)
    fam = FAMILIES[family]

    img = mesh(big, fam, rng, cells=4)
    img = glow(img, fam, rng)
    for motif in motifs:
        img = MOTIFS[motif](img, fam, rng)
    img = vignette(img, 0.16)
    img = finish(grain(img.resize(size, Image.LANCZOS)))

    mask = Image.new("L", big, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, big[0] - 1, big[1] - 1],
                                          radius=big[0] * 0.06, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask.resize(size, Image.LANCZOS))
    return out


# --------------------------------------------------------------------------
# Art direction
# --------------------------------------------------------------------------

# Family and motif are assigned per image rather than drawn at random.
#
# Random selection was tried first and clumped badly — eight of thirty images
# came out as the same diagonal-stripe idea, and the palette wandered so far
# from the burgundy that the set stopped looking like EVC. Assigning them here
# guarantees all ten motifs appear, keeps `burgundy`/`rose`/`plum`/`ember`
# dominant with the cooler families as occasional accents, and lets titles
# that share a rail be given contrasting hues on purpose.
MANIFEST = [
    # Catalogue posters. Grouped by the rail they appear in, so neighbours
    # differ in both hue and silhouette.
    #                                     family      motif
    ("art_titanic.png", poster, (640, 640), "teal", "rings"),
    ("art_badguy.png", poster, (640, 640), "plum", "waveform"),
    ("art_prionbreak.png", poster, (1000, 668), "burgundy", "stripes"),
    ("art_rings7.png", poster, (640, 640), "gold", "rings"),
    ("art_enchanted.png", poster, (640, 640), "rose", "orbs"),
    ("art_goku.png", poster, (640, 640), "ember", "sunburst"),
    ("art_loki.png", poster, (640, 640), "plum", "arcs"),
    ("art_avengers.png", poster, (640, 640), "burgundy", "frames"),
    ("art_blackadam.png", poster, (640, 640), "indigo", "dots"),
    ("art_ringspower.png", poster, (1000, 668), "ember", "peaks"),
    ("art_quatal.png", poster, (640, 640), "rose", "prism"),
    ("art_breakingbad.png", poster, (640, 640), "gold", "stripes"),
    ("art_loner.png", poster, (640, 640), "burgundy", "peaks"),
    ("art_cyclops.png", poster, (640, 640), "indigo", "arcs"),
    ("art_eminem.png", poster, (640, 640), "burgundy", "waveform"),
    ("pl_relaxing.png", poster, (640, 640), "teal", "dots"),
    # Profile art.
    ("avatar_namal.png", avatar, None, "burgundy", "rings"),
    ("p_maxmartin.png", avatar, None, "plum", "arcs"),
    ("p_charlieputh.png", avatar, None, "rose", "orbs"),
    ("p_lehahalton.png", avatar, None, "indigo", "rings"),
    ("p_louisbell.png", avatar, None, "ember", "arcs"),
    ("p_ladygaga.png", avatar, None, "teal", "orbs"),
    ("p_noland.png", avatar, None, "burgundy", "rings"),
    # Full-bleed and promo surfaces.
    ("interest_bg.png", backdrop, (1000, 668), "burgundy", None),
    ("studio_promo.png", poster, (1000, 566), "plum", "stripes"),
    # Onboarding slides and role tiles. Two motifs each, since these are shown
    # large and a single one leaves them looking empty.
    ("onboard_listen.png", illustration, (720, 1036), "rose", ("sunburst", "waveform")),
    ("onboard_watch.png", illustration, (800, 712), "indigo", ("dots", "prism")),
    ("onboard_create.png", illustration, (720, 1036), "ember", ("frames", "peaks")),
    ("role_user.png", poster, (400, 584), "rose", "rings"),
    ("role_producer.png", poster, (400, 584), "indigo", "waveform"),
]


def build(entry):
    filename, fn, size, family, motif = entry
    if fn is avatar:
        return avatar(filename, family, motif)
    if fn is backdrop:
        return backdrop(filename, size, family)
    if fn is illustration:
        return illustration(filename, size, family, motif)
    return poster(filename, size, family, motif)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", default=os.path.join("assets", "images"))
    args = parser.parse_args()

    os.makedirs(args.out, exist_ok=True)
    total = 0
    for entry in MANIFEST:
        filename = entry[0]
        img = build(entry)
        path = os.path.join(args.out, filename)
        img.save(path, "PNG", optimize=True)
        size = os.path.getsize(path)
        total += size
        print(f"{filename:24s} {img.size[0]:5d}x{img.size[1]:<5d} {size // 1024:5d} KB")
    print(f"\n{len(MANIFEST)} images, {total / 1_048_576:.1f} MB")


if __name__ == "__main__":
    main()
