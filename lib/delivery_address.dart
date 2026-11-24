import 'package:flutter/foundation.dart';

class DeliveryAddress {
  static final ValueNotifier<String> current = ValueNotifier<String>(
    '123 Main Street, Baybay, Los Baños, Laguna',
  );
}
