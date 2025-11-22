class PaymentModes {
  final String payment_name;
  final String payment_logo;

  PaymentModes({
    required this.payment_name,
    required this.payment_logo,
  });
}

final List<PaymentModes> payments = [
  PaymentModes(payment_name: "Gcash", payment_logo: "assets/logo/payment_modes/payment_mode_1.png"),
  PaymentModes(payment_name: "Maya", payment_logo: "assets/logo/payment_modes/payment_mode_2.png"),
  PaymentModes(payment_name: "COD", payment_logo: "assets/logo/payment_modes/payment_mode_3.png"),
  PaymentModes(payment_name: "Bank", payment_logo: "assets/logo/payment_modes/payment_mode_4.png"),
];
