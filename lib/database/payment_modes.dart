class PaymentModes {
  final String name;
  final String logo;

  PaymentModes({required this.name, required this.logo});
}

final List<PaymentModes> payments = [
  PaymentModes(
    name: "Gcash",
    logo: "assets/logo/payment_modes/payment_mode_1.png",
  ),
  PaymentModes(
    name: "Maya",
    logo: "assets/logo/payment_modes/payment_mode_2.png",
  ),
  PaymentModes(
    name: "COD",
    logo: "assets/logo/payment_modes/payment_mode_3.png",
  ),
  PaymentModes(
    name: "Bank",
    logo: "assets/logo/payment_modes/payment_mode_4.png",
  ),
];
