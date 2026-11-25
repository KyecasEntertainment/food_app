# Local Supabase transition plan

Status: core implementation in place, 2026-11-25. The running app uses Supabase when launched with the required Dart defines. `LocalDatabase` and `DemoAuth` remain as test fixtures. Existing demo records and avatars have not been imported into real Auth accounts.

## Target

Use the sibling `../food_app_supabase` project as the canonical local backend. Supabase Auth owns sign-in and user IDs. Postgres owns profiles, the catalog, carts, orders, and order lines. Supabase Storage serves food photos and user avatars. Flutter retains Dart models and bundles UI images, including category icons, branding, payment logos, delivery art, and the launcher icon. Payment choices and the delivery animation remain UI features for this transition; the app does not process payments.

## Baseline and implemented target

| Area | Current app | Target |
| --- | --- | --- |
| Auth | `DemoAuth` checks ten hardcoded passwords and demo UUIDs | Supabase email/password Auth; startup restores the session and logout signs out |
| Profile | `UserAccounts` is saved under `accounts_v1_<id>` | `profiles` row keyed by `auth.users.id`; address fields are flattened |
| Catalog | `product_list.dart` is returned by `LocalDatabase`; `photo` is a bundled asset path | Read seeded `food_items`; `photo` holds a Storage object key |
| Images | 25 food photos, 10 demo avatars, and 15 UI images are bundled | Upload food photos and mapped user avatars to Storage; keep all 15 UI images bundled |
| Cart | `cart_v1_<id>` in `SharedPreferences` | Add a per-user `cart_items` table and user-scoped policies |
| Orders | `orders_v1_<id>` contains client-created IDs, prices, and totals | Read `orders` with `order_items`; create both through one trusted database function |

The schema and seed in `../food_app_supabase/supabase/` are canonical. `food_app/supabase/migrations/` is a reference copy and should not receive new migrations. The existing `FoodRepository` interface is a useful boundary, but `saveOrder(FoodOrder)` cannot express a server-generated receipt and total. Replace that method with a create-order request containing item IDs and quantities, delivery address, tip, and an idempotency key, returning the saved order. Do not send an account ID, unit prices, delivery fee, or total as trusted inputs.

## Implementation sequence

1. **Establish a repeatable local connection.** Add `supabase_flutter`, initialize it before `runApp`, and configure the local API URL and publishable key through development build settings. Never ship the secret/service-role key in Flutter. Use `127.0.0.1:54321` on the host and `10.0.2.2:54321` on the Android emulator; document the reachable host URL for physical devices. Check Android Internet permission for release builds and platform rules for local HTTP. Confirm the stack applies the canonical migration and 25-item seed without a reset of any data that needs preserving.
2. **Complete the backend contract.** Add a migration for `cart_items` with `(account_id, item_id)` uniqueness, positive quantity, foreign keys, and policies limited to `auth.uid()`. Add a narrowly granted `place_order` database function that validates an authenticated user, nonempty unique item IDs, positive quantities, a complete address, and an allowed tip. It reads current `food_items` prices, calculates a server-defined delivery fee and total, then inserts the order and lines in one transaction. Return the persisted receipt. Add an idempotency key so a network retry cannot create a second order. Keep direct client order inserts disabled. For a privileged function, pin `search_path`, schema-qualify references, check ownership in the function, revoke default execution, and grant execution only to `authenticated`.
3. **Upload and serve food photos and avatars.** Add a migration that creates a public-read `food-photos` bucket for the 25 catalog photos and a private `user-avatars` bucket for account photos. Do not grant client writes to `food-photos`; a trusted local setup script uploads its files with stable object keys and correct MIME types. Run that script after initial `supabase start` and after any local database reset; SQL seed rows alone do not upload file bytes. Update the catalog seed so each `food_items.photo` stores its object key. Upload the 10 existing demo avatars to private per-user paths only after each demo profile has been mapped to a real Auth user; otherwise leave those files as migration inputs. Give authenticated users `SELECT`, `INSERT`, `UPDATE`, and `DELETE` access only within their own `user-avatars/<auth.uid()>/` folder. Set file size and MIME limits, and store only the avatar object key in `profiles.avatar`. Never put a secret/service-role key in Flutter.
4. **Implement the Flutter data and image adapters.** Move `FoodRepository` into a neutral file, add a Supabase implementation, and map profile/address columns, numeric prices, timestamps, and nested order lines explicitly. Read and write the cart for the authenticated user only. Resolve `food-photos` keys to public URLs and private avatar keys to short-lived signed URLs; refresh signed URLs when they expire. Do not persist signed URLs in profiles or carts. Use `image_picker` and Storage upload for a user's new avatar, then update the profile path; clean up an abandoned upload if the profile update fails. Keep the local adapter available for isolated tests until cutover. Use the Auth user ID instead of the demo UUID. Return useful failures to the UI instead of silently showing an empty catalog or cart.
5. **Switch the screens.** Replace `DemoAuth` in `login_screen.dart` with Supabase sign-in and add a way to create a local test account and its profile. Make `main.dart` route from restored Auth state; sign out in `profile_screen.dart`. Refresh the profile after edits, and update the Auth email when the email field changes. Replace `Image.asset` with network image loading for food photos in menu, search, cart, and checkout and for profile avatars; show a placeholder on slow or failed loads. Keep all category, branding, payment, delivery, and launcher images bundled. Make menu/search show loading and retry states. Make checkout display the server-confirmed total and only navigate to tracking after `place_order` succeeds. Clear the cart after that confirmed order; keep it if placement fails. Remove the delayed cart clear from `delivery_screen.dart`. The existing random delivery fee in `cart_screen.dart` must be replaced with the server fee rule or a server quote before showing a payable total.
6. **Cut over and reconcile data.** Remove production references to demo accounts, fixture passwords, and local repository selection after the Supabase path works end to end. Do not delete existing `SharedPreferences` records or source image files as part of this switch. The demo UUIDs are not Auth IDs, so old account/cart/order records and avatars require an explicit user-to-Auth mapping before any import. For development, start with fresh Auth accounts and seeded catalog; decide separately whether any real local records need a one-time import. Keep a backup and verify counts, totals, and image availability before removing old local data.

## Verification gates

- Local stack starts with all migrations, the 25 catalog items, and both Storage buckets. The repeatable upload script restores all 25 food photos after a fresh start or reset. The app can sign up, sign in, restart into the saved session, and sign out.
- Every food photo key resolves to the intended image; missing media shows a placeholder. UI images still render from bundled assets. A second user cannot list, download, sign, replace, or delete another user's avatar with their own credentials. Signed avatar URLs are time limited bearer links, so the app must not expose or persist them; they expire and refresh without losing the image.
- Two users can read only their own profile, cart, and orders. An unauthenticated caller cannot write them or call `place_order`.
- A changed catalog price is reflected in the saved order; submitted prices, totals, fees, or another user ID cannot alter it. Invalid items fail without a partial order. Retrying the same request returns one order.
- Cart additions, quantity changes, and removal survive an app restart and remain separate by user.
- Profile edits, including address and email, survive reload. Checkout address and item prices remain snapshots after later changes.
- A failed network request shows an actionable error and leaves the cart intact. Test the actual target platform's local HTTP connection, then run `flutter test` and `dart analyze`.

## Decisions and remaining data work

1. **Existing local records:** assume demo records can be left behind and new Auth accounts created. If the saved local data matters, define an import mapping and retention plan before cutover.
2. **Delivery fee:** the first version uses a fixed 50 peso fee in the database and app. A future variable fee needs a server quote before checkout.
3. **Catalog access:** keep login before browsing. The `food_items` policy requires authentication.
4. **Profile creation:** the registration trigger creates the profile from Auth signup metadata. The app also handles an existing Auth user with no profile as a load error.
5. **Old avatars:** map each demo image to a real Auth user only if those demo users will be recreated; otherwise keep them out of the new profiles.

## First implementation slice

Implemented: local Supabase initialization, Auth sign-in/signup and session routing, catalog reads, food photo uploads and display, private avatar upload, per-user carts, and trusted checkout. Local API smoke tests cover Auth, all catalog photos, avatar isolation, cart isolation, server pricing, retries, and direct-write denial. Flutter tests, analysis, and an Android debug build also pass. Remaining validation is a full manual signup-to-checkout run on the target device and any optional import of old local records.

## References

- [Supabase Flutter initialization](https://supabase.com/docs/reference/dart/initializing)
- [Supabase Flutter Auth sign-in](https://supabase.com/docs/reference/dart/auth-signinwithpassword)
- [Supabase Flutter database RPC](https://supabase.com/docs/reference/dart/rpc)
- [Securing database functions](https://supabase.com/docs/guides/database/functions)
- [Storage access control](https://supabase.com/docs/guides/storage/security/access-control)
- [Flutter Storage upload](https://supabase.com/docs/reference/dart/storage-from-upload)
- [Flutter signed URLs](https://supabase.com/docs/reference/dart/storage-from-createsignedurl)
