# Supabase transition

Run `migrations/20261124000000_initial_food_schema.sql` in a Supabase project.
The tables are `profiles`, `food_items`, `orders`, and `order_items`. An order
has one row per item; quantity and unit price are stored on each line. The
address fields on `orders` are a checkout snapshot, independent of later
profile edits. `photo` contains an asset path today; replace it with a
Supabase Storage path or public URL when catalog images are uploaded.
Email changes in the profile UI must also update Supabase Auth.

The Flutter app currently uses `LocalDatabase` (SharedPreferences) through
`FoodRepository`. Demo credentials are in `demo_auth.dart` and must be replaced
by Supabase Auth. The demo UUIDs are fixtures and do not correspond to
`auth.users`; create real profiles using authenticated Supabase user IDs.

At integration time, implement `FoodRepository` with Supabase queries and set
`activeRepository` during app startup. Map
the nested Dart `Address` to the flattened profile/order columns, and insert
`orders` plus `order_items` in one trusted server-side transaction. The server
must derive the account ID from the authenticated user, look up current prices
from `food_items`, and compute the final total. Direct client inserts are not
enabled by the migration; client totals are only for display. Cart persistence
can remain local or be added as a separate per-user Supabase table.
