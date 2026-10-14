# Design decisions

Reconciliation of `output/` (Evergreen & Brass, 2026-10-14) against `../PRD.md` and `../superpowers/specs/2026-10-14-prd-restructure-design.md`. One row per screen or component. Verdicts: **adopt**, **adopt with change**, **reject**, **defer**. Checked first: every **verbatim** sentence from the brief is present exactly; gift states are three and item states two; meals are the fixed two; nothing from PRD section 8 appears.

## Screens

| Date | Screen or component | Verdict | What changes and why |
|---|---|---|---|
| 2026-10-14 | A1 Sign in | adopt | Mark, one line, form, reset and create links. Route `/login`. |
| 2026-10-14 | A2 Create account | adopt | Name, email, password twice, "At least 8 characters." Lands on empty Home. Route `/register`. |
| 2026-10-14 | A3 Reset: ask, sent, new password | adopt with change | Three states as drawn. The "new password" state needs its own route for the email link: `/reset`, opened by Supabase's recovery link. Added to the spec. |
| 2026-10-14 | B1 Home, first open | adopt | Budget of 0 reads as "No gift budget yet" with Set budget; meals with 0 budgets read "No meal budgets yet". Rule added to the spec: 0 means unset. |
| 2026-10-14 | B1 Home, before the date | adopt | Ribboned evergreen card with the verbatim date and "Gifts arrive by 10 December with n shipping days." Gift and meal money sections, remaining large, budget figure opens the edit sheet. |
| 2026-10-14 | B1 Home, on or after the date | adopt with change | Cranberry card with the verbatim count and up to three gift links, "and n more" to Gifts beyond three. The drawn frame omits the Meals section; it stays on the screen (HOME-1), below Gifts, exactly as in the other frames. |
| 2026-10-14 | B1 Home, everything ordered | adopt | Quiet primaryContainer card, "Every gift is ordered." with the date it was. |
| 2026-10-14 | B1 Home, gifts over budget | adopt | "Over budget" tag, "$n over" as the large number, bar at full error. |
| 2026-10-14 | B1 Home, next year and read-only last year | adopt | History text button at the bottom; read-only year shows a lock tag, "Read only", a one-line summary, "Back to {year}". No ribbon in read-only. |
| 2026-10-14 | B2 Gifts list | adopt | Monogram, name, remaining first, thin bar, purchased of planned; over-budget row words and tag; after the date, "n to order" tags and the summary line naming people. Verbatim empty state in place. |
| 2026-10-14 | B3 Recipient | adopt | Large money triple; brass "Planned $x, $y more than the budget" line only when planned exceeds budget; over state on the header when spent exceeds it; row stepper; "Order now" marker. Delete confirm names the person and the gift count. |
| 2026-10-14 | B3 Edit person sheet | adopt | Name, budget, "Spent so far". Same sheet adds a person. |
| 2026-10-14 | B4 Gift screen | adopt | "For {name} · $x left of $y", price large, store as a link, labelled three-step control, stamped dates with edit. Delete behind one confirm: "It comes off {name}'s list, and the totals update." |
| 2026-10-14 | B4 Gift form | adopt | One sheet for add and edit. Add shows "{name} has $x left. This leaves $y." where y = remaining minus price. Edit shows the dates once set. |
| 2026-10-14 | B5 Meals | adopt | Two rows with date, guests, remaining of budget, bought of planned. Guest count 0 reads "Guests not set"; budget 0 reads "No budget set yet" with Set budget. Showing the meal's calendar date is derived from the type and year, not stored. |
| 2026-10-14 | B6 Meal | adopt | Header with guests and money triple; flat menu; two-cell stepper. Guests and budget edited together in one sheet with "Planned so far". |
| 2026-10-14 | B7 Menu item form | adopt | Name, cost, two-state control, "{meal} has $x left." Delete in the form when editing. |
| 2026-10-14 | B8 Settings | adopt | Name, "Signed in as {email}", currency as a dropdown, shipping days with the live resulting date, theme segmented control, sign out, delete account with the verbatim sentence. |
| 2026-10-14 | Laptop: rail and list-plus-detail | adopt with change | Rail with the mark at and above 840 px; list-plus-detail for Gifts and Meals at and above 1200 px; forms as dialogs at and above 840 px. The design gives no breakpoints; these are Material's medium and expanded classes. |
| 2026-10-14 | Empty, loading, error | adopt | Tree glyph plus verbatim sentence plus one button, in place of the first row. Skeleton rows without shimmer. Error block with cloud-off, one line, "Check your connection, then try again.", Try again. |

## System and components

| Date | Screen or component | Verdict | What changes and why |
|---|---|---|---|
| 2026-10-14 | Colour roles, light and dark | adopt | `ColorScheme.fromSeed(0xFF1E4D3B)` then every role from the table in `output/design-system.md` set with `copyWith`, so the result does not drift between Flutter versions. |
| 2026-10-14 | Seasonal extension | adopt | `ThemeExtension<SeasonColors>` with hero, alert and ribbon tokens exactly as listed. |
| 2026-10-14 | Type | adopt with change | Newsreader and Public Sans via `google_fonts`. Tabular figures with `FontFeature.tabularFigures()`; the first stage C task verifies Public Sans exposes `tnum` in the web build and falls back to IBM Plex Sans if not. `moneyLarge` lives in the extension. |
| 2026-10-14 | Icons | adopt with change | Flutter's built-in rounded Material icons, which carry every name the design uses except the Gifts tab glyph; `featured_seasonal_and_gifts` becomes `Icons.redeem_rounded`. No icon package added. |
| 2026-10-14 | Space, shape, depth, motion | adopt | As listed. Bars animate width over 300 ms; everything else 200 ms or none. |
| 2026-10-14 | Ribbon and mark | adopt | `Stack` with two `Positioned` bands; one ribboned object per screen. The mark is also the web favicon and PWA icon, generated as PNG from the same geometry. |
| 2026-10-14 | Button, Input, Sheet, Dialog, Confirm, Snackbar, Tab bar, Rail, Year switcher, Theme toggle | adopt | Stock Material 3 widgets themed; sheet on phone and dialog on laptop share one form widget. |
| 2026-10-14 | Money triple | adopt | Large and compact forms, over state with tag; one widget with a `size` parameter. |
| 2026-10-14 | Row stepper (forward by tap, skipping allowed) | adopt with change | Tapping a later cell moves forward, including To Buy straight to Purchased; a mis-tap is covered by the Undo snackbar. Tapping an earlier cell does nothing on the row; moving back is done in the form. Business rules for dates when skipping or moving back are in the spec, section 11. |
| 2026-10-14 | Form stepper | adopt | `SegmentedButton` with icon and label; any state selectable. |
| 2026-10-14 | Undo snackbar after a status change | adopt | Reverts status and dates to the previous values. Five seconds. |
| 2026-10-14 | Planned-over warning line on B3 | adopt | Display only; no rule changes. |
| 2026-10-14 | Name-based confirm copy | adopt | "{name}'s n gifts are deleted too." |
| 2026-10-14 | Up to three gift links on the Home alert card | adopt | Sorted by recipient name then gift name; "and n more" opens Gifts. |
