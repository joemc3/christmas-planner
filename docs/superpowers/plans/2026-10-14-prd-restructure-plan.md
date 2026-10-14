# Restructure to the PRD: implementation plan

**Spec:** `../specs/2026-10-14-prd-restructure-design.md`
**Lands in:** PR #6, together with the reconciled design. Stages A and B below do not depend on the design and are fully planned. Stage C is the visual layer; its tasks are written after `docs/design/decisions.md` exists, because they are the decisions.

Each task: write the failing test first where one applies, make it pass, run `make check`. Commit per task on the PR branch; the PR is one review.

## Stage A: schema and domain

### A1. Domain: ordering
- Create `lib/core/domain/ordering.dart` per spec section 5.
- Tests in `test/unit/ordering_test.dart`: 2026 with 7 shipping days is 26 Nov 2026; 0 and 60 shipping days; 2027; `notYet` the day before, `dueToday` on the day, `overdue` after, `handled` for Ordered and Purchased regardless of date; `giftsNeedingOrder` counts only To Buy on or after the date.
- Move `DateUtils.calculateStartOrderingDate` callers to it; delete the old function and its test.

### A2. Domain: money
- Create `lib/core/domain/money.dart` per spec section 5.
- Tests in `test/unit/money_test.dart`: empty lists give zero; spent counts Ordered and Purchased for gifts and Purchased only for items; remaining goes negative; counts.

### A3. Migration
- Write `supabase/migrations/20251015000004_prd_restructure.sql` following spec section 4, steps 1 to 8, in that order.
- `make db-reset`; it must apply clean. `make lint-db` clean.
- Verify by hand once against the reset stack: sign up via the running app, confirm `plans` has one row and `meals` has two for the new user, confirm the dropped tables are gone (`\dt` in `supabase db psql` or Studio).

### A4. Models and repositories
- `Plan` model and `PlanRepository` (`ensurePlan(year)`, `watchPlans()`, `updateGiftBudget(planId, amount)`).
- Reduce `Recipient`, `Gift`, `Meal`, `MealItem` models to the kept columns; `GiftStatus` and `MealItemStatus` enums to the PRD values; `MealType` to two. `Gift.toInsertJson` stamps `order_date` or `purchased_date` on status change (move the logic that stamps dates today).
- Repositories take `planId` where they took `userId`. Delete `BudgetRepository`, `CalendarRepository`, `ShoppingRepository`.
- Tests: `fromJson`/`toInsertJson` round trips for every model; date stamping on each transition.

## Stage B: app structure

### B1. Modules and router
- `lib/core/modules/app_module.dart` with the `AppModule` contract and `appModules`.
- `lib/core/router.dart` replaces `lib/core/utils/router.dart`: auth routes, `/settings`, `/forgot`, and the shell built from `appModules`. `MainShell` takes its destinations from the modules.
- Test: the registry yields three branches with paths `/home`, `/gifts`, `/meals`, and the shell shows three destinations.

### B2. Remove the dead features
- Delete `lib/features/calendar/`, `lib/features/shopping/`, `lib/features/budget/presentation/`, `lib/shared/models/task_model.dart`, `notification_model.dart`, `lib/shared/services/notification_service.dart`.
- Remove `table_calendar` and `flutter_local_notifications` from `pubspec.yaml`; `fvm flutter pub get`.
- Delete the old router. `make check` clean with the smoke test temporarily skipped.

### B3. Plan feature
- `features/plan/`: providers per spec section 7, the `ensure_plan` call on app start, `selectedPlanProvider`, a `readOnlyProvider` derived from it.
- Gifts and meals providers keyed on `selectedPlanProvider`.
- Widget test: a screen in read-only mode disables its add button and status taps.

### B4. Home data
- `features/home/` providers that combine plan, gifts, meals and ordering into one view model: ordering date and state, gifts needing order, gift money triple, meal money triple, gift counts.
- Unit test of the view model with fixtures before and after the ordering date.

### B5. Screens on the old look, new structure
- Point the existing Frosted screens at the new models and providers so the app runs end to end on the new schema before the new design lands: Home (existing dashboard reduced), Gifts list, Recipient, Gift form (three-step stepper), Meals (two fixed rows), Meal, Item form, Settings. Remove the removed fields from every form.
- Rewrite `tool/e2e/smoke.mjs` for three tabs and flows C1 to C5. `make smoke` green with screenshots into a scratch folder (not `docs/screenshots/` yet).

This is the point at which the restructure is complete and verifiable independent of the design. If the design session is late, stages A and B can land as their own PR for a reason we can name: the schema change unblocks everything else.

## Stage C: the design

Written 2026-10-14 from `docs/design/decisions.md`; every row there with verdict adopt or adopt with change maps to a task below. The source of truth for values is `docs/design/output/design-system.md`.

### C1. Theme and tokens
- `lib/core/theme/color_schemes.dart`: light and dark `ColorScheme` from the seed with every role set per the table. `lib/core/theme/season_colors.dart`: the `ThemeExtension`. `lib/core/theme/typography.dart`: Newsreader and Public Sans via `google_fonts`, the text theme table, `moneyLarge` in the extension, tabular figures.
- First, a throwaway check that Public Sans renders `tnum` in a web build (compare "11.11" and "00.00" widths); if not, switch to IBM Plex Sans and record it in `decisions.md`.
- `lib/core/theme/app_theme.dart` rebuilt: shapes, spacing constants, component themes (buttons, inputs with label above, navigation bar and rail, snackbar, dialogs, sheets). Delete the Frosted theme.
- Theme mode provider backed by shared preferences; `app.dart` honours it.
- Test: both schemes have the expected primary, error and surface values; the extension resolves in both.

### C2. Components
`lib/shared/widgets/`, one file each, each with a widget test where behaviour exists:
- `app_mark.dart` (also exported as the favicon and PWA icon PNGs under `web/`), `ribbon_card.dart` (Stack with two Positioned bands).
- `money_triple.dart` (large and compact, over state, animated bar).
- `status_stepper_row.dart` (bordered pill of 44 px cells, forward only, skipping allowed, calls back with the new status) and `status_stepper_form.dart` (SegmentedButton).
- `recipient_row.dart`, `gift_row.dart`, `meal_row.dart`, `menu_item_row.dart`.
- `ordering_banner.dart` (before, alert with up to three links, all-ordered quiet).
- `form_host.dart`: shows a child form as a bottom sheet below 840 px and a dialog at or above. `confirm.dart`. `empty_state.dart`, `skeleton_rows.dart`, `error_block.dart`.
- `undo_snackbar.dart`: helper that shows the snackbar and wires Undo to a revert callback.

### C3. Screens, in brief order
Each task replaces the stage B5 placeholder screen with the designed one and extends the smoke test to cover it.
- A1 sign in, A2 create account, A3 reset (three states; `/forgot` and `/reset` routes; recovery session handling).
- B1 Home: all seven states from the canvas, driven by the view model from B4; budget edit sheet; year switcher and read-only banner.
- B2 Gifts list with tags and the after-date summary line.
- B3 Recipient with planned-over line, row steppers with undo, Order now markers, delete confirm, edit-person sheet.
- B4 Gift screen and the shared gift form (add shows "leaves"; edit shows dates).
- B5 Meals with the unset states. B6 Meal with the guests-and-budget sheet. B7 item form.
- B8 Settings with currency dropdown, live ordering date, theme control, delete confirm.
- Laptop: rail at 840, list-plus-detail at 1200 for Gifts and Meals, dialogs.

### C4. States and the smoke test
- Empty, loading and error for every list screen, using the shared widgets.
- `tool/e2e/smoke.mjs`: flows C1 to C6 at 390 px, then Home, Gifts and Meals at 1280 px; screenshots into `docs/screenshots/`; README screenshot table updated to the new file names.
- `make smoke` green; `docs/PRD.md` status column updated to Built for every row.

## Done when

- `make check` and `make smoke` green on the PR branch.
- Every PRD 4.x row marked Built, Change or New is exercised by a unit, widget or smoke test, and the PRD status column says Built.
- `docs/design/decisions.md` has a row for every screen and component in the brief.
- The vault Status and Overview reflect the new shape (three tabs, `plans`, ports, FVM).
