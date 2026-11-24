import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/delivery_address.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final UserAccounts? loggedInUser;
  final bool showBackButton;
  final bool showAddress;

  const CustomAppBar({
    super.key,
    this.title,
    this.loggedInUser,
    this.showBackButton = false,
    this.showAddress = false,
  }) : assert(showAddress || title != null);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          if (showAddress) ...[
            const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: DeliveryAddress.current,
                builder: (context, address, _) => Text(
                  address.trim().isEmpty ? 'Add delivery address' : address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else
            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: loggedInUser != null && loggedInUser!.avatar.isNotEmpty
                  ? Image.asset(
                      loggedInUser!.avatar,
                      fit: BoxFit.cover,
                      width: 36,
                      height: 36,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
