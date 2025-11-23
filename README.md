# lib/ — Code Reference

This document summarizes every Dart source file under `lib/` (as of now). It lists the main widgets, classes, and top-level functions in each file plus a short description and notes for usage.

---

## Overview
The app is a Flutter mobile app (Food ordering). The root `lib/` contains UI screens, a shared `CartManager`, product/payment data and user accounts.

This README is made for the current workspace state and describes:
- `lib/main.dart`
- `lib/bottom_nav_bar.dart`
- `lib/custom_top_bar.dart`
- `lib/screen/*` (screens)
- `lib/database/*` (models, lists, managers)

---

## Files

### lib/main.dart
- Widgets / classes:
  - `Main` (StatelessWidget)
    - App entrypoint, sets `home: LoginScreen()` and registers route `/main`.
  - `MyWidget` (StatelessWidget) — placeholder.
  - `MainScreen` (StatefulWidget) + `_MainScreenState`
    - Holds `_selectedIndex` and a shared `CartManager` instance (`_cartManager`).
    - `_buildPages()` constructs the tab pages using `HomePage`, `SearchPage`, `CartPage`, `ProfilePage` and passes the shared `cartManager` and `loggedInUser`.
    - Uses `BottomNavigation` (from `bottom_nav_bar.dart`) for navigation.

Notes: `MainScreen` accepts an optional `UserAccounts? loggedInUser` to keep session data across navigation.

---

### lib/bottom_nav_bar.dart
- Widgets / classes:
  - `BottomNavigation` (StatelessWidget)
    - Simple wrapper around `BottomNavigationBar` with 4 items: Home, Search, Cart, Profile.
    - Props: `currentIndex`, `onTap`.

---

### lib/custom_top_bar.dart
- Widgets / classes:
  - `CustomAppBar` (StatelessWidget, implements `PreferredSizeWidget`)
    - Props: `title`, `UserAccounts? loggedInUser`, `bool showBackButton`.
    - Renders an `AppBar` with the title and a circular avatar (from `loggedInUser.avatar`) on the right.
    - `automaticallyImplyLeading` controlled by `showBackButton`.

---

### lib/screen/menu_screen.dart
- Widgets / classes:
  - `HomePage` (StatefulWidget) + `_HomePageState`
    - Props: `UserAccounts? loggedInUser`, `CartManager cartManager`.
    - Major UI builders (private methods):
      - `_buildSearchBar()` — navigates to `SearchPage(autoFocus: true, showBackButton: true)` when tapped.
      - `_buildFoodCategory()` — horizontal categories list.
      - `_buildPromotionsSection()` / `_buildPromoBar()` — promo banner.
      - `_buildPopularSection()` — grid of products; each product card has an add-to-cart action that constructs a `CartItem` and calls `cartManager.addItem()`.

Notes: This is the app's home/menu screen that lists `products` from `database/product_list.dart`.

---

### lib/screen/search_screen.dart
- Widgets / classes:
  - `SearchPage` (StatefulWidget) + `_SearchPageState`
    - Props: `UserAccounts? loggedInUser`, `bool autoFocus`, `CartManager cartManager`, `bool showBackButton`.
    - Handles a search input and filters `products` by `product_name`.
    - Adds `CartItem` to the cart on tap of the add button.

---

### lib/screen/cart_screen.dart
- Widgets / classes:
  - `CartPage` (StatefulWidget) + `_CartPageState`
    - Props: `UserAccounts? loggedInUser`, `CartManager cartManager`.
    - Initializes a random `deliveryFee` between 30 and 100 in `initState()`.
    - Shows cart items (from `cartManager.items`) with quantity controls that call `cartManager.updateQuantity()`.
    - Bottom summary: Total items, Subtotal (`cartManager.totalPrice`), Delivery fee, Total Amount.
    - Checkout button navigates to `CheckoutPage(...)`, passing subtotal, deliveryFee, totalAmount and totalItems.

Notes: `deliveryFee` is randomized per `CartPage` instance.

---

### lib/screen/checkout_screen.dart
- Widgets / classes:
  - `CheckoutPage` (StatefulWidget) + `_CheckoutPageState`
    - Props: `UserAccounts? loggedInUser`, `CartManager cartManager`, `double subtotal`, `double deliveryFee`, `double totalAmount`, `int totalItems`.
    - Features:
      - Editable address fields (`addressNameController`, `addressDetailController`).
      - Delivery instructions and contactless option.
      - Payment method dropdown driven by `lib/database/payment_modes.dart` (`payments` list).
      - Tip selection buttons (0, 5, 10, 20) and tip state `tipAmount`.
      - Order summary shows Subtotal, Delivery Fee, optional Tip, and Total (subtotal + deliveryFee + tip).
    - Checkout button navigates to `OrderTrackingPage` (delivery screen), passing `totalAmount + tipAmount` as the total.

Notes: Payment logos and modes are read from `payment_modes.dart`.

---

### lib/screen/delivery_screen.dart
- Widgets / classes:
  - `OrderTrackingPage` (StatefulWidget) + `_OrderTrackingPageState`
    - Props: `double subtotal`, `double deliveryFee`, `double totalAmount`, `int totalItems`, `CartManager cartManager`, `UserAccounts? loggedInUser`.
    - Behavior:
      - ETA countdown via `_startEtaCountdown()` (10s by default) and progress ring.
      - `_onOrderReceived()` sets `isDelivered` true and triggers `_showLoadingAndNavigate()`.
      - `_showLoadingAndNavigate()` waits a random 5–10 seconds, calls `cartManager.clearCart()` and replaces the navigation stack with `MainScreen(loggedInUser: widget.loggedInUser)` so the app lands on Menu and retains session.
      - `_orderSummary()` shows Items, Subtotal, Delivery Fee, Tip (computed as `totalAmount - subtotal - deliveryFee` when positive), and Total.
  - `LoadingProgressRing` (StatefulWidget) + `_RingPainter` (CustomPainter)
    - Animated circular progress ring used in the top status card.

Notes: Tip is derived from `totalAmount - subtotal - deliveryFee` so the Checkout currently encodes tip by increasing the total amount passed to this screen.

---

### lib/screen/profile_screen.dart
- Widgets / classes:
  - `ProfilePage` (StatefulWidget) + `_ProfilePage`
    - Props: `UserAccounts? loggedInUser`.
    - Displays avatar and personal info. If `loggedInUser` is present, populates fields from it.
    - `_openEditBottomSheet(...)` helper to edit name/email/contact using a modal bottom sheet.
    - `_infoCard(...)`, `_buildBadge(...)`, `_connectedAccountCard(...)` helper widgets.

---

### lib/screen/login_screen.dart
- Widgets / classes:
  - `LoginScreen` (StatefulWidget) + `_LoginScreenState`
    - Login form with email/password fields and validation.
    - Helpers: `_inputDecoration()`, `_buildTextField()`, `_emailValidator()`, `_passwordValidator()`.
    - `_submit()` validates and finds a matching user in `accounts` (from `user_accounts.dart`) and then `Navigator.pushReplacement` to `MainScreen(loggedInUser: matchedUser)`.

---

### lib/database/user_accounts.dart
- Classes / data:
  - `UserAccounts` model class (email, password, name, avatar, role).
  - `accounts` — sample `List<UserAccounts>` used for login.

---

### lib/database/session_manager.dart
- Current state: Empty file. Consider implementing session persistence here (e.g., shared preferences or secure storage) if you need to persist login across app restarts.

---

### lib/database/product_list.dart
- Classes / data:
  - `StoreProducts` model class (id, category, image, name, price).
  - `products` — list of sample products used across `HomePage` and `SearchPage`.

---

### lib/database/payment_modes.dart
- Classes / data:
  - `PaymentModes` model (payment_name, payment_logo).
  - `payments` — list of payment modes and asset paths used by `CheckoutPage`.

---

### lib/database/cart_manager.dart
- Classes / API:
  - `CartManager` — an in-memory cart manager with:
    - `_items` list of `CartItem`
    - Methods: `addItem(CartItem)`, `removeItem(product_id)`, `updateQuantity(product_id, quantity)`, `clearCart()`
    - Getters: `totalPrice` (sum of `subtotal`), `itemCount` (sum of quantities), and `items` accessor.

Notes: `MainScreen` creates a single `CartManager` instance and passes it to pages so they share cart state.

---

### lib/database/cart_list.dart
- Classes:
  - `CartList` — a simple model with `cart_id`, `product_id`, `product_quantity` (not used heavily in current UI).

---

### lib/database/cart_item.dart
- Classes:
  - `CartItem` model used by the UI and `CartManager` with fields: `product_id`, `product_name`, `product_image`, `product_price`, `quantity`.
  - Getter: `subtotal` (product_price * quantity).

---

