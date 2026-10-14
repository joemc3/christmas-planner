// Browser smoke test: drives the built web app against a local Supabase
// stack through Flutter's accessibility tree and screenshots each screen.
//
//   supabase start
//   flutter build web --release --no-web-resources-cdn \
//     --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
//     --dart-define=SUPABASE_ANON_KEY=<anon key from supabase status>
//   (cd build/web && python3 -m http.server 8099) &
//   cd tool/e2e && npm install && OUT_DIR=../../docs/screenshots node smoke.mjs
//
// Uses full Chromium ("channel: 'chromium'"): the headless shell crashes the
// Flutter engine on locale detection. Fails loudly with failure.png and a dump
// of the semantics tree if a step cannot find its control.
import { chromium } from 'playwright';
import fs from 'node:fs';

const BASE = process.env.APP_URL || 'http://127.0.0.1:8099';
const OUT = process.env.OUT_DIR || 'screenshots';
const email = `planner+${Date.now()}@example.com`;
const password = 'Mistletoe!2026';
fs.mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({ args: ['--no-sandbox', '--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--use-gl=angle', '--ignore-gpu-blocklist'], channel: 'chromium' });
const ctx = await browser.newContext({ viewport: { width: 430, height: 900 }, deviceScaleFactor: 2, ignoreHTTPSErrors: true });
const page = await ctx.newPage();
const logs = [];
page.on('console', m => logs.push(`[${m.type()}] ${m.text()}`));
page.on('pageerror', e => logs.push(`[pageerror] ${e.message}`));

const shot = async (name) => { await page.waitForTimeout(600); await page.screenshot({ path: `${OUT}/${name}.png` }); console.log('shot', name); };
// Flutter web renders to canvas; use the accessibility tree via semantics.
const enableSemantics = async () => {
  const btn = page.locator('flt-semantics-placeholder');
  if (await btn.count()) { await btn.first().evaluate(el => el.click()).catch(() => {}); }
};
const byLabel = (label) => page.locator(`flt-semantics:text-is("${label}")`).last();
// Tiles merge their children into one semantics node, so fall back to the
// smallest node containing the text.
const byText = async (label) => {
  const exact = byLabel(label);
  if (await exact.count()) return exact;
  const all = page.locator('flt-semantics').filter({ hasText: label });
  const lengths = await all.evaluateAll(els => els.map(e => e.textContent.length));
  let best = 0; lengths.forEach((l, i) => { if (l < lengths[best]) best = i; });
  return all.nth(best);
};
const click = async (label) => { await (await byText(label)).click({ timeout: 15000 }); await page.waitForTimeout(400); };
const type = async (label, text) => {
  const el = page.locator(`input[aria-label="${label}"], textarea[aria-label="${label}"]`).first();
  if (!(await el.count())) {
    const info = await page.evaluate(() => ({ inputs: [...document.querySelectorAll('input,textarea')].map(i => i.getAttribute('aria-label')), placeholder: document.querySelectorAll('flt-semantics-placeholder').length, sem: document.querySelectorAll('flt-semantics').length }));
    console.log('type-miss', label, JSON.stringify(info));
    await enableSemantics(); await page.waitForTimeout(1500);
  }
  await el.click({ timeout: 15000 }); await page.waitForTimeout(250);
  // Flutter swaps the DOM input on focus, so type via the keyboard instead of re-locating.
  await page.keyboard.press('Control+A'); await page.keyboard.type(text, { delay: 10 }); await page.waitForTimeout(150);
};

try {
await page.goto(BASE, { waitUntil: 'networkidle' });
await page.waitForTimeout(7000);
await enableSemantics();
await page.waitForTimeout(1500);
await shot('01-login');

// Register
await click('Sign Up');
await page.waitForTimeout(1500);
await shot('02-register');
await type('Full Name', 'Jo Planner');
await type('Email', email);
await type('Password', password);
await type('Confirm Password', password);
await page.locator('flt-semantics[role="checkbox"]').first().click();
await page.waitForTimeout(300);
await click('Create Account');
await page.waitForTimeout(5000);
await shot('03-dashboard-empty');

// Gifts: add recipient
await click('Gifts');
await page.waitForTimeout(1500);
await shot('04-gifts-empty');
await click('Add first recipient');
await page.waitForTimeout(1200);
await type('Name', 'Mum');
await type('Gift budget for this person', '150');
await type('Interests', 'Gardening, crime novels, good coffee');
await shot('05-recipient-form');
await click('Add recipient');
await page.waitForTimeout(3000);
await shot('06-recipient-empty');

// Add gifts
await click('Add gift');
await page.waitForTimeout(1200);
await type('Gift', 'Espresso machine');
await type('Planned price', '129');
await type('Store', 'John Lewis');
await shot('07-gift-form');
await click('Add gift');
await page.waitForTimeout(2500);
await byLabel('Gift').last().click().catch(() => {}); // FAB "Gift"
await page.waitForTimeout(1200);
await type('Gift', 'Signed Val McDermid hardback');
await type('Planned price', '24.99');
await click('Add gift');
await page.waitForTimeout(5000);
await shot('08-recipient-with-gifts');

// Gift detail + status
await click('Espresso machine');
await page.waitForTimeout(2000);
// Status chips are exposed as unlabeled checkboxes in order of GiftStatus.
await page.locator('flt-semantics[role="checkbox"]').nth(1).click();
await page.waitForTimeout(2000);
await shot('09-gift-detail');

// Gifts list
await click('Gifts'); // tab
await page.waitForTimeout(1500);
await click('Gifts');
await page.waitForTimeout(1500);
await shot('10-gifts-list');

// Meals
await click('Meals');
await page.waitForTimeout(1500);
await shot('11-meals-empty');
await click('Plan Christmas Day lunch');
await page.waitForTimeout(1200);
await type('Guests', '8');
await type('Budget', '220');
await click('Add meal');
await page.waitForTimeout(3000);
await click('Add item');
await page.waitForTimeout(1200);
await type('Dish or ingredient', 'Roast turkey');
await type('Est. cost', '65');
await type('Prep (min)', '30');
await type('Cook (min)', '240');
await click('Add');
await page.waitForTimeout(2500);
await byLabel('Item').last().click().catch(() => {});
await page.waitForTimeout(1200);
await type('Dish or ingredient', 'Christmas pudding');
await type('Est. cost', '12');
await type('Who is bringing / making it', 'Auntie Sue');
await click('Add');
await page.waitForTimeout(5000);
await shot('12-meal-detail');

// Dashboard
await click('Home');
await page.waitForTimeout(2500);
await shot('13-dashboard');

// Shopping, calendar, budget, settings
await click('Shop');
await page.waitForTimeout(2500);
await shot('14-shopping');
await click('Events');
await page.waitForTimeout(2500);
await shot('15-calendar');
await click('Home');
await page.waitForTimeout(1500);
await click('Budget');
await page.waitForTimeout(3000);
await shot('16-budget');
await click('Back');
await page.waitForTimeout(1000);
await byLabel('Settings').click().catch(async () => { await page.locator('flt-semantics[role="button"]').first().click(); });
await page.waitForTimeout(2500);
await shot('17-settings');

} catch (e) {
  console.log('FAILED:', e.message.split('\n')[0]);
  await page.screenshot({ path: `${OUT}/failure.png` }).catch(() => {});
  const dump = await page.evaluate(() => [...document.querySelectorAll('flt-semantics')].filter(n => n.children.length === 0 || n.getAttribute('role')).map(n => `${n.getAttribute('role')||'-'}: ${n.textContent.trim().slice(0,60)}`).join('\n')).catch(() => '');
  fs.writeFileSync(`${OUT}/failure-semantics.txt`, dump);
}
fs.writeFileSync(`${OUT}/console.log`, logs.join('\n'));
await browser.close();
console.log('DONE', email);
