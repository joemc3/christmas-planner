# Christmas Planner: Product Requirements

**Version:** 1.1
**Date:** 2026-10-14
**Supersedes:** [PRD 1.0 of 2025-11-15](original/PRD.md), kept verbatim for the record.
**Reader:** the product owner. Everything here is a product statement; the technical design is in `superpowers/specs/`.

## 1. What it is

One place to plan a family Christmas and stay inside the money. You list the people you are buying for and what each may cost, list the gifts under each person, and the app tells you what you have spent, what is left, and the date by which ordering has to start so that everything is in the house by 10 December. The same for the two Christmas meals: who is coming, what it may cost, what is on the menu, what is bought.

It replaces a spreadsheet and a notes app. It is not a calendar, a to-do app or a wish-list service.

## 2. Who it is for

One person in a household who owns Christmas. Phone first, laptop sometimes. Heavy use from October to mid December; a glance back the following year.

## 3. What changed from version 1.0

Version 1.0 was the brief the first build was generated from. The generated app went well past it (a calendar, shopping lists, a five-step gift status, six unused database tables). This version returns to 1.0 and keeps only the additions that serve it. Everything removed is listed in section 8 for the product owner to bring back when wanted.

Kept from the first build, beyond 1.0:

- Sign in with email and password, password reset by email, sign out, delete account.
- A settings screen for the user's name, currency and default shipping days (1.0 required shipping days to be configurable but did not say where).
- The date a gift was ordered and the date it was purchased are stamped automatically when its status changes.
- The "Start Ordering By" date is shown next to every gift that is still To Buy, not only on the home screen. This is what makes the date useful.
- A plan belongs to a year. On 1 January the app starts a fresh plan and last year's stays readable.

Settled here, open to the product owner's override:

| Decision | Choice | Why |
|---|---|---|
| Gift statuses | To Buy, Ordered, Purchased (as 1.0) | Wrapped and Delivered added two taps per gift and nothing to the budget. |
| Recipient fields | Name and budget (as 1.0) | Relationship, age group, interests and priority were never used by any calculation or screen that mattered. |
| Meal budgets | Set on each meal, not in a separate budget screen | 1.0 listed the meal budgets in two places; one is enough. |
| Year | Every plan is for one year; the app opens on the current year | 1.0 did not say what happens next year. |

## 4. Requirements

Status column: **Built** means it exists in the current code and survives the restructure; **Change** means it exists but is reduced or moved; **New** means it does not exist yet.

### 4.1 Account

| ID | Requirement | Status |
|---|---|---|
| ACC-1 | Create an account with email and password; sign in; sign out. | Built |
| ACC-2 | Reset a forgotten password by email. | Built |
| ACC-3 | Settings: display name, currency, default shipping days (default 7). | Built |
| ACC-4 | Delete the account and everything in it. | Built |

### 4.2 Gifts

| ID | Requirement | Status |
|---|---|---|
| GIFT-1 | Add, edit and delete recipients. A recipient has a name and a budget. | Change (fields reduced) |
| GIFT-2 | Under a recipient, add, edit and delete gifts. A gift has a name, a price, an optional store or link, and a status: To Buy, Ordered, Purchased. | Change (fields and statuses reduced) |
| GIFT-3 | For each recipient show: budget, planned (sum of all gift prices), spent (sum of Ordered and Purchased), remaining (budget minus spent), and gifts purchased out of gifts planned. | Built |
| GIFT-4 | A master gift budget for the year, set by the user, with total, spent and remaining across all recipients. | Built |
| GIFT-5 | Changing a gift to Ordered stamps the order date; to Purchased stamps the purchase date. Both visible on the gift. | Change (two dates instead of five) |

### 4.3 Ordering timeline

| ID | Requirement | Status |
|---|---|---|
| TIME-1 | Preparation target: 10 December of the plan year. Fixed. | Built |
| TIME-2 | Start Ordering By = 10 December minus (7 buffer days plus the user's shipping days). With the default 7 shipping days this is 26 November. | Built |
| TIME-3 | The home screen shows the Start Ordering By date and how many days remain until it, or how many days past it is. | Built |
| TIME-4 | Every gift still To Buy shows the same date and, once the date has passed, is marked as needing to be ordered now. Recipient rows show how many of their gifts are in that state. | New |

### 4.4 Meals

| ID | Requirement | Status |
|---|---|---|
| MEAL-1 | Each plan year has exactly two meals: Christmas Eve and Christmas Day. They cannot be added or deleted, only edited. | Change (no "other" meals) |
| MEAL-2 | A meal has a guest count and a budget. | Built |
| MEAL-3 | Under a meal, add, edit and delete menu items. An item has a name, a cost and a status: To Buy, Purchased. | Change (fields and statuses reduced) |
| MEAL-4 | For each meal show: budget, planned (sum of item costs), spent (sum of Purchased), remaining, and items purchased out of items planned. | Built |
| MEAL-5 | A master meal view: the two budgets added together, total spent, total remaining. | Change (moves to the home screen) |

### 4.5 Home

| ID | Requirement | Status |
|---|---|---|
| HOME-1 | Opens on the current year's plan. Shows days to Christmas, the Start Ordering By date (TIME-3), the master gift budget (GIFT-4) and the master meal budget (MEAL-5). | Change (budget moves here, recent-gifts list goes) |
| HOME-2 | Shows how many gifts across all recipients still need ordering now (TIME-4). | New |
| HOME-3 | Previous years' plans can be opened read-only. | New |

## 5. Business rules

- Spent on gifts = sum of `price` of gifts whose status is Ordered or Purchased.
- Remaining gift budget = master gift budget minus spent on gifts. Per recipient, remaining = recipient budget minus that recipient's spent.
- Spent on a meal = sum of `cost` of its items whose status is Purchased.
- Remaining meal budget = meal budget minus spent on that meal.
- Start Ordering By = 10 December of the plan year minus (7 + shipping days). Shipping days is a whole number from 0 to 60.
- A gift needs ordering now when its status is To Buy and today is on or after Start Ordering By.
- All sums are computed from the rows at the time of display; no totals are stored.
- A user sees only their own data.

## 6. Platforms

Web first, installable on a phone's home screen. The code is Flutter, so iOS and Android builds follow when the product owner wants them; nothing in this document depends on a native feature.

## 7. Quality bar

Production. Every screen works at phone width and on a laptop, in light and dark. Every requirement above has an automated test or is exercised by the browser smoke test before a release. No feature ships half-built behind a hidden table or an unused column.

## 8. Not in this version

For the product owner to decide, in no particular order. Each is designed to be addable as its own module without reworking what is here.

- Calendar of events and reminders; auto-generated events for the ordering date, deliveries and meal times.
- Shopping lists, including a list generated from a meal's To Buy items and one combined "still to buy" list.
- Budgets for decorations, activities and miscellaneous spending, with manual expenses.
- Gift statuses Wrapped and Delivered, tracking numbers, expected delivery dates, gift photos.
- Recipient details: relationship, age group, interests, notes, priority, archiving.
- Meal details: time, location, theme, dietary needs, courses, prep and cook times, who brings what, recipe links; a cooking-day timeline.
- Wish lists that recipients view and relatives claim from.
- A household: several adults editing the same plan.
- Native mobile builds and local notifications for the ordering date.
- Year-over-year comparisons beyond opening last year's plan.
