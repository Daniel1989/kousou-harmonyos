# Kousou User Stories And Test Log

Last updated: 2026-06-04

## Current User Stories

1. Login gate and compliance
   - As a new or logged-out user, I am routed to the standalone Login page before entering the app.
   - As a user, I must agree to the privacy policy and service agreement through the bottom compliance dialog before continuing.
   - As a user, I can open the privacy policy and service agreement from the compliance dialog and return to login.
   - As a logged-in user, Launch routes me into the app home without showing the login gate.

2. Huawei account and sync
   - As a user, I can log in with Huawei ID and the app stores my app user ID, Huawei account identifiers, nickname, email if available, token, and expiration.
   - As a logged-in user, I see a friendly Huawei account label in Settings and on the account page.
   - As a logged-in user, I can save my display nickname and log out.
   - As a logged-out user, app entry redirects back to the login gate.

3. Home and receipt recognition
   - As a logged-in user, I can see today's spending and income totals.
   - As a user, I can expand and collapse recent bills, and long lists load more as I scroll.
   - As a logged-in user, I can tap Recognize Image from Home, pick an image, and see recognized receipt items or a clear failure toast without crashing.
   - As a logged-in user, I can batch-save recognized receipt items.

4. Manual accounting
   - As a user, I can open the accounting page, switch between expense and income, select a category, input an amount with the custom keyboard, add a note, and save.
   - As a logged-in user, saving a record writes locally and submits to the service.
   - As a logged-in user, Home totals refresh after returning from accounting.

5. Statistics
   - As a user, I can view monthly spending, income, balance, record count, trends, charts, and category ranking.
   - As a user, I can change month and cannot move into a future month.
   - As a logged-in user, I can request AI statistics advice and see returned tips.
   - As a user, I see clear empty states when a chart or category ranking has no data.

6. Wishlist
   - As a logged-in user, I can create or edit a wishlist goal with type, title, target amount, monthly income, and note.
   - As a logged-in user, I can request AI analysis for a goal and see streaming or fallback analysis.
   - As a logged-in user, I can abandon a goal.
   - As a logged-out user, the app routes to login instead of exposing goal management.

7. Settings
   - As a logged-in user, I can open account management, privacy policy, service agreement, and category management from Settings.
   - As a tester, I can tap the version number six times to reveal hidden server host settings, save a custom host, or restore the default host.

8. Category management
   - As a logged-in user, I can manage expense and income categories on an independent page.
   - As a user, the category page starts with the category type I came from, and only shows categories of the selected type.
   - As a user, I can add a category, select an icon, edit an existing custom category, and delete a custom category.
   - As a user, default categories are visible but cannot be modified or deleted.

## Test Matrix For Current Build

1. Build and deploy
   - Build HAP with `hvigorw assembleHap --mode module -p product=default --no-daemon`.
   - Sign latest unsigned HAP with the `sharedDebug` profile.
   - Install on device `192.168.1.116:41885`.

2. UITest coverage
   - Capture Login or Home after launch.
   - Capture Home, Accounting, Statistics, Wishlist, Settings.
   - From Settings, capture Account, Privacy, Terms, Category Management.
   - On Category Management, verify expense tab does not show income category names, then switch to income and verify income names are visible.
   - Reveal hidden debug settings by tapping version six times.
   - Use layout JSON to record coordinates and visible text for every tested state.

3. Log coverage
   - Capture app console/runtime logs through `hdc hilog`.
   - During launch and navigation, check for `JsError`, `CRASH`, `FATAL`, and app `console.error`.
   - During server-backed flows, record whether logs show sync/API failures such as `[ServerSync]`, `[RdbInfo]`, `[Login]`, `[CategoryManage]`, or HTTP request errors.

## Issues Found And Fixed

1. Home action buttons overlapped the Home Scroll hit area.
   - Symptom: center taps on Recognize Image or Parse Text could be consumed by the Scroll.
   - Fix: constrained the Home page builder into a weighted Column and made the Home Scroll fill its parent.
   - Files: `entry/src/main/ets/pages/Index.ets`, `entry/src/main/ets/pages/components/Home.ets`.

2. Parsed amount did not appear on the keyboard.
   - Symptom: Parse Text navigated to the accounting page, but the keyboard still displayed `0`.
   - Fix: synced `parsedAmount` into `totalValue` on keyboard appearance and on link changes; save now uses the visible keyboard value.
   - File: `entry/src/main/ets/pages/components/MyKeyboard.ets`.

3. Statistics AI endpoint returned 405.
   - Symptom: app POST to `/v1/kousou/statistics/analyze` returned `RespCode:405`.
   - Root cause: server `analyze_statistics()` reused the GET-only `statistics(request)` view with a POST request.
   - Fix: extracted shared statistics payload calculation and reused it from both views.
   - Files: `/Users/caoxiaopeng/DevEcoStudioProjects/bitstripe/kousou/views.py`, `/Users/caoxiaopeng/DevEcoStudioProjects/bitstripe/kousou/tests.py`.

4. UI review issues from 2026-06-03.
   - Symptom: Settings account row, login page, category page, privacy/terms, navigation contrast, and empty states were inconsistent.
   - Fix: moved category management to an independent page, aligned Settings rows, added account page, showed Huawei nickname, added return buttons, filtered category lists by type, improved labels and contrast.
   - Files: `Index.ets`, `Login.ets`, `CategoryManage.ets`, `Settings.ets`, `Privacy.ets`, `Terms.ets`, `Statistics.ets`, `Wishlist.ets`.

5. Current user-story retest found Category Management icon-only items.
   - Symptom: Category Management showed category icons but no category names, so users could not confidently identify or edit a specific category.
   - Fix: added text labels under every category icon and under the add tile.
   - File: `entry/src/main/ets/pages/CategoryManage.ets`.

6. Current user-story retest found Account page content vertically centered too low.
   - Symptom: the account card started far below the `账号与同步` title, creating a large empty area in the first viewport.
   - Fix: forced the account page scroll content to top-align within the viewport.
   - File: `entry/src/main/ets/pages/Login.ets`.

## Verification Evidence

1. Prior verification
   - Earlier build/deploy/user-flow verification is preserved in screenshot directories under `screenshots/`.
   - Previous full UI review: `screenshots/full-ui-review-20260603-002320/ui-review.md`.
   - Previous UI fixes verification: `screenshots/ui-fixes-verify-20260603-003332/`.

2. Current verification
   - Run directory: `screenshots/user-story-verify-20260604-002826/`.
   - Final contact sheet: `screenshots/user-story-verify-20260604-002826/contact-sheet-final.png`.
   - Hilog capture: `screenshots/user-story-verify-20260604-002826/hilog-user-story.log`.
   - Build command: `/Users/caoxiaopeng/service/command-line-tools/bin/hvigorw assembleHap --mode module -p product=default --no-daemon`.
   - Build result: `BUILD SUCCESSFUL`.
   - Signed HAPs:
     - `entry/build/default/outputs/default/entry-default-user-story-verify-signed.hap`
     - `entry/build/default/outputs/default/entry-default-user-story-verify-fix2-signed.hap`
   - Device: `192.168.1.116:41885`.
   - Install result: `install bundle successfully`.

3. Current UITest evidence
   - `01-home.json`: Home showed `今天`, `今日支出`, `识别图片`, `展示最近账单`.
   - `02-money.json`: Accounting showed expense/income toggle, `新增分类`, category grid, note field, custom keyboard, and `完成`.
   - `03-statistics.json`: Statistics showed monthly totals, `生成 AI 统计建议`, chart tabs, and empty-state text.
   - `04-wishlist.json`: Wishlist showed type tabs and fixed labels `目标名称`, `目标金额`, `月收入`, `备注`.
   - `05-settings.json`: Settings showed account, privacy, terms, category management, and version rows.
   - `07-privacy.json` and `08-terms.json`: both showed visible back button `‹` and section headings.
   - `10-settings-hidden.json`: six version taps revealed `调试设置`, server host input, `保存`, and `恢复线上`.
   - `09-category-cost.json`: expense category page showed no income category names.
   - `12-category-income-retry.json`: income category page showed 13 category image items.
   - `14-category-labels.json`: category management showed text labels including `新增`, `餐饮`, `水果`, `蔬菜`, `饮料`, `冰淇淋`.
   - `13-account-fix.json`: account content started near the title, with `华为账号已登录`, nickname, display-name field, save button, and logout button visible.

4. Current log evidence
   - Hilog capture was saved at `screenshots/user-story-verify-20260604-002826/hilog-user-story.log`.
   - No app-bundle log lines, `JsError`, `CRASH`, `FATAL`, or app marker errors were found during the final pass.
   - The captured error lines were unrelated system-service noise from Huawei Wallet/MMS/light sensor components, not `com.example.my_account`.
