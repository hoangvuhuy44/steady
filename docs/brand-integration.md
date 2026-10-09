# Steady brand integration

This change applies the supplied **Steady-Brand-Identity.zip** to the existing
Flutter application. The implementation specification is
`Steady_Codex_Brand_Integration_Master_Prompt.md`; exact text tokens and original
artwork take precedence over sampled reference colors. The archive was inspected
and extracted with path traversal checks to ignored `build/brand-source/`.

## Audit and scope

- App entry/navigation: `lib/app/steady_app.dart`, Material 3, five destinations,
  bounded 880px content, existing VI/EN localization delegates.
- Old theme: generated green color scheme, green-tinted backgrounds, 20px cards,
  16px controls, system fonts. No custom font or brand asset declarations.
- Screens: Home, Check-in, guest recipe catalogue/detail, Rewards, Profile,
  email/social authentication, five-step health screening. Personalized meals
  remain an explicitly gated research surface, as in the original repository.
- Dependencies were retained; PNG rendering uses Flutter's built-in image
  support. No SVG dependency, backend migration, or business logic rewrite.
- Store, auth controllers, repositories, calculations, screening rules, filtering,
  reward thresholds, locale switching, navigation callbacks, and existing
  automated-test keys are preserved.

## Source artwork

| Source in ZIP | Repository destination / use |
| --- | --- |
| `01-Symbol/steady-symbol-{gradient,blue,white}.png` | `assets/brand/logo/`; approved symbol variants and source of platform icons |
| `03-Logo-Lockups/steady-horizontal-{ink,white}-outlined.png` | `assets/brand/logo/`; Home/auth header and light/dark logo variants |
| `06-Key-Visuals/background-light-minimal.png` | `assets/brand/visuals/`; decorative Home/auth header |
| `06-Key-Visuals/background-gradient-wave.png` | `assets/brand/visuals/`; supplied alternative background |
| `08-Supporting-Elements/{waves,circular-motion}.png` | `assets/brand/visuals/`; supplied supporting graphics |
| `08-Supporting-Elements/icon-{activity,progress,wellness,consistency}.png` | `assets/brand/icons/`; localized section headers |
| `09-Typography/fonts/{sora,inter}-variable.ttf` | `assets/fonts/`; unchanged source files |
| `09-Typography/fonts/{sora,inter}-OFL.txt` | `assets/licenses/`; SIL OFL licenses bundled in the app |
| `05-Colors/design-tokens.json` | `docs/brand/design-tokens.json`; original token reference, outside build assets |

The lockup is the outlined portable original, including its existing whitespace.
No logo, wordmark, or symbol was redrawn or recolored. Intrinsic aspect ratios are
reserved before image decoding to prevent layout jumps. Horizontal artwork has a
1040:300 aspect ratio and symbol artwork 1160:1360. Padding preserves clear space.
Reference boards, editable live-text SVGs, and the archive itself are not bundled.

`tool/generate_brand_icons.ps1` derives Android density bitmaps, a padded adaptive
foreground, opaque iOS AppIcon sizes, and web/maskable icons from the original PNG.
It preserves aspect ratio and gradient order. Adaptive artwork stays inside the
66dp safe zone of its 108dp canvas. No IDs, package names, signing settings, or
native navigation configuration change. The existing desktop launcher assets are
outside this mobile/web icon pass.

## Design system

| Token | Value / mapping |
| --- | --- |
| Fresh Mint | `#63E68D`, selected chip/navigation accent |
| Aqua Teal | `#20D0BE`, decorative accent/progress |
| Flow Cyan | `#1FB5F3`, decorative accent/progress |
| Momentum Blue | `#1976F8`, progress gradient |
| Deep Core Blue | `#0D4FC8`, primary action/link/focus |
| Soft Cloud | `#F5F7FA`, scaffold/input surfaces |
| Ink / Muted | `#101E32` / `#52647C`, readable text |
| White / Border | `#FFFFFF` / `#DFE7EF`, cards/tracks/dividers |
| Semantic error | `#B3261E`, paired with existing messages; pale surface `#FCEAE8` |
| Spacing | 4, 8, 12, 16, 24, 32, 48, 64px |
| Radii | 24px cards, 12px controls, 999px pills |
| Motion | 220ms ease-out, zero for reduced motion/accessibility navigation |

Use typed `SteadyColors`, `SteadySpacing`, `SteadyRadii`, `SteadyGradients`,
`SteadyMotion`, and `SteadyTypography` from `lib/theme/`. `SteadyTheme.light()`
remains the compatible entry point. Its explicit `ColorScheme` avoids seed
generation changing the official colors. All Material component themes share
the same palette, surfaces, input focus/error borders, and padded touch targets.
Buttons are at least 48px high and can grow with text. Interactive control outlines
use Muted rather than the low-contrast decorative Border token.

Reading text uses Ink/Muted; Deep Core Blue CTAs use White. Mint, Teal, and Cyan
carry Ink when used as a text surface. Color is paired with labels/icons for
completion, errors, and locked rewards. Progress gradients are decorative;
numeric/text/semantic information communicates their value independently.

## Typography and Vietnamese

Sora 600–700 is used for display, headings and titles; Inter 400 for body, 500 for
labels, 600 for actions. Mobile heading sizes are 24–36px; body sizes 16–18px;
captions 12–14px. Font declarations map the actual bundled variable files to the
weights used by the app, without downloads at runtime.

**Source limitation:** supplied Sora has 108 of the 156 printable characters used
in the VI/EN catalogs. It lacks 48 characters, including Vietnamese tone/horn
characters and the arrow. The supplied Inter covers all 156. Sora headings declare
`fontFamilyFallback: ['Inter']` so unsupported glyphs use the other official font,
instead of a device-dependent fallback or missing-glyph boxes. This means some
Vietnamese headings combine Sora and Inter glyphs. Full Sora-only Vietnamese
typography would require a revised brand font source from the brand owner.
`python tool/verify_brand_fonts.py` checks TTF cmap coverage and variable axes.

The English slogan remains `Movement. Consistency. Progress.`; its localized VI
display is `Vận động. Bền bỉ. Tiến bộ.`. Both live in the existing ARB flow.

## Reusable components and screen mapping

- `SteadyBrandLogo`: approved asset variant, image semantics, fixed aspect ratio.
- `SteadyBrandHeader`: light-minimal artwork, original lockup, localized slogan;
  used by Home and Sign-in/Sign-up.
- `SteadySectionHeader`: Sora heading, localized supporting text and decorative
  original icon; used by Check-in, Recipes, Rewards, Profile, and Screening.
- `SteadyProgressRing`: real active days / `ActivityMetrics.targetDays`, shared
  by Home and Profile via the existing `ActivityGoal` widget.
- `SteadyProgressBar`: real points / existing reward threshold, screening step / 5,
  and existing research meal-budget calculation. Values clamp visually to 0–1;
  underlying data and calculations are unchanged. Empty progress retains its track.
- Existing `MetricCard`, `ConsistencyWeek`, nutrition/result cards, and Material
  buttons consume the centralized tokens/theme. Week indicators wrap on narrow
  screens at large text sizes and preserve localized status semantics.

Short authentication, Check-in, and screening forms use `SingleChildScrollView`
with a stretching column to keep inputs/actions mounted as users scroll or open
the keyboard. The research page includes extra bottom space so a floating SnackBar
does not cover its final action. Main navigation retains its five destinations,
ordering, callbacks, and labels.

For a new screen, use the existing localized catalog, a bounded safe-area layout,
`SteadySpacing.screen`, themed cards/buttons/fields, and a section header. Do not
invent additional primary colors, recreate the logo with text, or put White text
on Mint/Teal. Feed progress real derived state and provide a localized semantic
label. Avoid animation when `SteadyMotion.durationOf(context)` returns zero.

## Verification and visual evidence

- `flutter pub get`, `flutter gen-l10n`, and `dart format` are run for the changes.
- `flutter analyze` and the full `flutter test` suite check the existing flows.
- `test/brand_identity_widget_test.dart` adds AA contrast checks, reduced-motion
  progress semantics, and real-font layout/keyboard checks across VI/EN, 320/390px
  phones and 1024px layouts, including 200% text.
- `test/helpers/brand_fonts.dart` loads the shipped fonts instead of test Ahem.
- `flutter test tool/brand_visual_review_test.dart --no-pub` captures seven screens
  in each locale under `docs/screenshots/brand/`, using decoded original artwork.
  These are widget-rendered snapshots with deterministic test fixtures, not live
  account screenshots. There are no fabricated before screenshots.
- `flutter build web --no-pub` verifies the feasible production target.
- The pre-existing immutable-test-double analyzer warning is repaired by keeping
  its fault switches in a final mutable fixture map; test assertions are retained.

Final verification on 2026-10-10 (Flutter 3.47.5 / Dart 3.13.4, Windows):

| Check | Result |
| --- | --- |
| `flutter pub get`, `flutter gen-l10n` | Passed; dependencies unchanged |
| `dart format` | Passed |
| `flutter analyze --no-pub` | Passed, no issues |
| `flutter test --no-pub` | Passed, 137 tests, 1 pre-existing browser-only skip |
| Real-font responsive/contrast/motion checks | Passed in full suite |
| `flutter test tool/brand_visual_review_test.dart --no-pub` | Passed; 14 rendered snapshots |
| `flutter build web --no-pub` | Passed; JS build and Wasm dry run succeeded |
| Font cmap and source-file SHA-256 verification | Passed; Inter covers VI/EN; all 17 bundled source files byte-identical to ZIP |
| Legacy colors / `ColorScheme.fromSeed` search in `lib/` | No matches |
| `git diff --check` | Passed |

Native
iOS signing/device builds are unavailable on this Windows host. Android adaptive
icons and iOS bitmap sizes are generated and inspected, but launcher behavior
still needs device review. OAuth provider callbacks and real account/backend
connections are covered by existing controller/widget regressions, not a new
live login or database mutation.
