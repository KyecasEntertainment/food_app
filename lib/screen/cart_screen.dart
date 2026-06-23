import 'package:flutter/material.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/screen/checkout_screen.dart';
import 'package:food_app/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class CartPage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final CartManager cartManager;
  const CartPage({super.key, this.loggedInUser, required this.cartManager});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late double deliveryFee;

  @override
  void initState() {
    super.initState();
    deliveryFee = Random().nextInt(71).toDouble() + 30; // Random between 30-100
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cart', loggedInUser: widget.loggedInUser),
      body: widget.cartManager.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.lavender,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartManager.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartManager.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item.product_image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 80,
                                        height: 80,
                                        color: AppColors.lavender,
                                        child: Icon(
                                          Icons.fastfood,
                                          color: AppColors.ink,
                                          size: 40,
                                        ),
                                      ),
                                ),
                              ),
                              SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product_name,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₱${item.product_price.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Subtotal: ₱${item.subtotal.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.cartManager.updateQuantity(
                                          item.product_id,
                                          item.quantity + 1,
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: AppColors.surface,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.cartManager.updateQuantity(
                                          item.product_id,
                                          item.quantity - 1,
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        color: AppColors.surface,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total Price Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.lavender, width: 2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items:',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.cartManager.itemCount}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₱${widget.cartManager.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Fee:',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₱${deliveryFee.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(color: AppColors.lavender, thickness: 1),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₱${(widget.cartManager.totalPrice + deliveryFee).toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  loggedInUser: widget.loggedInUser,
                                  cartManager: widget.cartManager,
                                  subtotal: widget.cartManager.totalPrice,
                                  deliveryFee: deliveryFee,
                                  totalAmount:
                                      widget.cartManager.totalPrice +
                                      deliveryFee,
                                  totalItems: widget.cartManager.itemCount,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Checkout',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
