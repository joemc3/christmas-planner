# Design output: Evergreen & Brass

What came back from the Claude Design session run against `../brief/`, dated 14 October 2026. It is a proposal. Nothing here is adopted until it is reconciled screen by screen in `../decisions.md`.

- Live canvas: https://claude.ai/artifact/HzVyw1u6WUo3djgdUZNuyU (pages: System, Phone, Laptop)
- `canvas/`: the canvas source, one `.dc.html` per artboard plus `canvas.json`. Open them on the canvas; they are not standalone pages.
- `design-system.md`: palette as Material 3 roles for light and dark, the seasonal theme extension, type scale, spacing, shape, motion, and the component set.

## Direction

The brief asks for warmth without cuteness and "a palette that feels like December without shouting it". The festive feeling comes from three things only:

1. **Evergreen** (`#1E4D3B`) as the seed and primary, on paper-white surfaces.
2. **A brass ribbon**: two crossing bands that wrap exactly one object per screen, the Start Ordering By card on Home and the app mark on sign-in and the rail. It is drawn with two positioned containers and needs no assets.
3. **Cranberry** reserved for problems: over budget, order now, delete.

Type is Newsreader (display) for titles and the ordering date, and Public Sans (text) with tabular figures for every amount. Icons are Material Symbols Rounded. The one seasonal glyph is `park` (a tree), shown beside "days to Christmas" and in empty states. There are no snowflakes, no confetti, no illustration and no celebratory motion. Motion is limited to 200 ms state changes and budget bars easing to their new width.

## What is on the canvas

| Artboard | Contents |
|---|---|
| Main | Design system: roles, extension, type, space, ribbon, mark |
| Components | Every component in `04-constraints.md`, light and dark |
| Auth | A1 sign in, A2 create account, A3 reset (ask, sent, new password) |
| Home | B1 first open, before the date, on the date, everything ordered, over budget, next year, last year read only |
| Gifts | B2 before and on the date, empty, loading, error |
| Recipient | B3 planned over budget, in-shop one-tap Purchased with undo, spent over budget, order now, empty, loading, error, delete confirm, edit person sheet |
| Gift | B4 gift screen, add sheet, edit sheet with dates, delete confirm |
| Meals | B5 meal week, no budgets yet, loading, error |
| Meal | B6 Christmas Day, empty, guests and budget sheet; B7 add item, edit item with delete; loading, error |
| Settings | B8 settings, delete account confirm |
| Laptop × 4 | Home (before and on the date), Gifts list plus recipient plus gift dialog, Meals list plus meal plus item dialog, sign in and settings |

Every phone frame is 390 px; every laptop frame is 1280 × 800. Each artboard shows light above dark, and its Tweaks panel can show one theme only.

Flows covered: C1 (first open → Home with money), C2 (in a shop, Dad), C3 (26 November, three gifts across Mum and Ellie, then everything ordered), C4 (Christmas Day: guests, budget, four items, two bought), C5 (Mum planned over, Sam spent over, Home over), C6 (2027 empty with 2026 read only).

Sample figures add up across frames: master gift budget $600.00; Mum $150.00, Dad $120.00, Sam $100.00, Ellie $80.00, Grandma $60.00; meals $120.00 (Eve) and $220.00 (Day).

## Screen by screen

**A1–A3 Sign in, create account, reset.** Sign-in is the one place the brand gets room: an evergreen band wrapped in the brass ribbon, then a plain form on paper white. One line says what the account is for. There is no social sign-in and no tour; after creating an account the user lands on empty Home. Reset is three quiet states: ask, check your email, new password. Labels sit above fields so that 130 percent text never collides with what is typed. Serves principle 7.

**B1 Home.** Built on principle 2. The ordering date is the only filled, ribboned object on the screen. Before 26 November it carries the verbatim date and the days left. On or after the date it turns cranberry, leads with the verbatim count and lists the gifts themselves as links, so "a way straight to them" is one tap with no new screen. When nothing is To Buy it steps down to a quiet tonal card and says so once. Days to Christmas sits beneath it, small. Gift and meal money follow as two plain sections with remaining as the large number (principle 1); the budget figure is a button that opens the edit sheet. Purchased-of-planned sits in the Gifts heading. The previous-year link is a small text button at the bottom; a read-only year drops the ribbon, labels itself and offers the way back.

**B2 Gifts.** A plain list of people (principles 4 and 5): monogram, name, remaining first, a thin bar, purchased of planned. Over budget changes the words ("$12.00 over"), the bar and adds a tag, so it never relies on a red decimal (principle 1). After the ordering date a cranberry "to order" tag appears only on the rows that need it, and one summary line names the people. The empty state is the verbatim sentence where the first row would be, with the one action (principle 6).

**B3 Recipient.** One person: the large money triple, then their gifts. If planned gifts would exceed the budget, a brass line warns before it happens; when spent exceeds it, the header switches to the over state. Each gift row ends in a three-cell stepper (tag, truck, check). The user taps the state reached, so To Buy to Purchased in a shop is one tap, and the filled cells read left to right as a sequence (principle 3). A snackbar with Undo covers a mis-tap; nothing celebrates. A To Buy gift on or after the date gets "Order now" and a cranberry first cell. Delete asks once and says the gifts go too.

**B4 Gift and gift form.** The gift screen is a reference card for the shop: whose it is and what is left for them, the price large, the store as a link, the status as a labelled three-step control, and the stamped dates beneath it, each editable. The form is one component for add and edit: a bottom sheet on phone, a dialog on laptop. The add form shows what the price would leave in that person's budget. Delete lives on the gift screen, behind one confirm.

**B5 Meals.** Exactly two rows, Christmas Eve and Christmas Day, each with date, guests, remaining of budget, items bought and one bar. There is no add and no delete anywhere. A meal with no budget says so and offers the button in place of the money; that is this screen's empty state.

**B6–B7 Meal and menu item form.** Mirrors the recipient screen so the app teaches one pattern: a header with guests and the money triple, then a flat menu whose rows end in a two-cell stepper (tag, check). Guests and budget are edited together in one sheet. The item form is the gift form with two states and no store; delete sits in the form when editing.

**B8 Settings.** A short form: name, currency, shipping days with the line explaining that it moves the ordering date (showing the resulting date), and theme as a three-way segmented control. Sign out and delete account sit apart at the bottom; delete asks once with the verbatim sentence.

**Laptop.** The phone widened, not a new product (principle 7). The tab bar becomes a rail carrying the mark, Gifts and Meals become list plus detail, and forms open as dialogs. Content holds to readable widths instead of stretching. Nothing appears that the phone does not have.

**Empty, loading, error.** Empty states sit where the first row would be: a tree glyph, the verbatim sentence, one primary button. Loading uses static skeleton rows shaped like the real rows (a slow opacity pulse at most, no shimmer). Errors replace the list with a cloud-off icon, one line saying what failed, "Check your connection, then try again." and a Try again button.

## Points for reconciliation

These go beyond or interpret the brief; each needs a verdict in `../decisions.md`.

1. **Row stepper allows skipping.** Principle 3 says moving forward is one tap. The row control lets the user tap any later state, so To Buy can go straight to Purchased in a shop. Ordered is not forced. Whether skipping Ordered also stamps an order date is a business-rule question, not a design one; GIFT-5 as written stamps only the purchase date.
2. **"Straight to them" without a new screen.** On or after the date, the Home card lists up to three gifts as links (each opens B4). With more than three, the plan is to show three and a "and n more" link to Gifts. No filtered gift list is introduced.
3. **Planned-over warning.** PRD GIFT-3 already computes planned. The brass line on B3 ("Planned $153.99, $3.99 more than the budget") only displays it when planned exceeds budget. It changes no rule.
4. **Gender-neutral confirms.** Confirm copy uses the person's name ("Mum's 2 gifts are deleted too") because the app does not know anyone's pronouns.
5. **Undo snackbar** after every one-tap status change. Not in the brief; it is the cost of making status changes one tap.
6. **Fonts.** Verify that the Google Fonts build of Public Sans exposes `tnum` in Flutter (`FontFeature.tabularFigures()`) before committing; the fallback is Source Sans 3 or IBM Plex Sans.
7. **Custom-drawn pieces:** the ribbon (two `Positioned` containers) and the row stepper (a `SegmentedButton` restyled, or a `Row` of `IconButton`s inside a bordered `ClipRRect`). Everything else is a stock Material 3 widget.
