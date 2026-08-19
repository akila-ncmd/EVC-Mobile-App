# EVC — Music & Video Streaming App

A Flutter implementation of the EVC mobile app: a two-sided music and video
platform where listeners stream, own, rent and gift titles, and creators
publish and monetise their own work.

Built from a set of 39 iPhone screen designs.

## Highlights

- **26 screens**, both the consumer and creator sides
- **Design system first** — 20 shared components driven by a single token file
- **Real playback** — `just_audio` for music, `video_player` for video
- **53 tests** — golden images for all 26 screens, behaviour coverage of
  ownership, search, publishing, following and session state, plus an
  accessibility audit against Flutter's WCAG guidelines
- **Repository pattern** over mock data — swap in a real API without touching UI

## Running

```bash
flutter pub get
flutter run
```

Web build:

```bash
flutter build web --release
```

## Tests

```bash
flutter test
```

`behaviour_test.dart` covers the state layer; `screens_golden_test.dart` renders
every screen offscreen and diffs it against a reference image;
`accessibility_test.dart` enforces tap-target size, text contrast and screen
reader labels across ten screens.

Goldens live in `test/goldens/` and double as a visual record of every screen.
Refresh them after intentional UI changes:

```bash
flutter test --update-goldens
```

## Architecture

```
lib/
├─ core/
│  ├─ theme/     tokens: colors, typography, spacing, radii, shadows
│  ├─ router/    go_router route table
│  └─ widgets/   shared component library (+ /gallery reference screen)
├─ features/
│  ├─ onboarding/  splash, carousel, role picker, interests
│  ├─ auth/        sign in, sign up
│  ├─ discovery/   home, search, detail, player
│  ├─ library/     owned / rented / gifted
│  ├─ music/       playlists, now playing, playback controller
│  ├─ creator/     studio, publish, analytics, balance
│  ├─ people/      artists, producers, directors
│  └─ settings/
└─ data/
   ├─ models/    domain types
   ├─ mock/      stand-in catalogue
   ├─ repository.dart
   └─ session.dart
```

**State**: Riverpod. **Navigation**: go_router. **Charts**: fl_chart.

The component gallery is at route `/gallery` — every shared widget in its real
states, useful for review and for spotting visual drift.

## Design decisions

Three deviations from the source mockups, made deliberately:

1. **Contrast** — faded list titles in the designs fell below WCAG AA. Replaced
   with `#C9A9AE` at 5.27:1, preserving the intent while staying legible.
2. **Row heights** — the original screens clipped a third meta line. Rows are
   now content-sized.
3. **Touch targets** — several controls sat under 44pt and were raised to meet
   the 48dp Android minimum.

All three are enforced by `accessibility_test.dart` rather than left as prose.

## Placeholder content and licensing

> **Not for distribution.** This is a portfolio prototype. The artwork,
> titles, and photographs shown are placeholders taken from the original
> design mockups. They are **copyrighted by their respective owners**, are
> used here only to demonstrate layout, and are **not licensed for
> redistribution or commercial use**. No affiliation with or endorsement by
> any rights holder is implied or claimed.

Artwork, titles and people in this build are placeholders for demonstration
only. Swap `EvcArtwork`'s sources and
`MockData` before any public release. Demo audio is royalty-free
(SoundHelix); demo video is Big Buck Bunny (Blender Foundation, CC-BY).

## Status

Prototype. No backend, no payments — mock data behind a repository interface.
