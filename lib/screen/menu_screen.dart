import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/screen/search_screen.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/product_search_field.dart';

class HomePage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final CartManager cartManager;
  final VoidCallback onCartPressed;
  const HomePage({
    super.key,
    this.loggedInUser,
    required this.cartManager,
    required this.onCartPressed,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showAddress: true,
        onCartPressed: widget.onCartPressed,
        cartManager: widget.cartManager,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            SizedBox(height: 10),
            // Food Category
            _buildFoodCategory(),
            SizedBox(height: 20),
            // Promotions Section
            _buildPromotionsSection(),
            SizedBox(height: 20),
            // Popular Section
            _buildPopularSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ProductSearchField(
      readOnly: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(
              loggedInUser: widget.loggedInUser,
              autoFocus: true,
              cartManager: widget.cartManager,
              onCartPressed: widget.onCartPressed,
              showBackButton: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodCategory() {
    final categories = [
      {"name": "All", "image": "assets/food_images/Category/all.png"},
      {"name": "Burgers", "image": "assets/food_images/Category/Burger.png"},
      {"name": "Pizza", "image": "assets/food_images/Category/Pizza.png"},
      {
        "name": "Fried Chicken",
        "image": "assets/food_images/Category/Chicken.png",
      },
      {"name": "Fries", "image": "assets/food_images/Category/Fries.png"},
      {"name": "Drinks", "image": "assets/food_images/Category/Drinks.png"},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = category["name"]!;
          final categoryImage = category["image"]!;
          final isSelected = selectedCategory == categoryName;

          return Material(
            color: isSelected ? AppColors.primary : AppColors.surface,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => setState(() => selectedCategory = categoryName),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: categoryName == 'All'
                          ? Icon(
                              Icons.apps_rounded,
                              size: 22,
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            )
                          : Image.asset(
                              categoryImage,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.fastfood,
                                    size: 22,
                                    color: isSelected
                                        ? AppColors.textOnPrimary
                                        : AppColors.textPrimary,
                                  ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildPromotionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildPromoBar()],
      ),
    );
  }

  Widget _buildPromoBar() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryPressed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -10,
            bottom: -10,
            child: Image.asset(
              'assets/food_images/Category/Fries.png',
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  child: Icon(
                    Icons.fastfood,
                    size: 80,
                    color: AppColors.textOnPrimary,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Today's Offer",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Free Medium Fries\nfor Orders Above\n₱300',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection() {
    // Filter products based on selected category
    List<StoreProducts> filteredProducts = selectedCategory == "All"
        ? products
        : products
              .where((p) => p.product_category == selectedCategory)
              .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 15),
          filteredProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No items in this category',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = (constraints.maxWidth - 15) / 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        mainAxisExtent: tileWidth + 90,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildFoodContainer(filteredProducts[index]);
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFoodContainer(StoreProducts product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  product.product_image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: AppColors.surface,
                        child: Icon(
                          Icons.food_bank,
                          size: 50,
                          color: AppColors.textPrimary,
                        ),
                      ),
                ),
              ),
              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product.product_name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₱${product.product_price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Add Button
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                // Add to cart functionality
                final cartItem = CartItem(
                  product_id: product.product_id,
                  product_name: product.product_name,
                  product_image: product.product_image,
                  product_price: product.product_price,
                  quantity: 1,
                );
                widget.cartManager.addItem(cartItem);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.product_name} added to cart!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppColors.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
