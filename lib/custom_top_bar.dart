import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/delivery_address.dart';
import 'package:food_app/database/cart_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showAddress;
  final VoidCallback? onCartPressed;
  final CartManager? cartManager;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showAddress = false,
    this.onCartPressed,
    this.cartManager,
  }) : assert(showAddress || title != null),
       assert(onCartPressed == null || cartManager != null);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: showAddress
          ? Row(
              children: [
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
              ],
            )
          : Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: onCartPressed == null
          ? null
          : [
              AnimatedBuilder(
                animation: cartManager!,
                builder: (context, _) {
                  final count = cartManager!.distinctProductCount;
                  return IconButton(
                    tooltip:
                        'Cart ($count ${count == 1 ? 'product' : 'products'})',
                    onPressed: onCartPressed,
                    icon: Badge.count(
                      count: count,
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.textOnPrimary,
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
