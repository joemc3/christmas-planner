# Design brief for Christmas Planner

This folder is the complete input for a design session in Claude Design. Read the five numbered files in order. They are the only source of truth; the current app, shown in `05-current-ui.md` and `../../screenshots/`, is inventory, not a starting point.

What we want back, placed in `../output/`:

1. A design system: palette for light and dark, type scale and fonts, spacing, radius, and the component set listed in `04-constraints.md`. Flutter Material 3 is the toolkit, so express colours as a seed and role overrides where possible, and fonts as Google Fonts names.
2. Screens for every item in `03-screens-and-flows.md`, at phone width (390 px) and laptop width (1280 px), in light and dark.
3. For each screen, one paragraph on why it looks the way it does and which principle from `02-principles.md` it serves.
4. Empty, loading and error states for every list screen.

What the design may not do is in `04-constraints.md`. Sentences marked **verbatim** in `03-screens-and-flows.md` must appear exactly as written; everything around them is yours.

The output is a proposal. It will be reviewed against `../../PRD.md` screen by screen, and the decisions recorded in `../decisions.md`, before anything is built.
