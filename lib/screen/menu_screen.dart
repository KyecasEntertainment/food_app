import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/screen/search_screen.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/app_colors.dart';

class HomePage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final CartManager cartManager;
  const HomePage({super.key, this.loggedInUser, required this.cartManager});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(title: 'Menu', loggedInUser: widget.loggedInUser),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            SizedBox(height: 20),
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
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      alignment: Alignment.topCenter,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.lavender,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: TextField(
          readOnly: true,
          style: const TextStyle(color: AppColors.text),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppColors.text),
            hintText: 'Search',
            hintStyle: GoogleFonts.inter(
              textStyle: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                  loggedInUser: widget.loggedInUser,
                  autoFocus: true,
                  cartManager: widget.cartManager,
                  showBackButton: true,
                ),
              ),
            );
          },
        ),
      ),
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
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = category["name"]!;
          final categoryImage = category["image"]!;
          final isSelected = selectedCategory == categoryName;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categoryName;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.lavender,
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected
                        ? Border.all(color: AppColors.orange, width: 3)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      categoryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lavender,
                          child: Icon(
                            Icons.fastfood,
                            size: 35,
                            color: AppColors.ink,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 70,
                  child: Text(
                    categoryName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 10),
      ),
    );
  }

  Widget _buildPromotionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promotions',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 15),
          _buildPromoBar(),
        ],
      ),
    );
  }

  Widget _buildPromoBar() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lavender, AppColors.primary],
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
                  child: Icon(Icons.fastfood, size: 80, color: AppColors.text),
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
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Free Medium Fries\nfor Orders Above\n₱300',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
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
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 15),
          filteredProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No items in this category',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildFoodContainer(filteredProducts[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFoodContainer(StoreProducts product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  product.product_image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: AppColors.lavender,
                      child: Icon(
                        Icons.food_bank,
                        size: 50,
                        color: AppColors.ink,
                      ),
                    );
                  },
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
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₱${product.product_price.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
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
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppColors.surface, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
