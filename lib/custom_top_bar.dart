import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/database/user_accounts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final UserAccounts? loggedInUser;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.loggedInUser,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.istokWeb(
                textStyle: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: loggedInUser != null && loggedInUser!.avatar.isNotEmpty
                  ? Image.asset(
                      loggedInUser!.avatar,
                      fit: BoxFit.cover,
                      width: 36,
                      height: 36,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(Icons.person,
                            size: 18, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.person,
                          size: 18, color: Colors.grey),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}