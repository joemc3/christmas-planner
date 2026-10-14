# Screens and flows

Sentences marked **verbatim** must appear exactly as written. Everything else, including headings, button labels and the order of secondary content, is open to design. Money is shown in the user's currency with two decimals. "Today" examples assume 2026 and a user with the default 7 shipping days, so Start Ordering By is 26 November 2026.

## A. Outside the plan

### A1. Sign in (`/login`)
Email, password with reveal, sign in. A link to reset the password and a link to create an account. No social sign-in.

### A2. Create account (`/register`)
Display name, email, password, password again. One line on what the account is for. After sign-up the user lands on the empty home screen; no onboarding tour.

### A3. Reset password (`/forgot`)
Email, send. Then one line: check your email. The email link opens a screen with new password and confirm.

## B. The plan (three tabs: Home, Gifts, Meals; settings reached from Home)

### B1. Home (`/home`)
The current year's plan. In this order of importance:

1. The ordering date. Before it: the date and the number of days until it. **verbatim:** Start ordering by 26 November. On or after it, lead with the count instead: **verbatim:** 3 gifts still need ordering. and a way straight to them (B4 filtered, or the recipients that hold them). When nothing is To Buy, say so once and show the date quietly.
2. Days to Christmas, small.
3. Gift money: budget, spent, remaining across all recipients, with one bar. Tapping the budget figure edits it in place or in a sheet.
4. Meal money: the two meal budgets added together, spent, remaining, one bar.
5. Gift count: purchased out of planned, across all recipients.
6. A way to open a previous year, read-only, if one exists. Small, at the bottom.

Settings icon in the header.

### B2. Gifts: the people (`/gifts`)
A list of recipients. Each row: name, remaining out of budget (principle 1), gifts purchased out of planned, and, on or after the ordering date, how many of their gifts still need ordering. Over budget is visible on the row. Add recipient is the primary action. Empty state: **verbatim:** Add the first person you are buying for.

### B3. Recipient (`/gifts/:recipientId`)
Header: name, budget, spent, remaining, one bar. Edit and delete the person from here (delete asks once and says the gifts go with them). Below: the gifts, each row with name, price, store or link if set, status, and a one-tap way to move the status forward. A gift still To Buy on or after the ordering date is marked. Add gift is the primary action. Empty state: **verbatim:** No gifts yet for {name}.

### B4. Gift (`/gifts/:recipientId/gift/:giftId`) and gift form
Name, price, store or link, status as a three-step control, and the dates: ordered on, purchased on (shown once set, stamped automatically on status change, editable). The form is the same whether adding or editing; a sheet from the bottom on phone, a dialog on laptop. Delete from the gift screen.

### B5. Meals (`/meals`)
Exactly two rows, Christmas Eve and Christmas Day, no add and no delete. Each row: name, guest count, remaining out of budget, items purchased out of planned, one bar. A meal with no budget set yet says so and invites setting it.

### B6. Meal (`/meals/:mealId`)
Header: name (fixed), guest count, budget, spent, remaining, one bar; edit guest count and budget from here. Below: the menu items, each row with name, cost, status, one-tap status forward. Add item is the primary action. Empty state: **verbatim:** Nothing on the menu yet.

### B7. Menu item form
Name, cost, status as a two-step control. Sheet on phone, dialog on laptop. Delete from the form when editing.

### B8. Settings (`/settings`)
Display name, currency, default shipping days (whole number, 0 to 60) with one line explaining it moves the ordering date. Sign out. Delete account, which asks once and names what is deleted: **verbatim:** This deletes your account and every plan, person, gift and meal in it. Theme: follow system, light, dark.

## C. Flows to design end to end

1. **First ten minutes.** Sign up, land on empty Home, add a recipient with a budget, add two gifts, come back to Home and see money and the ordering date reflect them.
2. **In a shop.** Open Gifts, open a person, see remaining, mark one gift Purchased in one tap, watch remaining and the count update.
3. **The date arrives.** Home on 26 November with three gifts still To Buy across two people: what the user sees, how they reach each gift, what Home looks like after they order them.
4. **Meal week.** Open Meals, set Christmas Day's guest count and budget, add four items, mark two Purchased.
5. **Over budget.** A person whose planned gifts exceed their budget, then one whose spent exceeds it; and Home when gifts overall are over.
6. **Next year.** Home in October 2027 with an empty 2027 plan and 2026 reachable read-only.
