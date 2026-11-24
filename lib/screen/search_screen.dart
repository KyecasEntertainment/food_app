import 'package:flutter/material.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/product_search_field.dart';

class SearchPage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final bool autoFocus;
  final CartManager cartManager;
  final bool showBackButton;
  const SearchPage({
    super.key,
    this.loggedInUser,
    this.autoFocus = false,
    required this.cartManager,
    this.showBackButton = false,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    if (widget.autoFocus) {
      // Delay focus request to after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<StoreProducts> filteredProducts = searchText.isEmpty
        ? products
        : products
              .where(
                (p) => p.product_name.toLowerCase().contains(
                  searchText.toLowerCase(),
                ),
              )
              .toList();

    return Scaffold(
      appBar: CustomAppBar(
        showAddress: true,
        loggedInUser: widget.loggedInUser,
        showBackButton: widget.showBackButton,
      ),
      body: Column(
        children: [
          ProductSearchField(
            focusNode: _searchFocusNode,
            onChanged: (value) => setState(() => searchText = value),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        product.product_image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.surface,
                          child: Icon(
                            Icons.fastfood,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      product.product_name,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      product.product_category,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
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
                            content: Text(
                              '${product.product_name} added to cart!',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
