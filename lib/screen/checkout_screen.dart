import 'package:flutter/material.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/payment_modes.dart';
import 'package:food_app/screen/delivery_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final CartManager cartManager;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final int totalItems;

  const CheckoutPage({
    super.key,
    this.loggedInUser,
    required this.cartManager,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.totalItems,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late String selectedPayment;
  String deliveryInstructions = '';
  bool contactlessDelivery = false;
  double tipAmount = 0;
  

  late TextEditingController addressNameController;
  late TextEditingController addressDetailController;

  @override
  void initState() {
    super.initState();
    selectedPayment = payments.isNotEmpty ? payments.first.payment_name : 'GCash';
    addressNameController = TextEditingController(text: 'Home');
    addressDetailController = TextEditingController(text: '123 Main Street, Baybay, Los Baños, Laguna');
  }

  @override
  void dispose() {
    addressNameController.dispose();
    addressDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Checkout', loggedInUser: widget.loggedInUser),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Section
              _buildAddressSection(),
              SizedBox(height: 20),

              // Delivery Instructions
              _buildDeliveryInstructionsSection(),
              SizedBox(height: 20),

              // Payment Method Section
              _buildPaymentMethodSection(),
              SizedBox(height: 20),

              // Tip Section
              _buildTipSection(),
              SizedBox(height: 20),

              // Order Summary
              _buildOrderSummarySection(),
              SizedBox(height: 24),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingPage(
                          subtotal: widget.subtotal,
                          deliveryFee: widget.deliveryFee,
                          totalAmount: widget.totalAmount + tipAmount,
                          totalItems: widget.totalItems,
                          cartManager: widget.cartManager,
                          loggedInUser: widget.loggedInUser,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 85, 3, 129),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Checkout',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address Name',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: addressNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: 'e.g., Home, Office',
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Full Address',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: addressDetailController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: 'Enter your complete address',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Instructions',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: CheckboxListTile(
            value: contactlessDelivery,
            onChanged: (value) {
              setState(() {
                contactlessDelivery = value ?? false;
              });
            },
            title: Text(
              'Contactless Delivery: your rider will place your delivery at your door',
              style: GoogleFonts.inter(
                fontSize: 13,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Add delivery instruction (optional)',
            hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              deliveryInstructions = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: selectedPayment,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: payments.map((method) {
                    return DropdownMenuItem<String>(
                      value: method.payment_name,
                      child: Text(
                        method.payment_name,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedPayment = newValue;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Builder(
                  builder: (context) {
                    final logo = payments.isNotEmpty
                        ? (payments.firstWhere(
                            (p) => p.payment_name == selectedPayment,
                            orElse: () => payments.first,
                          ).payment_logo)
                        : 'assets/logo/payment_modes/payment_mode_1.png';

                    return Image.asset(
                      logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.credit_card, size: 24, color: Colors.grey),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tip Your Rider',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.edit, size: 20, color: Colors.grey[600]),
          ],
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTipOption(0, 'No tip'),
            _buildTipOption(5, '₱5'),
            _buildTipOption(10, '₱10'),
            _buildTipOption(20, '₱20'),
          ],
        ),
      ],
    );
  }

  Widget _buildTipOption(double amount, String label) {
    final isSelected = tipAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          tipAmount = amount;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              Text(
                '₱${widget.subtotal.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              Text(
                '₱${widget.deliveryFee.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ],
          ),
          if (tipAmount > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tip',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                Text(
                  '₱${tipAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ],
            ),
          ],
          Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₱${(widget.totalAmount + tipAmount).toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 85, 3, 129),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
