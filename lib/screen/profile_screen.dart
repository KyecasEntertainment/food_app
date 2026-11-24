import 'package:flutter/material.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final UserAccounts? loggedInUser;

  const ProfilePage({super.key, this.loggedInUser});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late String name;
  late String email;
  late String contact;

  // Use the actual products list from product_list.dart
  late List<StoreProducts> productList;

  @override
  void initState() {
    super.initState();
    // Initialize product list from the global products list
    productList = List.from(products);

    if (widget.loggedInUser != null) {
      name = widget.loggedInUser!.name;
      email = widget.loggedInUser!.email;
      contact = "+639934229236";
    } else {
      name = "John Doe";
      email = "johndoe@example.com";
      contact = "+639934229236";
    }
  }

  // Input decoration
  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // -------------------------------------------------------------
  // REUSED BOTTOM SHEET FOR EDITING PERSONAL INFO
  // -------------------------------------------------------------
  void _openEditBottomSheet({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(controller: controller, decoration: _input(title)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  onSave(controller.text);
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // POPUP: ADD PRODUCT
  // -------------------------------------------------------------
  void _openAddProductPopup() {
    String productName = "";
    String productCategory = "Burgers";
    double productPrice = 0.0;
    String productImage = "";
    final categories = ["Burgers", "Pizza", "Fried Chicken", "Fries", "Drinks"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              decoration: _input("Product Name"),
              onChanged: (v) => productName = v,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: productCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => productCategory = v ?? "Burgers",
              decoration: _input("Category"),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: _input("Price"),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (v) => productPrice = double.tryParse(v) ?? 0.0,
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: _input("Image Path"),
              onChanged: (v) => productImage = v,
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (productName.isNotEmpty && productPrice > 0) {
                    setState(() {
                      final newId =
                          (productList.isEmpty
                              ? 0
                              : productList.last.product_id) +
                          1;
                      final newProduct = StoreProducts(
                        product_id: newId,
                        product_category: productCategory,
                        product_name: productName,
                        product_image: productImage.isNotEmpty
                            ? productImage
                            : "assets/food_images/Category/all.png",
                        product_price: productPrice,
                      );
                      productList.add(newProduct);
                      // Update global products list
                      products.add(newProduct);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Product added successfully!"),
                      ),
                    );
                  }
                },
                child: const Text("Confirm"),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // POPUP: EDIT PRODUCT
  // -------------------------------------------------------------
  void _openEditProductPopup() {
    if (productList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No products to edit")));
      return;
    }

    late StoreProducts selectedProduct = productList.first;
    late String newName = selectedProduct.product_name;
    late double newPrice = selectedProduct.product_price;
    late String newCategory = selectedProduct.product_category;
    final categories = ["Burgers", "Pizza", "Fried Chicken", "Fries", "Drinks"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<StoreProducts>(
              value: selectedProduct,
              items: productList
                  .map(
                    (p) =>
                        DropdownMenuItem(value: p, child: Text(p.product_name)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  selectedProduct = v;
                  newName = v.product_name;
                  newPrice = v.product_price;
                  newCategory = v.product_category;
                }
              },
              decoration: _input("Choose Product"),
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: _input("New Name"),
              controller: TextEditingController(text: newName),
              onChanged: (v) => newName = v,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: newCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => newCategory = v ?? newCategory,
              decoration: _input("Category"),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: _input("New Price"),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: TextEditingController(text: newPrice.toString()),
              onChanged: (v) => newPrice = double.tryParse(v) ?? newPrice,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    final index = productList.indexOf(selectedProduct);
                    final updatedProduct = StoreProducts(
                      product_id: selectedProduct.product_id,
                      product_category: newCategory,
                      product_name: newName,
                      product_image: selectedProduct.product_image,
                      product_price: newPrice,
                    );
                    productList[index] = updatedProduct;
                    // Update global products list
                    final globalIndex = products.indexOf(selectedProduct);
                    if (globalIndex != -1) {
                      products[globalIndex] = updatedProduct;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Product updated successfully!"),
                    ),
                  );
                },
                child: const Text("Confirm Changes"),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // POPUP: REMOVE PRODUCT
  // -------------------------------------------------------------
  void _openRemoveProductPopup() {
    if (productList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No products to remove")));
      return;
    }

    late StoreProducts selectedProduct = productList.first;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Remove Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<StoreProducts>(
              value: selectedProduct,
              items: productList
                  .map(
                    (p) =>
                        DropdownMenuItem(value: p, child: Text(p.product_name)),
                  )
                  .toList(),
              onChanged: (v) => selectedProduct = v ?? selectedProduct,
              decoration: _input("Select Product"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () {
                  setState(() {
                    productList.remove(selectedProduct);
                    // Update global products list
                    products.remove(selectedProduct);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Product removed successfully!"),
                    ),
                  );
                },
                child: const Text(
                  "Confirm Remove",
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showAddress: true,
        loggedInUser: widget.loggedInUser,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: AppColors.surface,
                  backgroundImage: widget.loggedInUser != null
                      ? AssetImage(widget.loggedInUser!.avatar)
                      : null,
                  child: widget.loggedInUser == null
                      ? const Icon(
                          Icons.person,
                          size: 70,
                          color: AppColors.textPrimary,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              _infoCard(
                title: "Name",
                value: name,
                onEdit: () {
                  _openEditBottomSheet(
                    title: "Edit Name",
                    currentValue: name,
                    onSave: (v) => setState(() => name = v),
                  );
                },
              ),

              const SizedBox(height: 12),

              _infoCard(
                title: "Email",
                value: email,
                onEdit: () {
                  _openEditBottomSheet(
                    title: "Edit Email",
                    currentValue: email,
                    onSave: (v) => setState(() => email = v),
                  );
                },
                badge: _buildBadge("Verify", AppColors.accent),
              ),

              const SizedBox(height: 12),

              _infoCard(
                title: "Contact Number",
                value: contact,
                onEdit: () {
                  _openEditBottomSheet(
                    title: "Edit Contact Number",
                    currentValue: contact,
                    onSave: (v) => setState(() => contact = v),
                  );
                },
                badge: _buildBadge("Verified", AppColors.success),
              ),

              const SizedBox(height: 30),

              // Product Management - only show for Admin users
              if (widget.loggedInUser != null &&
                  widget.loggedInUser!.role == "Admin") ...[
                const Text(
                  "Product Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                _actionButton(
                  "Add Product",
                  Icons.add,
                  AppColors.accent,
                  _openAddProductPopup,
                ),
                const SizedBox(height: 10),

                _actionButton(
                  "Edit Product",
                  Icons.edit,
                  AppColors.primary,
                  _openEditProductPopup,
                ),
                const SizedBox(height: 10),

                _actionButton(
                  "Remove Product",
                  Icons.delete,
                  AppColors.error,
                  _openRemoveProductPopup,
                ),

                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required VoidCallback onEdit,
    Widget? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit, color: AppColors.textOnPrimary),
              ),
            ],
          ),
          if (badge != null) ...[const SizedBox(height: 8), badge],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == AppColors.accent
              ? AppColors.textPrimary
              : AppColors.textOnPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _actionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(
          icon,
          color: color == AppColors.accent
              ? AppColors.textPrimary
              : AppColors.textOnPrimary,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: color == AppColors.accent
                ? AppColors.textPrimary
                : AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
