# Constraints

## What the design may not decide

- Nothing that adds a feature outside `../../PRD.md`: no calendar, no shopping list, no wish lists, no more than three gift states or two menu-item states, no meals beyond the fixed two, no decorations or activities budgets. If a screen seems to need one, say so in the paragraph for that screen and design without it.
- No change to the business rules: what counts as spent, how the ordering date is computed, 10 December as the target.
- No change to the **verbatim** sentences in `03-screens-and-flows.md`. Present them; do not rewrite them.
- No onboarding tour, no tips, no celebratory animations.
- No illustration or imagery that depends on an asset we would have to source; icons from the Material Symbols set only.

## Technical

- Flutter 3.47, Material 3. Components are Material widgets or compositions of them; a design that needs a custom-drawn control should say so and justify it.
- Phone width 390 px is the primary design size; must also work at 360 px. Laptop at 1280 px. No horizontal scroll at any width.
- Light and dark from one `ColorScheme` each; colours expressed as Material roles (primary, secondary, tertiary, surface and their containers, error) so they map straight into `ThemeData`. A seed colour plus explicit overrides is ideal.
- Fonts from Google Fonts; at most one display face and one text face. Tabular figures for money.
- Accessible: 4.5:1 contrast for text, 3:1 for the budget bar against its track, visible focus on laptop, every control at least 44 px tall on phone, every icon-only button with a label. Must survive 130 percent text scaling without clipping money.
- Navigation: three tabs on phone (bottom), the same three as a rail or top tabs on laptop. Detail screens push on top of their tab.

## Component set to design

Button (primary, secondary, danger, text), Input (text, money, whole number, email, password with reveal), Money triple (budget, spent, remaining with one bar; compact row form and large header form), Status stepper (three states for gifts, two for menu items; list-row form and form-control form), Recipient row, Gift row, Meal row, Menu item row, Ordering-date banner (before, on, after), Needs-ordering marker on a row, Sheet (phone) and Dialog (laptop) for forms, Confirm (one line, one danger action), Empty state, Tab bar and rail, Year switcher (small), Theme toggle.
