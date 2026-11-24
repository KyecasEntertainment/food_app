# Food app

A Flutter food ordering app. The current app runs with local demo sign-in,
catalog fixtures, and `SharedPreferences` storage. Its records and repository
interface are structured for a later Supabase integration.

## Data model

| Record | Fields |
| --- | --- |
| Account | UUID, first name, last name, email, avatar, structured address |
| Address | Unit/house/lot number, subdivision/village, barangay, municipality, optional latitude and longitude |
| Food item | Numeric ID, photo path, name, price, category |
| Cart item | Food item ID, quantity, displayed name/photo/price |
| Order | UUID, account ID, order lines, delivery address snapshot, shipping price, tip price, total price, creation time |
| Order line | Food item ID, quantity, unit price snapshot |

The app saves account changes, carts, and placed orders locally through
`FoodRepository` in `lib/database/local_database.dart`. Food items come from the
existing fixtures through the same interface. Cart records are saved per
account; order records retain their address and item prices after checkout.

Demo passwords live only in `demo_auth.dart` and are not serialized with
profiles or orders. They are development fixtures, not production auth.

## Supabase preparation

The Postgres schema, constraints, foreign keys, indexes, and row level security
policies are in `supabase/migrations/20261124000000_initial_food_schema.sql`.
See `supabase/README.md` for the remaining integration steps. The app does not
connect to Supabase yet. The address form accepts pin coordinates; a Google
Maps picker has not been connected.

## Checks

Run `flutter test` and `dart analyze` from the project root.
