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

Written after reconciliation. One task per row of `docs/design/decisions.md` with verdict adopt or adopt with change, in this order: theme and tokens, the component set, then screens in the order of `03-screens-and-flows.md`, then empty/loading/error states, then the smoke test screenshots refreshed into `docs/screenshots/` and the README screenshot table updated.

## Done when

- `make check` and `make smoke` green on the PR branch.
- Every PRD 4.x row marked Built, Change or New is exercised by a unit, widget or smoke test, and the PRD status column says Built.
- `docs/design/decisions.md` has a row for every screen and component in the brief.
- The vault Status and Overview reflect the new shape (three tabs, `plans`, ports, FVM).
