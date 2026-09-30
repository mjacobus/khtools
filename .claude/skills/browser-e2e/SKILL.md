---
name: browser-e2e
description: Use when a change touches UI/UX and needs proof in the real running app — drive a headless browser (Playwright) against the khtools dev server, assert UI and DB state, and capture screenshots for the PR body. Complements RSpec; it does not replace it.
---

# Browser E2E — Headless Playwright Against the Running App

Request/component specs prove pieces in isolation. This skill proves the whole path: a real browser logs in, navigates, and we assert what the user sees **and** what landed in the database. It also produces the **screenshots every UX-changing PR must include**.

Write the RSpec specs first (they gate the PR). Run the browser E2E as the final pass.

## When to use

- The PR changes a page, form, list, menu, or any other visible behavior → **always** attach screenshots.
- You want proof a form persists correctly through the real stack.

For pure logic, stick to RSpec.

## Prerequisites

- **Node** isn't on the default PATH; use mise's: `~/.local/share/mise/installs/node/lts/bin/node`.
- **Playwright** isn't a project dependency. Install it once into the gitignored harness dir:
  ```bash
  mkdir -p tmp/e2e && cd tmp/e2e && npm init -y && npm i playwright
  ```
  Chromium builds are cached under `~/.cache/ms-playwright`. If the installed Playwright wants a revision that isn't there, run `npx playwright install chromium`.
- **Dev server** on port **3002** (3000/3001 are usually taken by other projects):
  ```bash
  bin/rails db:migrate
  bin/rails s -p 3002 -P tmp/pids/e2e.pid > tmp/e2e/server.log 2>&1 &
  until curl -s localhost:3002/up | grep -q OK; do sleep 1; done
  ```
  Restart it after switching branches.
- **Login**: `GET /dev/login?id=<user_id>` (development only) sets the session. No OAuth needed.

## Harness layout

Everything under `tmp/e2e/` (gitignored). Only screenshots get committed.

```
tmp/e2e/
  <feat>_setup.rb     # rails runner — create fictitious data, write state.json
  <feat>_state.json   # ids handed to the driver
  <feat>_run.js       # Playwright — login, navigate, assert UI + DB, screenshot
  screenshots/        # raw output; copy keepers to docs/screenshots/<pr>-<feature>/
```

### Setup (`bin/rails runner tmp/e2e/<feat>_setup.rb`)

**The repo is public — screenshots must only show fictitious data.** Never log in as a real dev-DB user; create a fresh account tagged with a random suffix:

```ruby
require 'json'

tag = SecureRandom.hex(3)
account = Db::Account.create!(congregation_name: "Congregação Exemplo #{tag}")
avatar = 'https://www.gravatar.com/avatar/?d=mp' # the sidebar 500s on users without an avatar
admin = User.create!(name: 'Admin Exemplo', email: "admin-#{tag}@example.com", account:, avatar:,
                     master: true, enabled: true, oauth_provider: 'e2e', oauth_uid: "admin-#{tag}")
group = Db::FieldServiceGroup.create!(name: 'Grupo Centro', account:)
publisher = Db::Publisher.create!(name: 'Ana Souza', gender: 'f', group:, account:)

File.write('tmp/e2e/<feat>_state.json', JSON.pretty_generate(tag:, admin_id: admin.id, publisher_id: publisher.id))
```

A `master` user skips the controller ACL. To check what a regular user sees, create a non-master user and call `grant_controller_access('congregation/publishers')` on it before saving.

### Driver (`NODE_PATH=tmp/e2e/node_modules ~/.local/share/mise/installs/node/lts/bin/node tmp/e2e/<feat>_run.js`)

```js
const { chromium } = require('playwright');
const fs = require('fs');
const { execSync } = require('child_process');

const BASE = 'http://localhost:3002';
const st = JSON.parse(fs.readFileSync('tmp/e2e/<feat>_state.json', 'utf8'));
const log = (m) => console.log(`[E2E] ${m}`);
const sh = (cmd) => execSync(cmd, { encoding: 'utf8' }).trim();
const assert = (label, cond) => {
  if (cond) log(`✓ ${label}`);
  else { log(`✗ FAIL: ${label}`); process.exitCode = 1; }
};
// DB is the source of truth. endsWith: rails runner may print warnings first.
const dbBool = (rubyExpr) => sh(`bin/rails runner 'print (${rubyExpr})'`).endsWith('true');

(async () => {
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await (await browser.newContext({ viewport: { width: 1280, height: 900 } })).newPage();
    page.on('console', (m) => m.type() === 'error' && log(`console.error: ${m.text().slice(0, 120)}`));

    await page.goto(`${BASE}/dev/login?id=${st.admin_id}`);
    await page.goto(`${BASE}/congregation/publishers/${st.publisher_id}/edit`);
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'tmp/e2e/screenshots/<feat>-form.png', fullPage: true });

    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);
    assert('persisted', dbBool(`Db::Publisher.find(${st.publisher_id}).name == "Ana Souza"`));
  } finally {
    await browser.close();
  }
})().catch((e) => { console.error('[E2E] FATAL:', e); process.exit(1); });
```

The app uses simple_form, so field names follow `model[attribute]`, for example `select[name="publisher[user_id]"]`.

## Screenshots in the PR

1. **Look at every screenshot** (Read the PNG) before committing it. Confirm it shows the change and no real data.
2. Commit the keepers to `docs/screenshots/<pr>-<feature>/`. The PR number in the path keeps PRs from colliding.
3. Reference them in the PR body by **commit SHA**, not branch name. Branches are deleted on merge and branch URLs would break:
   `https://raw.githubusercontent.com/mjacobus/khtools/<sha>/docs/screenshots/<pr>-<feature>/<file>.png`
4. Add a "Screenshots" section before "Test plan", and a Test plan line describing the Playwright run.

## Checks

- `grep -c "Completed 500" tmp/e2e/server.log` should not grow during the run.
- A `console.error` 400 from gravatar (the sidebar appends `?sz=`) is harmless.

## Cleanup

Stop the server with `kill $(cat tmp/pids/e2e.pid)`. E2E records stay in the dev DB, tagged `Exemplo <tag>`. They're harmless.
