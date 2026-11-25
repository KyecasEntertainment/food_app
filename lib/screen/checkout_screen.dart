import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/address_input.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/order.dart';
import 'package:food_app/database/supabase_settings.dart';
import 'package:food_app/database/payment_modes.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/delivery_address.dart';
import 'package:food_app/screen/delivery_screen.dart';

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
  final _addressFormKey = GlobalKey<FormState>();
  late Address _address;
  bool _savingOrder = false;
  bool _orderPlaced = false;
  FoodOrder? _pendingOrder;
  late String selectedPayment;
  bool contactlessDelivery = false;
  double tipAmount = 0;

  late final TextEditingController instructionsController;

  @override
  void initState() {
    super.initState();
    selectedPayment = payments.isNotEmpty ? payments.first.name : 'GCash';
    _address = DeliveryAddress.structured.value;
    instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final accountId = widget.loggedInUser?.id;
    if (accountId == null) return;
    if (_savingOrder ||
        _orderPlaced ||
        !(_addressFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_pendingOrder == null && widget.cartManager.items.isEmpty) return;
    setState(() => _savingOrder = true);
    try {
      final draft = _pendingOrder ?? FoodOrder.fromCart(
        cartItems: widget.cartManager.items,
        deliveryAddress: _address,
        shippingPrice: widget.deliveryFee,
        tipPrice: tipAmount,
        accountId: accountId,
      );
      _pendingOrder = draft;
      if (widget.loggedInUser != null) {
        final account = await activeRepository.getAccount(
          widget.loggedInUser!.id,
        );
        await activeRepository.saveAccount(
          (account ?? widget.loggedInUser!).copyWith(address: _address),
        );
      }
      final order = await activeRepository.saveOrder(draft);
      widget.cartManager.clearCart();
      await widget.cartManager.saved;
      _orderPlaced = true;
      DeliveryAddress.setAddress(_address);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OrderTrackingPage(
            subtotal: order.items.fold<double>(
              0,
              (sum, line) => sum + line.subtotal,
            ),
            deliveryFee: order.shippingPrice,
            totalAmount: order.totalPrice,
            totalItems: order.items.fold<int>(
              0,
              (sum, line) => sum + line.quantity,
            ),
            cartManager: widget.cartManager,
            loggedInUser: widget.loggedInUser,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the order. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout',
        showBackButton: true,
        onCartPressed: () => Navigator.of(context).pop(),
        cartManager: widget.cartManager,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review your order',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Confirm your details before placing it',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.totalItems} ${widget.totalItems == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _addressSection(),
                const SizedBox(height: 16),
                _deliverySection(),
                const SizedBox(height: 16),
                _paymentSection(),
                const SizedBox(height: 16),
                _tipSection(),
                const SizedBox(height: 16),
                _summarySection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : _checkoutBar(),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _addressSection() {
    return _sectionCard(
      icon: Icons.location_on_outlined,
      title: 'Delivery address',
      child: Form(
        key: _addressFormKey,
        child: AddressInput(
          initialAddress: _address,
          requireSubdivision: SupabaseSettings.isConfigured,
          requirePin: SupabaseSettings.isConfigured,
          showMapPicker: true,
          onChanged: (address) => _address = address,
        ),
      ),
    );
  }

  Widget _deliverySection() {
    return _sectionCard(
      icon: Icons.two_wheeler_outlined,
      title: 'Delivery preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            value: contactlessDelivery,
            onChanged: (value) => setState(() => contactlessDelivery = value),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Contactless delivery',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Your rider will leave the order at your door',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Instructions for your rider'),
          TextField(
            controller: instructionsController,
            maxLines: 2,
            decoration: _fieldDecoration('Add a note (optional)'),
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() {
    return _sectionCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Payment method',
      child: payments.isEmpty
          ? const Text('No payment methods available')
          : Column(
              children: [
                for (var index = 0; index < payments.length; index++) ...[
                  if (index > 0) const SizedBox(height: 8),
                  _paymentOption(payments[index]),
                ],
              ],
            ),
    );
  }

  Widget _paymentOption(PaymentModes method) {
    final isSelected = selectedPayment == method.name;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.5 : 1,
      ),
    );

    return Material(
      color: isSelected ? AppColors.surface : AppColors.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => selectedPayment = method.name),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: Image.asset(
                  method.logo,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.credit_card,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  method.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipSection() {
    return _sectionCard(
      icon: Icons.volunteer_activism_outlined,
      title: 'Tip your rider',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A little extra goes directly to your rider',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tipOption(0, 'No tip'),
              _tipOption(5, '₱5'),
              _tipOption(10, '₱10'),
              _tipOption(20, '₱20'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipOption(double amount, String label) {
    final isSelected = tipAmount == amount;
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => setState(() => tipAmount = amount),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _summarySection() {
    return _sectionCard(
      icon: Icons.receipt_long_outlined,
      title: 'Order summary',
      child: Column(
        children: [
          _summaryRow('Subtotal', widget.subtotal),
          const SizedBox(height: 10),
          _summaryRow('Delivery fee', widget.deliveryFee),
          if (tipAmount > 0) ...[
            const SizedBox(height: 10),
            _summaryRow('Rider tip', tipAmount),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _summaryRow('Total', widget.totalAmount + tipAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _checkoutBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total to pay',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '₱${(widget.totalAmount + tipAmount).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savingOrder || _orderPlaced
                          ? null
                          : _placeOrder,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        'Place order',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
