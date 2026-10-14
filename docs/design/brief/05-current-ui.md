# The current UI, for inventory only

Screenshots in `../../screenshots/`, taken October 2026 at phone width by the browser smoke test. None of it should be kept for its own sake.

The current look is a palette the first build named "Frosted Hearth": a cream background, deep teal-navy, burnt orange, pale gold, a berry red for over-budget, serif display and text faces (Fraunces, Source Serif 4) and a monospace (DM Mono) for buttons. Every screen is a title, a summary card, a list of rounded white cards and an orange floating action button, with a floating dark pill tab bar at the bottom. It is coherent but generic: nothing on any screen says what matters today, and the ordering date is one card among several on the dashboard.

Screens that exist today, with which brief screen they map to:

| Today | Screenshot | Becomes |
|---|---|---|
| Login | `login.png` | A1 |
| Register | (not captured) | A2 |
| Dashboard: greeting, days to Christmas, days to 10 Dec, last-day-to-order card, gift budget bar, quick actions, recent gifts | `dashboard.png` | B1, reorganised around the date |
| Gifts: budget / planned / bought strip, recipient rows | `gifts.png` | B2 |
| Recipient: avatar, interest chips, four money figures, gift rows | `recipient.png` | B3, without chips |
| Recipient form | `recipient-form.png` | reduced to name and budget |
| Gift detail with five-step status stepper | `gift-detail.png` | B4 with three steps |
| Meals: list of meals including "other" | `meals.png` | B5, fixed two |
| Meal detail: guests / budget / planned / spent, menu grouped by course, prep time | `meal-detail.png` | B6, flat menu |
| Budget: yearly allocations with stacked bar | `budget.png` | removed; gift budget edited from B1 |
| Calendar | `calendar.png` | removed |
| Shopping lists | `shopping.png` | removed |
| Settings: name, currency, shipping days, sign out, delete | `settings.png` | B8 plus theme |

Components that exist and will be rebuilt to the new system: FormSheet (bottom sheet form), FrostedCard, FrostedButton, confirm dialog, MainShell (tab bar).
