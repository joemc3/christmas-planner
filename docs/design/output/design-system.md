# Design system: Evergreen & Brass

For Flutter 3.47, Material 3. One `ColorScheme` per theme, built with `ColorScheme.fromSeed(seedColor: Color(0xFF1E4D3B), brightness: …)` and then every role below set explicitly with `.copyWith(...)` so the result does not drift between Flutter versions.

## Colour roles

| Role | Light | Dark | Used for |
|---|---|---|---|
| primary | `#1E4D3B` | `#94D2B2` | Primary buttons, bars, Purchased |
| onPrimary | `#FFFFFF` | `#00382A` | Text and icons on primary |
| primaryContainer | `#CFE5D8` | `#1F4D3B` | Nav indicator, monograms, quiet date card |
| onPrimaryContainer | `#0B2A1F` | `#C9EEDA` | Text on primaryContainer |
| secondary | `#52635A` | `#B8CCC0` | Secondary icons |
| onSecondary | `#FFFFFF` | `#23352C` | |
| secondaryContainer | `#D7E5DC` | `#33463C` | Tonal buttons, To Buy step, selected segment |
| onSecondaryContainer | `#102019` | `#D4E8DC` | |
| tertiary | `#8A6414` | `#E6C47C` | Brass: Ordered, planned-over warning |
| onTertiary | `#FFFFFF` | `#3F2E00` | |
| tertiaryContainer | `#F5E4BC` | `#5B4407` | Ordered step |
| onTertiaryContainer | `#3B2A00` | `#FDE3A8` | |
| error | `#A3263A` | `#FFB1B8` | Cranberry: over budget, order now, delete |
| onError | `#FFFFFF` | `#67001B` | |
| errorContainer | `#FADCDF` | `#8A1D32` | To-order tags, late step |
| onErrorContainer | `#5C0E1C` | `#FFDADC` | |
| surface | `#FBFAF7` | `#0F1512` | Screen ground |
| surfaceContainerLow | `#F5F3EE` | `#151C18` | Sheets, rail |
| surfaceContainer | `#EFECE6` | `#19211D` | Navigation bar |
| surfaceContainerHigh | `#E8E5DE` | `#212A25` | Dialogs, selected list row |
| surfaceContainerHighest | `#E1DED6` | `#2A342F` | Bar track, skeletons |
| onSurface | `#1B1F1C` | `#E4E9E4` | Body text |
| onSurfaceVariant | `#4A524D` | `#B4BEB7` | Secondary text, icons |
| outline | `#78807A` | `#87918A` | Field and stepper borders |
| outlineVariant | `#D4D6CF` | `#38433D` | Dividers |
| inverseSurface | `#2E3330` | `#E1E4DF` | Snackbar |
| onInverseSurface | `#EFF1EC` | `#2C322E` | Snackbar text |
| inversePrimary | `#94D2B2` | `#1E4D3B` | Snackbar action |

Text field fill: `#FFFFFF` light, `surface` dark.

## Seasonal extension

`ThemeExtension<SeasonColors>` for the things Material does not name.

| Token | Light | Dark | Used for |
|---|---|---|---|
| heroSurface | `#1E4D3B` | `#1F4D3B` | Ordering-date card (primary / primaryContainer) |
| onHero | `#F4F1E8` | `#F1EEE4` | Text on the date card |
| heroMuted | `#BFD6C9` | `#B5CDBF` | Secondary text on the date card |
| alertSurface | `#8E1F33` | `#8A1D32` | Date card on or after the date |
| onAlert | `#FFF4F4` | `#FFF1F2` | Text on the alert card |
| alertMuted | `#F6CDD3` | `#F3C6CC` | Secondary text on the alert card |
| ribbon | `#C9A14C` | `#B8924A` | Ribbon bands (decorative, never text) |
| ribbonEdge | `#A68337` | `#8C6C2E` | 2 px ribbon edges |

## Contrast checks

Text on its background is at least 4.5:1 in both themes (for example tertiary `#8A6414` on surface ≈ 5.1:1, error `#A3263A` on surface ≈ 6.9:1). Bar fill against its track is at least 5:1 in both themes, above the 3:1 requirement. Status is never colour alone: each state also changes icon, fill extent and label.

## Type

Google Fonts, at most one display face and one text face.

| Style | Face | Size / line | Weight | Use |
|---|---|---|---|---|
| displaySmall | Newsreader | 32/40 (44/52 laptop) | 500 | Ordering date |
| headlineMedium | Newsreader | 28/36 (32/40 laptop) | 500 | Screen titles |
| headlineSmall | Newsreader | 24/32 | 500 | Section heads, sheet and dialog titles |
| titleLarge | Newsreader | 22/28 | 500 | Meal names |
| moneyLarge (extension) | Public Sans | 40/48, −0.02em, tnum | 600 | Remaining on detail headers (36/44 on Home) |
| titleMedium | Public Sans | 16/24 | 600 | Row names |
| bodyLarge | Public Sans | 16/24 | 400 | Body, inputs |
| bodyMedium | Public Sans | 14/20 | 400 | Row meta, money lines (tnum) |
| labelLarge | Public Sans | 15/20 | 600 | Buttons |
| labelMedium | Public Sans | 12/16 | 700 | Tags, nav labels |

Every amount uses `FontFeature.tabularFigures()`.

## Space, shape, depth, motion

- Spacing scale 4, 8, 12, 16, 24, 32, 48. Gutter 16 on phone, 32–40 on laptop.
- List rows: minimum 72 tall, 12/16 padding, 1 px `outlineVariant` dividers, no cards.
- Radius: 12 fields and tags; 22 row steppers; 24 hero card; 28 sheets and dialogs; full pill for buttons.
- Touch: 44 minimum on every control; buttons 48 on phone, 44 on laptop.
- Depth: flat. Only the FAB, sheets, dialogs and snackbar lift.
- Motion: 200 ms standard easing for state changes; budget bars ease to their new width over 300 ms. Nothing else animates.
- Focus on laptop: 3 px `primary` outline, 3 px offset.

## The ribbon and the mark

Ordering-date card: `Stack` with two `Positioned` brass bands, vertical 12 px wide at 36 px from the right edge and horizontal 12 px tall at 24 px from the top, each with 2 px `ribbonEdge` edges. Content padding 56 top, 72 right, 24 left and bottom (64 / 120 / 32 on laptop, with 14 px bands). One ribboned object per screen.

The mark: a rounded square (22% radius) in `heroSurface` with a vertical band at 58–70% across and a horizontal band at 34–46% down. Used for the app icon, favicon, rail and sign-in.

## Components

| Component | Notes |
|---|---|
| Button | Primary (filled), secondary (outlined), tonal, danger (filled error), text |
| Input | Label above the field, 52 tall, 12 radius. Money has a currency prefix; whole number has −/+ icon buttons; password has a reveal button; error state is a 2 px error outline plus a message |
| Money triple | Large: "Left to spend", moneyLarge, 8 px bar, spent and budget beneath. Compact: "$21.00 left of $150.00" with a 6 px bar. Over: "$12.00 over", error bar at 100%, an "Over budget" tag |
| Status stepper, row | Bordered pill of 44 × 44 cells: tag (To Buy), truck (Ordered), check (Purchased); two cells for menu items. Reached cells fill with the state's container colour; tap a later cell to move forward |
| Status stepper, form | `SegmentedButton` with icon and label per state, reached segments filled |
| Recipient row | Monogram, name with optional tags, thin bar, remaining of budget, purchased of planned |
| Gift row | Name; price and store; status line ("Ordered 2 Oct", "To Buy · order by 26 Nov", "Order now"); row stepper |
| Meal row | Meal name in titleLarge, date and guests, bar, remaining, bought; or "No budget set yet" with Set budget |
| Menu item row | Name; cost and status; two-cell stepper |
| Ordering-date banner | Before (ribboned evergreen), on or after with gifts to order (ribboned cranberry with up to three gift links), all ordered (quiet primaryContainer) |
| Needs-ordering marker | "Order now" in error with a schedule icon, and an errorContainer first cell on the stepper; "n to order" tag on recipient rows |
| Sheet / dialog | Phone: bottom sheet with drag handle on surfaceContainerLow. Laptop: 480–520 px dialog on surfaceContainerHigh |
| Confirm | Title as a question, one line naming what goes, Cancel and one danger action |
| Empty state | Tree glyph in tertiary, the verbatim sentence, one primary button, placed where the first row would be |
| Loading / error | Skeleton rows shaped like real rows; error block with cloud-off icon, one line, Try again |
| Tab bar / rail | `NavigationBar` (Home, Gifts, Meals) on surfaceContainer; `NavigationRail` on laptop with the mark on top; indicator primaryContainer |
| Year switcher | Small text button with a history icon at the bottom of Home; read-only years show a "Read only" tag and a "Back to 2027" action |
| Theme toggle | Three-segment control: System, Light, Dark |
| Snackbar | Inverse surface, one line, Undo action |

Icons (Material Symbols Rounded): `home`, `featured_seasonal_and_gifts`, `restaurant`, `settings`, `sell`, `local_shipping`, `check`, `schedule`, `warning`, `park`, `person_add`, `add`, `edit`, `delete`, `storefront`, `open_in_new`, `edit_calendar`, `calendar_month`, `group`, `history`, `lock`, `cloud_off`, `refresh`, `visibility`, `mark_email_read`, `logout`.
