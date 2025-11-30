# lib/ — Code Reference

This document summarizes every Dart source file under `lib/` (as of November 29, 2025). It lists the main widgets, classes, top-level functions, and all methods in each file plus a short description and notes for usage.

---

## Overview
The app is a Flutter mobile app (Food ordering). The root `lib/` contains UI screens, a shared `CartManager`, product/payment data and user accounts.

This README documents:
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
    - Methods:
      - `build(BuildContext context)` → Returns `MaterialApp` with theme and routes.
  - `MyWidget` (StatelessWidget) — placeholder.
    - Methods:
      - `build(BuildContext context)` → Placeholder widget.
  - `MainScreen` (StatefulWidget) + `_MainScreenState`
    - Holds `_selectedIndex` and a shared `CartManager` instance (`_cartManager`).
    - Methods:
      - `initState()` — Initializes `_cartManager`.
      - `_buildPages()` → Constructs the tab pages using `HomePage`, `SearchPage`, `CartPage`, `ProfilePage` and passes the shared `cartManager` and `loggedInUser`.
      - `build(BuildContext context)` → Renders `Scaffold` with `BottomNavigation`.
    - Uses `BottomNavigation` (from `bottom_nav_bar.dart`) for navigation.

Notes: `MainScreen` accepts an optional `UserAccounts? loggedInUser` to keep session data across navigation.

---

### lib/bottom_nav_bar.dart
- Widgets / classes:
  - `BottomNavigation` (StatelessWidget)
    - Simple wrapper around `BottomNavigationBar` with 4 items: Home, Search, Cart, Profile.
    - Props: `currentIndex`, `onTap`.
    - Methods:
      - `build(BuildContext context)` → Returns styled `BottomNavigationBar`.

---

### lib/custom_top_bar.dart
- Widgets / classes:
  - `CustomAppBar` (StatelessWidget, implements `PreferredSizeWidget`)
    - Props: `title`, `UserAccounts? loggedInUser`, `bool showBackButton`.
    - Methods:
      - `build(BuildContext context)` → Renders an `AppBar` with title and circular avatar.
      - `get preferredSize` → Returns `Size.fromHeight(kToolbarHeight)`.
    - Renders an `AppBar` with the title and a circular avatar (from `loggedInUser.avatar`) on the right.
    - `automaticallyImplyLeading` controlled by `showBackButton`.

---

### lib/screen/menu_screen.dart
- Widgets / classes:
  - `HomePage` (StatefulWidget) + `_HomePageState`
    - Props: `UserAccounts? loggedInUser`, `CartManager cartManager`.
    - Methods:
      - `build(BuildContext context)` → Renders full home page layout.
      - `_buildSearchBar()` → Navigates to `SearchPage(autoFocus: true, showBackButton: true)` when tapped.
      - `_buildFoodCategory()` → Horizontal categories list with scroll.
      - `_buildPromotionsSection()` → Promo section header.
      - `_buildPromoBar()` → Carousel of promotional banners.
      - `_buildPopularSection()` → Section header for popular items.
      - `_buildPopularGrid()` → Grid of product cards with add-to-cart action.
      - `_buildProductCard(StoreProducts product)` → Individual product card widget.
    - Each product card has an add-to-cart action that constructs a `CartItem` and calls `cartManager.addItem()`.

Notes: This is the app's home/menu screen that lists `products` from `database/product_list.dart`.

---

### lib/screen/search_screen.dart
- Widgets / classes:
  - `SearchPage` (StatefulWidget) + `_SearchPageState`
    - Props: `UserAccounts? loggedInUser`, `bool autoFocus`, `CartManager cartManager`, `bool showBackButton`.
    - Methods:
      - `initState()` → Sets up focus if `autoFocus` is true.
      - `build(BuildContext context)` → Renders search UI with filtered results.
      - `_buildSearchBar()` → Input field for search query.
      - `_buildResults()` → Grid of filtered product results.
      - `_buildProductCard(StoreProducts product)` → Product card with add-to-cart.
    - Handles a search input and filters `products` by `product_name`.
    - Adds `CartItem` to the cart on tap of the add button.

---

### lib/screen/cart_screen.dart
- Widgets / classes:
  - `CartPage` (StatefulWidget) + `_CartPageState`
    - Props: `UserAccounts? loggedInUser`, `CartManager cartManager`.
    - Methods:
      - `initState()` → Initializes random `deliveryFee` between 30 and 100.
      - `build(BuildContext context)` → Renders cart items and summary.
      - `_buildCartItems()` → List of cart items with quantity controls.
      - `_buildCartItemCard(CartItem item)` → Individual cart item card.
      - `_buildSummary()` → Bottom summary section with totals.
    - Shows cart items (from `cartManager.items`) with quantity controls that call `cartManager.updateQuantity()`.
    - Bottom summary: Total items, Subtotal (`cartManager.totalPrice`), Delivery fee, Total Amount.
    - Checkout button navigates to `CheckoutPage(...)`, passing subtotal, deliveryFee, totalAmount and totalItems.

Notes: `deliveryFee` is randomized per `CartPage` instance.

---

### lib/screen/checkout_screen.dart
- Widgets / classes:
  - `CheckoutPage` (StatefulWidget) + `_CheckoutPageState`
    - Props: `UserAccounts? loggedInUser`, `CartManager cartManager`, `double subtotal`, `double deliveryFee`, `double totalAmount`, `int totalItems`.
    - Methods:
      - `initState()` → Initializes controllers and default values.
      - `dispose()` → Cleans up text controllers.
      - `build(BuildContext context)` → Renders checkout form and summary.
      - `_buildAddressSection()` → Editable address fields.
      - `_buildDeliveryOptions()` → Delivery instructions and contactless toggle.
      - `_buildPaymentMethod()` → Dropdown for payment selection.
      - `_buildTipSelection()` → Tip amount selector buttons.
      - `_buildOrderSummary()` → Summary with all costs and tip.
      - `_buildCheckoutButton()` → Checkout action button.
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
    - Methods:
      - `initState()` → Starts ETA countdown timer.
      - `dispose()` → Cancels timer.
      - `build(BuildContext context)` → Renders delivery tracking UI.
      - `_startEtaCountdown()` → Initializes 10-second countdown timer.
      - `_onOrderReceived()` → Sets `isDelivered` true and triggers loading/navigation.
      - `_showLoadingAndNavigate()` → Waits 5–10 seconds, clears cart, and navigates to `MainScreen`.
      - `_buildTrackingHeader()` → Status and ETA display card.
      - `_buildDeliveryMap()` → Map or delivery visualization area.
      - `_buildDeliveryDetails()` → Delivery person info and contact.
      - `_orderSummary()` → Shows Items, Subtotal, Delivery Fee, Tip, and Total.
  - `LoadingProgressRing` (StatefulWidget) + `_LoadingProgressRingState`
    - Methods:
      - `initState()` → Starts animation controller.
      - `dispose()` → Disposes animation controller.
      - `build(BuildContext context)` → Renders animated progress ring.
  - `_RingPainter` (CustomPainter)
    - Methods:
      - `paint(Canvas canvas, Size size)` → Draws circular progress ring.
      - `shouldRepaint(CustomPainter oldDelegate)` → Repaints on animation updates.
    - Animated circular progress ring used in the top status card.

Notes: Tip is derived from `totalAmount - subtotal - deliveryFee` so the Checkout currently encodes tip by increasing the total amount passed to this screen.

---

### lib/screen/profile_screen.dart
- Widgets / classes:
  - `ProfilePage` (StatefulWidget) + `_ProfilePageState`
    - Props: `UserAccounts? loggedInUser`.
    - Methods:
      - `build(BuildContext context)` → Renders profile UI.
      - `_openEditBottomSheet(...)` → Opens modal bottom sheet for editing profile fields.
      - `_infoCard(String label, String value)` → Reusable info display card.
      - `_buildBadge(String label)` → Badge widget for user status.
      - `_connectedAccountCard(String provider)` → Connected account display.
      - `_buildEditableField(String label, String initialValue, Function(String) onSave)` → Editable field in bottom sheet.
    - Displays avatar and personal info. If `loggedInUser` is present, populates fields from it.
    - `_openEditBottomSheet(...)` helper to edit name/email/contact using a modal bottom sheet.
    - `_infoCard(...)`, `_buildBadge(...)`, `_connectedAccountCard(...)` helper widgets.

---

### lib/screen/login_screen.dart
- Widgets / classes:
  - `LoginScreen` (StatefulWidget) + `_LoginScreenState`
    - Methods:
      - `build(BuildContext context)` → Renders login form UI.
      - `_inputDecoration(String hint)` → Reusable text field decoration.
      - `_buildTextField(String hint, TextEditingController controller, String? Function(String?) validator, bool obscureText)` → Reusable text field widget.
      - `_emailValidator(String? value)` → Email validation logic.
      - `_passwordValidator(String? value)` → Password validation logic.
      - `_submit()` → Validates form and authenticates user against `accounts` list.
      - `_buildSubmitButton()` → Login button widget.
    - Login form with email/password fields and validation.
    - Helpers: `_inputDecoration()`, `_buildTextField()`, `_emailValidator()`, `_passwordValidator()`.
    - `_submit()` validates and finds a matching user in `accounts` (from `user_accounts.dart`) and then `Navigator.pushReplacement` to `MainScreen(loggedInUser: matchedUser)`.

---

### lib/database/user_accounts.dart
- Classes / data:
  - `UserAccounts` model class
    - Fields: `email`, `password`, `name`, `avatar`, `role`.
    - Constructor: `UserAccounts({required email, required password, required name, required avatar, required role})`.
  - `accounts` — `List<UserAccounts>` with sample user data used for login authentication.

---

### lib/database/session_manager.dart
- Current state: Empty file. 
- Recommended implementation: Session persistence (e.g., shared preferences or secure storage) to persist login across app restarts.

---

### lib/database/product_list.dart
- Classes / data:
  - `StoreProducts` model class
    - Fields: `id`, `category`, `image`, `name`, `price`.
    - Constructor: `StoreProducts({required id, required category, required image, required name, required price})`.
  - `products` — `List<StoreProducts>` with sample product data used across `HomePage` and `SearchPage`.

---

### lib/database/payment_modes.dart
- Classes / data:
  - `PaymentModes` model class
    - Fields: `payment_name`, `payment_logo`.
    - Constructor: `PaymentModes({required payment_name, required payment_logo})`.
  - `payments` — `List<PaymentModes>` with payment modes and asset paths used by `CheckoutPage`.

---

### lib/database/cart_manager.dart
- Classes / API:
  - `CartManager` — an in-memory cart manager
    - Private fields: `_items` (list of `CartItem`).
    - Methods:
      - `addItem(CartItem item)` → Adds a `CartItem` to the cart or increments quantity if already exists.
      - `removeItem(String product_id)` → Removes item from cart by product ID.
      - `updateQuantity(String product_id, int quantity)` → Updates item quantity or removes if quantity is 0.
      - `clearCart()` → Empties the cart completely.
    - Getters:
      - `totalPrice` → Returns sum of all item subtotals.
      - `itemCount` → Returns total number of items (sum of quantities).
      - `items` → Returns list of `CartItem` in cart.

Notes: `MainScreen` creates a single `CartManager` instance and passes it to pages so they share cart state.

---

### lib/database/cart_list.dart
- Classes:
  - `CartList` model class
    - Fields: `cart_id`, `product_id`, `product_quantity`.
    - Constructor: `CartList({required cart_id, required product_id, required product_quantity})`.

