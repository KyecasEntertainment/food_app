import 'package:flutter/foundation.dart';

class DeliveryAddress {
  static const String defaultAddress =
      '123 Main Street, Baybay, Los Baños, Laguna';

  static final ValueNotifier<String> current = ValueNotifier<String>(
    defaultAddress,
  );
}
