import 'package:flutter/material.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/food_photo.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/product_search_field.dart';

class SearchPage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final bool autoFocus;
  final CartManager cartManager;
  final bool showBackButton;
  final VoidCallback onCartPressed;
  const SearchPage({
    super.key,
    this.loggedInUser,
    this.autoFocus = false,
    required this.cartManager,
    this.showBackButton = false,
    required this.onCartPressed,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';
  List<FoodItem> _products = [];
  bool _loadingProducts = true;
  bool _loadFailed = false;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchFocusNode = FocusNode();
    if (widget.autoFocus) {
      // Delay focus request to after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final items = await activeRepository.getFoodItems();
      if (mounted) {
        setState(() {
          _products = items;
          _loadingProducts = false;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingProducts = false;
          _loadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<FoodItem> filteredProducts = searchText.isEmpty
        ? _products
        : _products
              .where(
                (p) => p.name.toLowerCase().contains(searchText.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: CustomAppBar(
        showAddress: true,
        showBackButton: widget.showBackButton,
        onCartPressed: widget.onCartPressed,
        cartManager: widget.cartManager,
      ),
      body: Column(
        children: [
          ProductSearchField(
            focusNode: _searchFocusNode,
            onChanged: (value) => setState(() => searchText = value),
          ),
          Expanded(
            child: _loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : _loadFailed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Could not load the menu.'),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _loadingProducts = true;
                              _loadFailed = false;
                            });
                            _loadProducts();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  color: AppColors.card,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: foodPhotoProvider(product.photo),
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
                      product.name,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      product.category,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: GestureDetector(
                      onTap: () async {
                        final cartItem = CartItem(
                          itemId: product.id,
                          name: product.name,
                          photo: product.photo,
                          unitPrice: product.price,
                          quantity: 1,
                        );
                        widget.cartManager.addItem(cartItem);
                        try {
                          await widget.cartManager.saved;
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not save your cart.'),
                            ),
                          );
                        }
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
