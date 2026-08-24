#!/usr/bin/env python3
"""Rebuild the README images from the golden renders.

`docs/screens/*.png` and `docs/banner.png` are downscales of the goldens in
`test/goldens/`, so they go stale the moment the UI changes. Regenerating them
by hand was how they ended up still showing the old copyrighted placeholder
artwork after it had been replaced everywhere else.

    flutter test --update-goldens
    python scripts/generate_docs_images.py
"""

from __future__ import annotations

import os

from PIL import Image, ImageDraw

GOLDENS = os.path.join("test", "goldens")
SCREENS_OUT = os.path.join("docs", "screens")
BANNER_OUT = os.path.join("docs", "banner.png")

# Width of a screenshot in the README tables. The goldens render at 750x1624,
# which is far larger than GitHub displays them.
SCREEN_WIDTH = 320

# docs/screens/<name>.png  ←  test/goldens/<golden>.png
SCREENS = {
    "splash": "01_splash",
    "onboarding": "02_onboarding",
    "signin": "04_signin",
    "interests": "06_interests",
    "design_system": "08_gallery",
    "home": "09_home",
    "discovery": "10_discovery",
    "detail": "11_about",
    "player": "12_player",
    "library": "13_library",
    "music": "15_music",
    "settings": "17_settings",
    "creator_hub": "18_creator_hub",
    "analytics": "23_analytics",
    "my_videos": "24_my_videos",
    "people": "26_people",
}

# The five screens across the top of the README, in order. The middle card is
# the studio's Monitor tab rather than the Analytics screen — its pie chart
# carries the banner, where Analytics repeats the list already in card two.
BANNER_SCREENS = ["09_home", "13_library", "21_studio_monitor", "25_balance", "26_people"]
BANNER_SIZE = (862, 399)
BANNER_BG = (68, 7, 2)  # AppColors.deep
BANNER_CARD_WIDTH = 152
BANNER_GAP = 10
BANNER_RADIUS = 10


def load(golden: str) -> Image.Image:
    return Image.open(os.path.join(GOLDENS, f"{golden}.png")).convert("RGB")


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.width - 1, img.height - 1],
                                          radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def build_screens() -> None:
    os.makedirs(SCREENS_OUT, exist_ok=True)
    for name, golden in SCREENS.items():
        img = load(golden)
        height = round(SCREEN_WIDTH * img.height / img.width)
        img = img.resize((SCREEN_WIDTH, height), Image.LANCZOS)
        path = os.path.join(SCREENS_OUT, f"{name}.png")
        img.save(path, "PNG", optimize=True)
        print(f"{path:32s} {img.size[0]}x{img.size[1]}")


def build_banner() -> None:
    banner = Image.new("RGB", BANNER_SIZE, BANNER_BG)
    cards = []
    for golden in BANNER_SCREENS:
        img = load(golden)
        height = round(BANNER_CARD_WIDTH * img.height / img.width)
        cards.append(rounded(img.resize((BANNER_CARD_WIDTH, height), Image.LANCZOS),
                             BANNER_RADIUS))

    total = len(cards) * BANNER_CARD_WIDTH + (len(cards) - 1) * BANNER_GAP
    x = (BANNER_SIZE[0] - total) // 2
    for card in cards:
        y = (BANNER_SIZE[1] - card.height) // 2
        banner.paste(card, (x, y), card)
        x += BANNER_CARD_WIDTH + BANNER_GAP

    banner.save(BANNER_OUT, "PNG", optimize=True)
    print(f"{BANNER_OUT:32s} {banner.size[0]}x{banner.size[1]}")


if __name__ == "__main__":
    build_screens()
    build_banner()
