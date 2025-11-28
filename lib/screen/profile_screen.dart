import 'package:flutter/material.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/custom_top_bar.dart';

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

  // Dummy product list
  List<String> products = ["Burger", "Fries", "Pizza"];

  @override
  void initState() {
    super.initState();
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
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: _input(title),
            ),
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
    String productPrice = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Product",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              decoration: _input("Product Name"),
              onChanged: (v) => productName = v,
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: _input("Price"),
              keyboardType: TextInputType.number,
              onChanged: (v) => productPrice = v,
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Upload Product Photo"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    products.add(productName);
                  });
                  Navigator.pop(context);
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
    String selectedProduct = products.first;
    String newName = "";
    String newPrice = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Product",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: selectedProduct,
              items: products
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p),
                      ))
                  .toList(),
              onChanged: (v) => selectedProduct = v!,
              decoration: _input("Choose Product"),
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: _input("New Name"),
              onChanged: (v) => newName = v,
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: _input("New Price"),
              keyboardType: TextInputType.number,
              onChanged: (v) => newPrice = v,
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Upload New Photo"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    int i = products.indexOf(selectedProduct);
                    products[i] =
                        newName.isNotEmpty ? newName : selectedProduct;
                  });
                  Navigator.pop(context);
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
    String selectedProduct = products.first;

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
            const Text("Remove Product",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: selectedProduct,
              items: products
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => selectedProduct = v!,
              decoration: _input("Select Product"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    products.remove(selectedProduct);
                  });
                  Navigator.pop(context);
                },
                child: const Text("Confirm Remove",
                    style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.grey.shade200,
      appBar: CustomAppBar(title: 'Profile', loggedInUser: widget.loggedInUser),
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
                  backgroundColor: Colors.grey[400],
                  backgroundImage: widget.loggedInUser != null
                      ? AssetImage(widget.loggedInUser!.avatar)
                      : null,
                  child: widget.loggedInUser == null
                      ? const Icon(Icons.person,
                          size: 70, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(height: 25),

              const Text("Personal Information",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
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
                badge: _buildBadge("Verify", Colors.red),
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
                badge: _buildBadge("Verified", Colors.green),
              ),

              const SizedBox(height: 30),

              const Text("Product Management",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _actionButton("Add Product", Icons.add, Colors.green,
                  _openAddProductPopup),
              const SizedBox(height: 10),

              _actionButton("Edit Product", Icons.edit, Colors.blue,
                  _openEditProductPopup),
              const SizedBox(height: 10),

              _actionButton("Remove Product", Icons.delete, Colors.red,
                  _openRemoveProductPopup),

              const SizedBox(height: 40),
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
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          if (badge != null) ...[
            const SizedBox(height: 8),
            badge,
          ]
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _connectedAccountCard({
    required String logo,
    required String service,
    required String status,
    bool button = false,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Image.asset(
            logo,
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported,
                  size: 32, color: Colors.white);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(status,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          if (button)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Text("Connect", style: TextStyle(color: Colors.black)),
            )
          else if (trailing != null)
            trailing,
        ],
      ),
    );
  }

  Widget _actionButton(
      String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
