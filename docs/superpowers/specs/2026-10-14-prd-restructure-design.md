# Restructure to the PRD: technical design

**Date:** 2026-10-14
**Implements:** `docs/PRD.md` version 1.1
**Status:** approved in conversation 2026-10-14; implementation in PR #6 after the design session

## 1. Goal

Bring the code down to the product in `docs/PRD.md` and make it modular enough that any item in PRD section 8 can be added as a new module without reworking the others. The visual layer is not designed here; it comes from `docs/design/output/` through `docs/design/decisions.md` and is implemented in the same PR as this restructure.

## 2. What goes, what stays

### Removed

| Thing | Where | Why |
|---|---|---|
| Calendar feature | `lib/features/calendar/`, `calendar_events` table, `table_calendar` package | PRD 8 |
| Shopping feature | `lib/features/shopping/`, `shopping_lists`, `shopping_list_items` tables | PRD 8 |
| Budget screen | `lib/features/budget/presentation/`, route `/budget` | Gift budget is edited from Home; meal budgets live on meals |
| Dead tables | `tasks`, `notifications`, `expenses`, `wishlists`, `wishlist_items`, `budget_categories` | No UI, no requirement |
| Dead models and service | `lib/shared/models/task_model.dart`, `notification_model.dart`, `lib/shared/services/notification_service.dart`, `flutter_local_notifications` package | No requirement |
| Gift statuses Wrapped, Delivered | `gift_status` enum, stepper | PRD GIFT-2 |
| Meal type Other | `meal_type` enum, add/delete meal | PRD MEAL-1 |
| Meal item status Prepared | `meal_item_status` enum | PRD MEAL-3 |
| Recipient columns | `relationship`, `age_group`, `interests`, `notes`, `avatar_url`, `priority`, `archived` | PRD GIFT-1 |
| Gift columns | `description`, `actual_price`, `tracking_number`, `expected_delivery_date`, `actual_delivery_date`, `wrapped_date`, `category`, `image_url`, `priority`, `notes`, `is_surprise` | PRD GIFT-2 |
| Meal columns | `name`, `meal_time`, `location`, `theme`, `dietary_restrictions`, `notes` | PRD MEAL-1, MEAL-2; the type is the name |
| Meal item columns | `description`, `quantity`, `actual_cost`, `store_name`, `category`, `recipe_link`, `prep_time`, `cook_time`, `assigned_to`, `notes` | PRD MEAL-3 |
| Budget columns | `family_budgets.meal_budget_eve`, `meal_budget_day`, `decorations_budget`, `activities_budget`, `miscellaneous_budget` | Meal budgets live on `meals.budget_limit`; the rest is PRD 8 |
| Profile columns | `user_profiles.avatar_url`, `timezone`, `notification_preferences` | No requirement |
| `docs/SPEC.md` | | Replaced by `docs/PRD.md` and this document |

### Kept

`user_profiles` (id, email, full_name, currency, default_shipping_days), `family_budgets` renamed to `plans` (user_id, year, gift_budget_total), `recipients` (plan_id, name, budget_limit), `gifts` (recipient_id, name, price, store_name, order_link, status, order_date, purchased_date), `meals` (plan_id, type, guest_count, budget_limit), `meal_items` (meal_id, item_name, cost, status). Auth, settings, the Frosted widgets as a base to rebuild from, the smoke test harness, CI, Makefile.

### Added

- `plans` as the explicit year container (section 4).
- `gifts.purchased_date`.
- `ordering.dart`: the pure Start Ordering By logic and the per-gift state (section 5).
- An `AppModule` contract so tabs are registered, not hardwired (section 6).
- A read-only mode for previous years (section 7).

## 3. Architecture

Unchanged in kind: Flutter 3.47, Riverpod 3, go_router 17 with a `StatefulShellRoute`, supabase_flutter 2, feature folders `lib/features/<name>/{data,domain?,presentation}`. Lists are Supabase streams; single rows are futures invalidated by forms after save. Sums are computed in Dart from the streamed rows; nothing is stored.

```
lib/
  app.dart                      MaterialApp.router, themes from design output
  core/
    domain/ordering.dart        pure functions, no Flutter imports
    domain/money.dart           sums: planned, spent, remaining for gifts and items
    modules/app_module.dart     the AppModule contract and the registered list
    router.dart                 builds routes from modules + the fixed auth/settings routes
    theme/                      tokens from docs/design/output after reconciliation
  features/
    auth/                       as today, plus forgot-password screen
    plan/                       plans table, current-year provider, year switcher, ensure_plan RPC
    home/                       the Home tab; reads gifts, meals, plan, ordering
    gifts/                      recipients + gifts: data, presentation
    meals/                      meals + items: data, presentation
    settings/                   as today, plus theme choice
  shared/widgets/               the component set from the design, rebuilt
```

## 4. Data model and migration

One new migration, `20251015000004_prd_restructure.sql`, applied on top of the three existing ones. It is destructive by design: the only data that exists is local smoke-test data; there is no hosted project. The migration:

1. Creates `plans (id, user_id, year, gift_budget_total, created_at, updated_at, UNIQUE(user_id, year))`, copies rows from `family_budgets`, drops `family_budgets`.
2. Adds `recipients.plan_id` and `meals.plan_id` (NOT NULL, FK `plans` ON DELETE CASCADE). Backfills from the row's user and year (recipients take the user's current-year plan; meals use their existing `year`). Drops `recipients.user_id`, `meals.user_id`, `meals.year`. RLS on recipients and meals becomes a join through `plans.user_id`; RLS on gifts and meal_items joins through their parent as today.
3. Recreates the three enums with the PRD values. Postgres cannot drop enum values, so: create `gift_status_v2 ('To Buy','Ordered','Purchased')`, update rows (`Wrapped`, `Delivered` become `Purchased`), alter the column type with a `USING` cast, drop the old type, rename. Same for `meal_type_v2 ('Xmas_Eve','Xmas_Day')` (rows of type `Other` are deleted with their items) and `meal_item_status_v2 ('To Buy','Purchased')` (`Prepared` becomes `Purchased`).
4. Adds `gifts.purchased_date DATE`. Drops the columns listed in section 2 from every kept table.
5. Drops the removed tables, their triggers and policies, and removes them from the realtime publication. Keeps `REPLICA IDENTITY FULL` on the kept tables; adds it to `plans`.
6. Replaces `handle_new_user()`: inserts the profile only. No shopping list, no budget row.
7. Adds `ensure_plan(p_year int) RETURNS plans` (SECURITY DEFINER, checks `auth.uid()`): inserts the plan row for the caller and year if missing, and the two meals (`Xmas_Eve`, `Xmas_Day`) for it if missing, and returns the plan. Idempotent. The client calls it when Home opens for the current year, so next year's plan appears on first open in January.
8. Adds a unique constraint `meals (plan_id, type)` so the two meals cannot be duplicated.

`supabase db lint --level error` and the migrations CI job must pass; the smoke test must sign up a new user and complete every flow on the fresh schema.

## 5. Domain logic

`lib/core/domain/ordering.dart`, pure Dart:

```dart
const preparationDay = 10;        // December
const bufferDays = 7;

DateTime preparationTarget(int year) => DateTime(year, 12, preparationDay);
DateTime startOrderingBy(int year, int shippingDays) =>
    preparationTarget(year).subtract(Duration(days: bufferDays + shippingDays));

enum OrderingState { notYet, dueToday, overdue, handled }
OrderingState giftOrderingState({required GiftStatus status, required DateTime today, required DateTime startBy});
int giftsNeedingOrder(Iterable<Gift> gifts, DateTime today, DateTime startBy);
```

`handled` means the status is Ordered or Purchased. `shippingDays` is validated 0 to 60 at the settings form and clamped here. Tests cover the PRD example (2026, 7 days gives 26 November 2026), both boundaries, a year change, and each state.

`lib/core/domain/money.dart`: `planned`, `spent`, `remaining` for a list of gifts (spent counts Ordered and Purchased) and a list of meal items (spent counts Purchased), plus `purchasedCount` and `plannedCount`. Tests cover empty lists, rounding at two decimals, and over-budget.

## 6. Modules

```dart
abstract class AppModule {
  String get id;                          // 'home', 'gifts', 'meals'
  NavigationDestination get destination;  // icon and label for the tab
  List<RouteBase> routes(GlobalKey<NavigatorState> root);  // this tab's branch routes
}
final appModules = <AppModule>[HomeModule(), GiftsModule(), MealsModule()];
```

`core/router.dart` builds the `StatefulShellRoute` branches and the shell's destinations from `appModules`, and adds the auth and settings routes itself. Adding a calendar later is a new `features/calendar/` with its own `AppModule`, a migration, and one line in `appModules`. Modules do not import each other; Home reads gifts and meals through their public providers only.

## 7. Plans and years

`features/plan/` exposes `currentPlanProvider` (calls `ensure_plan(thisYear)` once per app start) and `selectedPlanProvider`, which defaults to the current plan and can be set to a previous year from Home. Every gifts and meals provider is keyed on the selected plan's id. When the selected plan is not the current year, forms and status taps are disabled and the screens show a read-only marker; the design decides how.

## 8. Error handling

As today: repositories throw typed exceptions (`AppException` subclasses), providers surface them as `AsyncError`, screens show the error inline with a retry. The `ensure_plan` call failing blocks Home with a message and retry; the app cannot work without a plan row.

## 9. Testing

- Unit: `ordering.dart`, `money.dart`, every model's `fromJson`/`toInsertJson`, the module registry producing the expected routes.
- Widget: Home with fixtures before and after the ordering date; recipient row over budget; the status stepper in both sizes.
- Smoke (`tool/e2e/smoke.mjs`): rewritten for three tabs and the new screens, running flows C1 to C5 from the design brief, screenshots refreshed into `docs/screenshots/`.
- Migration: CI's `supabase db start` plus `db lint`; the smoke test proves the new schema end to end.

## 10. Out of scope here

Visual design (the design session), hosting, mobile builds, anything in PRD section 8.

## 11. Rules settled by the design reconciliation (2026-10-14)

From `docs/design/decisions.md`. These are product rules the brief left open and the design made concrete; the PRD's rules in section 5 are unchanged.

- **Status dates.** Moving to Ordered stamps `order_date` = today if it is null. Moving to Purchased stamps `purchased_date` = today if null; skipping Ordered leaves `order_date` null. Moving back (only possible in the form) clears the dates of states no longer reached. Both dates stay editable in the form.
- **Undo.** A row-stepper change shows a snackbar for five seconds whose Undo restores the previous status and both dates exactly.
- **Zero means unset.** A plan's `gift_budget_total` of 0 shows "No gift budget yet"; a meal's `budget_limit` of 0 shows "No budget set yet"; a meal's `guest_count` of 0 shows "Guests not set". Sums treat them as 0.
- **Meal dates.** Christmas Eve is 24 December and Christmas Day 25 December of the plan year, derived for display, never stored.
- **Home alert card.** On or after Start Ordering By, lists at most three To Buy gifts (by recipient name, then gift name) as links to B4, then "and n more" to Gifts.
- **Previous years.** A plan whose year is less than the current year is read-only: no add, edit, delete or status change; the UI says so. `ensure_plan` is called only for the current year.
- **Routes.** `/login`, `/register`, `/forgot`, `/reset` (target of the Supabase recovery email; the app reads the recovery session and shows the new-password form), `/settings`, `/home`, `/gifts`, `/gifts/:recipientId`, `/gifts/:recipientId/gift/:giftId`, `/meals`, `/meals/:mealId`.
- **Breakpoints.** Below 840 px: bottom `NavigationBar`, forms as bottom sheets, one pane. 840 px and up: `NavigationRail` with the mark, forms as dialogs. 1200 px and up: Gifts and Meals render list plus detail side by side; the detail routes still exist and deep-link.
- **Theme.** Follow system, light or dark, stored per device in shared preferences (not in the profile); default follows system.
- **Icons.** Built-in rounded Material icons; the Gifts tab uses `redeem`.
