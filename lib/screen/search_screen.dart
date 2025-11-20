import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/product_list.dart';

class SearchPage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final bool autoFocus;
  const SearchPage({super.key, this.loggedInUser, this.autoFocus = false});

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
        : products.where((p) => p.product_name.toLowerCase().contains(searchText.toLowerCase())).toList();

    return Scaffold(
      appBar: CustomAppBar(title: 'Search', loggedInUser: widget.loggedInUser),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          color: Colors.grey[300],
                          child: Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(product.product_name),
                    subtitle: Text(product.product_category),
                    trailing: Text('₱${product.product_price.toStringAsFixed(2)}'),
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