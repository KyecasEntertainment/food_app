# Food app

A Flutter food ordering app backed by the sibling local Supabase project. Run
with `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` Dart defines. Without them,
the app displays a configuration message. Supabase Auth, Postgres, and Storage
provide accounts, catalog, carts, orders, food photos, and user avatars.

## Data model

| Record | Fields |
| --- | --- |
| Account | UUID, first name, last name, email, avatar, structured address |
| Address | Unit/house/lot number, subdivision/village, barangay, municipality, optional latitude and longitude |
| Food item | Numeric ID, photo path, name, price, category |
| Cart item | Food item ID, quantity, displayed name/photo/price |
| Order | UUID, account ID, order lines, delivery address snapshot, shipping price, tip price, total price, creation time |
| Order line | Food item ID, quantity, unit price snapshot |

`SupabaseFoodRepository` implements `FoodRepository` for the running app.
`LocalDatabase` and its fixtures remain for isolated tests. The local backend
stores one cart per account and keeps address and item price snapshots in each
order. The database calculates the delivery fee and final order total.

Demo passwords in `demo_auth.dart` are test fixtures and are not used by the
running app. Account passwords go to Supabase Auth.

## Supabase preparation

The local Supabase backend is in the sibling `food_app_supabase` directory. It
contains the canonical Postgres migrations, row level security policies, catalog
seed, Storage buckets, image upload script, and startup instructions. See
`supabase/README.md` for connection steps.
The account creation form requires first and last name, email, password, the
four address parts, and a latitude/longitude pin. The Google Maps picker is
available on Android and iOS after an API key is configured; coordinate entry
remains available for development and web.

## Checks

Run `flutter test` and `dart analyze` from the project root.
