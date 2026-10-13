# Christmas Planner: product and technical spec

Status: living document. Written October 2026 from the code, the database
schema and the original idea, because the PRD/TRD the first commit mentions
was never checked in. Treat the "Status" column of each table as the source of
truth for what exists today.

## 1. The idea in one paragraph

One private place to run the whole Christmas: who you are buying for and how
much you can spend on each of them, what you are serving on Christmas Eve and
Christmas Day and what that costs, one overall budget that rolls everything up,
and a calendar that works backwards from 25 December so nothing is ordered too
late. It replaces the usual mix of a notes app, a spreadsheet and browser tabs.

## 2. Who it is for

- **The planner.** One person in a household who owns Christmas logistics.
  Phone first, laptop sometimes. Starts in October or November, uses the app
  heavily for eight weeks, then wants to look back next year.
- **Not (yet) for:** multiple adults editing the same plan, or recipients
  viewing their own wish lists. The schema has the tables for both
  (`wishlists`, `wishlist_items` with claim tracking) but nothing is built on
  them. See section 9.

## 3. Jobs to be done

1. "I need to know how much Christmas will cost before I start spending."
2. "I have gift ideas scattered everywhere; I want them per person with a
   budget and to know what is bought, what is on its way and what still needs
   wrapping."
3. "I am hosting; I need the menu, the shopping and who is bringing what."
4. "Tell me the last safe day to order online so things arrive in time."
5. "Give me one list to take to the shops."

## 4. Functional requirements

### 4.1 Accounts

| Req | Description | Status |
|---|---|---|
| A1 | Email + password sign up, sign in, sign out | Done |
| A2 | Password reset by email | Done |
| A3 | Profile: name, currency, default shipping days | Done |
| A4 | Delete account and all data | Done (cascades in DB) |
| A5 | A new account gets a default shopping list and a budget row for the current year | Done (DB trigger) |

### 4.2 Gifts

| Req | Description | Status |
|---|---|---|
| G1 | Add recipients with relationship, age group, interests, notes, priority, personal budget | Done |
| G2 | Add gifts to a recipient: planned price, paid price, store, link, category, priority, surprise flag, notes | Done |
| G3 | Gift status: To Buy, Ordered, Purchased, Wrapped, Delivered; changing status stamps order/delivery/wrapped dates | Done |
| G4 | Per-recipient: planned vs budget, spent, remaining, progress bar, over-budget warning | Done |
| G5 | Overall: budget vs planned vs bought across all recipients | Done |
| G6 | Order date, expected delivery, tracking number | Done |
| G7 | Archive a recipient (keep history, hide from list) | Repo and column exist, no UI |
| G8 | Search and filter gifts (by status, by store) | Not built |
| G9 | Gift photos | Column exists, no UI |

### 4.3 Meals

| Req | Description | Status |
|---|---|---|
| M1 | Meals of type Christmas Eve, Christmas Day, Other with guest count, time, location, theme, dietary needs, budget | Done |
| M2 | Menu items with course, quantity, estimated and paid cost, prep and cook minutes, who is bringing it, store, recipe link | Done |
| M3 | Item status To Buy, Purchased, Prepared with one-tap cycling | Done |
| M4 | Per-meal planned vs budget vs spent, items prepared, total kitchen time | Done |
| M5 | Generate a shopping list from a meal's To Buy items | Not built (schema supports it: `shopping_list_items.meal_item_id`) |
| M6 | Cooking-day timeline (work back from meal time using prep and cook minutes) | Not built |

### 4.4 Budget

| Req | Description | Status |
|---|---|---|
| B1 | One budget per year with gift, Eve meal, Day meal, decorations, activities, misc allocations | Done |
| B2 | Spending is derived from gifts and meal items (ordered/purchased and above), plus manual expenses for the other categories | Done (expenses table has no UI yet) |
| B3 | Overview with stacked bar and per-category cards | Done |
| B4 | Add a manual expense (decorations, activities, misc) | Not built |
| B5 | Alerts when a category passes 90 percent | Partial (colour only, no notification) |

### 4.5 Calendar and deadlines

| Req | Description | Status |
|---|---|---|
| C1 | Month view with events, add event with reminder lead time | Done |
| C2 | Countdown to Christmas and to the preparation deadline (10 Dec) on the dashboard | Done |
| C3 | "Last day to order" = preparation deadline minus buffer minus the user's default shipping days; shown on the dashboard and per gift | Dashboard card done; per-gift warning not built |
| C4 | Auto-generated events: last order day, each gift's expected delivery, meal times | Not built |
| C5 | Local notifications for reminders (mobile) | Service exists, nothing schedules notifications |

### 4.6 Shopping

| Req | Description | Status |
|---|---|---|
| S1 | Multiple lists, add items with category and estimated cost, tick off, totals | Done |
| S2 | Items linked back to a gift or a meal item | Columns exist, no UI |
| S3 | Consolidated "everything still to buy" view across gifts and meals | Not built |

### 4.7 Dashboard

Shows greeting, days to Christmas and to the deadline, the last day to order
online (C3), gift budget used, quick links and the five most recent gifts.
A meal summary card is a small follow-up.

## 5. Non-functional requirements

- **Privacy.** Every table has row-level security keyed on `auth.uid()`;
  a user can only read or write their own rows. Verified by reading
  `supabase/migrations/20250101000002_rls_policies.sql`; not yet covered by an
  automated test.
- **Platforms.** Web first (Docker image serves the Flutter web build). The
  code is platform-neutral, but `android/` and `ios/` have not been generated
  (`flutter create --platforms android,ios .` when wanted).
- **Offline.** None. Supabase streams keep screens live while online.
- **Performance.** Data per user is tiny (tens of rows per table); client-side
  grouping is fine. No pagination needed.
- **Accessibility.** Material 3 widgets, tap targets of at least 44 px,
  text scaling is currently pinned to 1.0 in `app.dart` and should be
  unpinned once layouts are checked at large text sizes.

## 6. Data model

Tables (all with UUID keys, `created_at`, `updated_at` triggers, RLS):

```
user_profiles (1:1 with auth.users)
family_budgets (user, year) ── gift_budget_total, meal_budget_eve/day, decorations, activities, misc
recipients (user) ──< gifts
meals (user, type, year) ──< meal_items
shopping_lists (user) ──< shopping_list_items ──? gifts / meal_items
calendar_events (user)
tasks (user) ──? gifts / meals          (no UI yet)
notifications (user)                     (no UI yet)
expenses (user) ──? gifts / meal_items   (no UI yet)
wishlists (user, recipient) ──< wishlist_items (claimed_by)   (no UI yet)
budget_categories (user, name, year)     (no UI yet)
```

Enums: `gift_status`, `meal_type`, `meal_item_status`. Money is `NUMERIC(10,2)`.

Design notes:

- Gifts hang off recipients, not users, so deleting a recipient removes their
  gifts and RLS on gifts is a join through recipients.
- Budgets and meals carry a `year`, which is how "look back at last year"
  will work. Recipients and gifts do not, so year-over-year gift history is
  not possible yet; adding `year` to recipients (or an archive-per-year flow)
  is the fix.

## 7. Architecture

- Flutter 3.47 / Dart 3.13, Riverpod 3 for state, go_router 17 with a
  `StatefulShellRoute` for the five tabs.
- Feature folders (`lib/features/<name>/{data,presentation}`): models are
  plain `Equatable` classes with `fromJson`/`toInsertJson`; repositories wrap
  `supabase_flutter` and throw typed exceptions; providers expose streams
  (`.stream(primaryKey:)`) for lists and futures for single rows.
- Supabase: Postgres + Auth + PostgREST + Realtime. Config in
  `supabase/config.toml`, schema in `supabase/migrations/`.
- Deploy: `Dockerfile` builds the web bundle (Supabase URL and anon key are
  compile-time `--dart-define`s) and serves it with nginx.

## 8. Known gaps and risks

1. No end-to-end test against a real Supabase; CI applies the migrations to a
   fresh Postgres and runs unit/widget tests only.
2. `watchAllGifts` streams every gift the user can see and the dashboard
   groups client-side; fine at this scale, but RLS is what scopes it.
3. Streams do not refetch a single row's `FutureProvider` (recipient by id,
   gift by id); the forms invalidate them after a save, so stale data only
   appears if a row changes on another device while a detail screen is open.
4. `AppTheme.darkTheme` exists but has not been reviewed screen by screen.

## 9. Roadmap, in order of value

1. Flag individual gifts that are still To Buy once the last order date
   (C3) is close; this is the feature that makes the app different from a
   list.
2. "Build shopping list from meal" (M5) and the consolidated to-buy view (S3).
3. Manual expenses (B4) so decorations and activities actually count.
4. Archive recipients (G7) and gift search (G8).
5. Household sharing: a `households` table, membership, and RLS keyed on
   household instead of user. This is the big one and changes every policy.
6. Wish lists that recipients can view and relatives can claim from (schema
   is already there).
7. Mobile builds, local notifications for deadlines (C5).
