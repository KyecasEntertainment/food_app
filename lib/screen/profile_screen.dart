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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
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

              // User Avatar from UserAccounts
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[400],
                  backgroundImage: widget.loggedInUser != null
                      ? AssetImage(widget.loggedInUser!.avatar)
                      : null,
                  child: widget.loggedInUser == null
                      ? Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image load error
                  },
                ),
              ),

              const SizedBox(height: 25),

              // Personal Information
              const Text(
                "Personal Information",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),

              const SizedBox(height: 10),

              // Name Card
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

              // Email Card
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

              // Contact Card
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

              const SizedBox(height: 25),

              // Connected Accounts
              const Text(
                "Connected Accounts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Facebook Account Card
              _connectedAccountCard(
                logo: "assets/logo/facebook/facebook_logo.png",
                service: "Facebook",
                status: "Connected",
                trailing: const Icon(Icons.close, color: Colors.red),
              ),

              const SizedBox(height: 10),

              // Google Account Card
              _connectedAccountCard(
                logo: "assets/logo/google/google_logo.png",
                service: "Google",
                status: "Connect",
                button: true,
              ),

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
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
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
              return Icon(Icons.image_not_supported, size: 32, color: Colors.grey);
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
                Text(
                  status,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          
          if (button)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Connect",
                style: TextStyle(color: Colors.black),
              ),
            )
          else if (trailing != null)
            trailing,
        ],
      ),
    );
  }
}