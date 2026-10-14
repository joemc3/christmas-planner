// Browser smoke test: drives the built web app against a local Supabase
// stack through Flutter's accessibility tree and screenshots every screen.
// `make smoke` runs it; by hand:
//
//   make db
//   make build
//   (cd build/web && python3 -m http.server 8099) &
//   cd tool/e2e && npm install && OUT_DIR=../../docs/screenshots node smoke.mjs
//
// Covers the brief's flows C1 (first open), C2 (in a shop, one tap to
// Purchased with Undo), C4 (meal week) and C5 (over budget), at phone width,
// then Home, Gifts and Meals at laptop width. C3 (the ordering date arriving)
// and C6 (next year) depend on today's date and are covered by unit tests
// of the Home view model instead.
//
// Uses full Chromium ("channel: 'chromium'"): the headless shell crashes the
// Flutter engine on locale detection. Fails loudly with failure.png and a
// dump of the semantics tree if a step cannot find its control.
import { chromium } from 'playwright';
import fs from 'node:fs';

const BASE = process.env.APP_URL || 'http://127.0.0.1:8099';
const OUT = process.env.OUT_DIR || 'screenshots';
const email = `planner+${Date.now()}@example.com`;
const password = 'mistletoe-2026';
fs.mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({
  args: ['--no-sandbox', '--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--use-gl=angle', '--ignore-gpu-blocklist'],
  channel: 'chromium',
});
let ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, ignoreHTTPSErrors: true });
let page = await ctx.newPage();
const logs = [];
page.on('console', m => logs.push(`[${m.type()}] ${m.text()}`));
page.on('pageerror', e => logs.push(`[pageerror] ${e.message}`));

const shot = async (name) => { await page.waitForTimeout(700); await page.screenshot({ path: `${OUT}/${name}.png` }); console.log('shot', name); };

// Flutter web renders to canvas; use the accessibility tree via semantics.
const enableSemantics = async () => {
  const btn = page.locator('flt-semantics-placeholder');
  if (await btn.count()) { await btn.first().evaluate(el => el.click()).catch(() => {}); }
};
// Flutter web exposes a node's label as aria-label; a row that merges its
// texts carries a multi-line label on the tappable node. Look up by role
// and accessible name first, then by label, then by text content.
const esc = (s) => s.replace(/["\\]/g, '\\$&');
const find = async (label) => {
  for (const role of ['button', 'tab', 'link']) {
    const r = page.getByRole(role, { name: label, exact: true });
    if (await r.count()) return r.last();
  }
  const exact = page.locator(`flt-semantics[aria-label="${esc(label)}"]`);
  if (await exact.count()) return exact.last();
  const prefix = page.locator(`flt-semantics[aria-label^="${esc(label)}"]`);
  if (await prefix.count()) return prefix.first();
  const text = page.locator(`flt-semantics:text-is("${esc(label)}")`);
  if (await text.count()) return text.last();
  const contains = page.locator(`flt-semantics[aria-label*="${esc(label)}"]`);
  if (await contains.count()) return contains.first();
  const hasText = page.locator('flt-semantics').filter({ hasText: label });
  if (await hasText.count()) {
    const lengths = await hasText.evaluateAll(els => els.map(e => e.textContent.length));
    let best = 0; lengths.forEach((l, i) => { if (l < lengths[best]) best = i; });
    return hasText.nth(best);
  }
  throw new Error(`no semantics node for "${label}"`);
};
const click = async (label) => { await (await find(label)).click({ timeout: 15000 }); await page.waitForTimeout(450); };
const clickButton = click;
// Labels sit above fields and are merged into the input's accessible name,
// which may carry the hint too, so match exact first, then prefix.
const type = async (label, text) => {
  let el = page.locator(`input[aria-label="${esc(label)}"], textarea[aria-label="${esc(label)}"]`).first();
  if (!(await el.count())) el = page.locator(`input[aria-label^="${esc(label)}"], textarea[aria-label^="${esc(label)}"]`).first();
  if (!(await el.count())) {
    const info = await page.evaluate(() => ({ inputs: [...document.querySelectorAll('input,textarea')].map(i => i.getAttribute('aria-label')) }));
    console.log('type-miss', label, JSON.stringify(info));
    await enableSemantics(); await page.waitForTimeout(1500);
  }
  await el.click({ timeout: 15000 }); await page.waitForTimeout(250);
  // Flutter swaps the DOM input on focus, so type via the keyboard.
  // Select whatever is there without a platform modifier, then type.
  await page.keyboard.press('End'); await page.keyboard.press('Shift+Home'); await page.keyboard.press('Backspace');
  await page.keyboard.type(text, { delay: 30 }); await page.waitForTimeout(150);
};

try {
  await page.goto(BASE, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500);
  await enableSemantics();
  await page.waitForTimeout(1500);
  await shot('01-sign-in');

  // A2: create an account, land on the empty Home.
  await click('Create an account');
  await shot('02-create-account');
  await type('Your name', 'Jo Planner');
  await type('Email', email);
  await type('Password', password);
  await type('Password again', password);
  await clickButton('Create account');
  await page.waitForTimeout(3000);
  await shot('03-home-first-open');

  // C1: set the gift budget from Home.
  await clickButton('Set budget');
  await type('Budget for all gifts', '600');
  await clickButton('Save');
  await page.waitForTimeout(800);

  // B2: the people.
  await click('Gifts');
  await shot('04-gifts-empty');
  await clickButton('Add person');
  await shot('05-add-person');
  await type('Name', 'Mum');
  await type('Budget', '150');
  await clickButton('Add person');
  await page.waitForTimeout(800);
  await clickButton('Add person');
  await type('Name', 'Dad');
  await type('Budget', '120');
  await clickButton('Add person');
  await page.waitForTimeout(800);
  await shot('06-gifts');

  // B3, B4: Mum's gifts: one Ordered, one To Buy, planned over budget (C5).
  await click('Mum');
  await shot('07-recipient-empty');
  await clickButton('Add gift');
  await type('Name', 'Espresso machine');
  await type('Price', '129');
  await type('Store or link', 'John Lewis');
  await click('Ordered');
  await shot('08-add-gift');
  await clickButton('Add gift');
  await page.waitForTimeout(800);
  await clickButton('Add gift');
  await type('Name', 'Signed hardback');
  await type('Price', '24.99');
  await type('Store or link', 'Waterstones');
  await clickButton('Add gift');
  await page.waitForTimeout(800);
  await shot('09-recipient-planned-over');
  await click('Espresso machine');
  await shot('10-gift');
  await clickButton('Back');
  await page.waitForTimeout(600);

  // C2: in a shop with Dad: one tap to Purchased, Undo offered.
  await clickButton('Back');
  await page.waitForTimeout(600);
  await click('Dad');
  await clickButton('Add gift');
  await type('Name', 'Wool socks');
  await type('Price', '18');
  await clickButton('Add gift');
  await page.waitForTimeout(800);
  await clickButton('Mark Purchased');
  await page.waitForTimeout(600);
  await shot('11-recipient-one-tap-purchased');
  // With semantics on, Flutter keeps a snackbar that has an action; close it.
  await clickButton('Close');
  await clickButton('Back');
  await page.waitForTimeout(600);
  await shot('12-gifts-list');

  // C4: meal week.
  await click('Meals');
  await shot('13-meals-no-budgets');
  await click('Christmas Day');
  await shot('14-meal-empty');
  await clickButton('Edit guests and budget');
  await type('Guests', '8');
  await type('Budget', '220');
  await clickButton('Save');
  await page.waitForTimeout(800);
  await clickButton('Add item');
  await type('Name', 'Turkey crown');
  await type('Cost', '64');
  await clickButton('Add item');
  await page.waitForTimeout(800);
  await clickButton('Add item');
  await type('Name', 'Pigs in blankets');
  await type('Cost', '12');
  await clickButton('Add item');
  await page.waitForTimeout(800);
  await clickButton('Mark Purchased');
  await page.waitForTimeout(600);
  await shot('15-meal');
  await clickButton('Close');
  await clickButton('Back');
  await page.waitForTimeout(600);
  await shot('16-meals');

  // Home with money, before the date.
  await click('Home');
  await page.waitForTimeout(800);
  await shot('17-home');

  // B8: settings, then dark theme on Home.
  await clickButton('Settings');
  await shot('18-settings');
  await click('Dark');
  await page.waitForTimeout(500);
  await clickButton('Back');
  await page.waitForTimeout(800);
  await shot('19-home-dark');
  await clickButton('Settings');
  await click('System');
  await clickButton('Back');
  await page.waitForTimeout(600);

  // Laptop width: a fresh window at 1280 px, signed in to the same account
  // (A1), with the rail and list plus detail.
  await ctx.close();
  ctx = await browser.newContext({ viewport: { width: 1280, height: 800 }, deviceScaleFactor: 2, ignoreHTTPSErrors: true });
  page = await ctx.newPage();
  page.on('console', m => logs.push(`[${m.type()}] ${m.text()}`));
  await page.goto(BASE, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500);
  await enableSemantics();
  await page.waitForTimeout(1500);
  await type('Email', email);
  await type('Password', password);
  await clickButton('Sign in');
  await page.waitForTimeout(3000);
  await shot('20-laptop-home');
  // Known issue: the NavigationRail has no semantics nodes in the web build
  // (Flutter 3.47.7), so the rail cannot be driven through the accessibility
  // tree; the tabs are reached by URL here. See docs/design/decisions.md.
  await page.goto(`${BASE}/#/gifts`); await page.waitForTimeout(1500);
  await click('Mum');
  await page.waitForTimeout(800);
  await shot('21-laptop-gifts');
  await page.goto(`${BASE}/#/meals`); await page.waitForTimeout(1500);
  await click('Christmas Day');
  await page.waitForTimeout(800);
  await shot('22-laptop-meals');

  console.log('DONE', email);
} catch (err) {
  console.error('FAILED', err.message);
  await page.screenshot({ path: `${OUT}/failure.png` }).catch(() => {});
  const sem = await page.evaluate(() => [...document.querySelectorAll('flt-semantics')].map(e => `${e.getAttribute('role') || ''}|${e.getAttribute('aria-label') || ''}|${e.children.length ? '' : e.textContent.trim().replace(/\s+/g, ' ').slice(0, 60)}`).filter(x => x !== '||').slice(0, 150));
  console.error('semantics:', JSON.stringify(sem, null, 1));
  console.error('logs:', logs.slice(-40).join('\n'));
  process.exitCode = 1;
} finally {
  await browser.close();
}
