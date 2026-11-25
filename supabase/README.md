# Supabase transition

The local Supabase project and its canonical migration are in the sibling
`food_app_supabase` directory. Follow its README to start the stack. This
directory retains the original migration as a reference for app integration.
The canonical project also has a registration migration that requires email,
subdivision/village, and a complete pin for new profiles and creates the
profile after Supabase Auth signup. Passwords remain in Supabase Auth; no
password column is added to `public.profiles`.
The tables are `profiles`, `food_items`, `cart_items`, `orders`, and
`order_items`. An order
has one row per item; quantity and unit price are stored on each line. The
address fields on `orders` are a checkout snapshot, independent of later
profile edits. `photo` contains a key in the `food-photos` Storage bucket.
Category icons, branding, payment graphics, and delivery art remain bundled
Flutter assets. User avatars use the private `user-avatars` bucket.
Email changes in the profile UI must also update Supabase Auth.

With `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` provided as Dart defines,
the app initializes Supabase Auth, restores its session, and uses
`SupabaseFoodRepository` for profiles, catalog, carts, and orders. Without the
defines, it displays a configuration message. `LocalDatabase` remains for
isolated tests. The demo UUIDs are fixtures and do not correspond to
`auth.users`.

For the Android emulator, pass the local API URL from the sibling README and
its publishable/anon key:

```powershell
flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

For the Google Maps picker, enable the Maps SDK and billing in Google Cloud,
provide a restricted API key, and add `--dart-define=GOOGLE_MAPS_ENABLED=true`.
On Android, set `GOOGLE_MAPS_API_KEY` as a Gradle property or environment
variable. On iOS, copy `ios/Flutter/Maps.example.xcconfig` to the ignored
`Maps.xcconfig` and set its key. Web and desktop use coordinate entry. See
[Google Maps Flutter setup](https://developers.google.com/maps/flutter-package/config).

Checkout calls the `place_order` database function. It derives the account ID
from Auth, looks up current food prices, and writes the order and lines in one
transaction. The delivery fee is currently a fixed 50 pesos in the app and
database. Direct client order inserts are disabled. Reusing the same request
UUID returns the same order after a network retry.
