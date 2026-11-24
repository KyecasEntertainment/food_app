import 'package:flutter/foundation.dart';
import 'package:food_app/database/address.dart';

class DeliveryAddress {
  static const String defaultAddress = '';

  static final ValueNotifier<Address> structured = ValueNotifier(Address.empty);

  static final ValueNotifier<String> current = ValueNotifier<String>(
    defaultAddress,
  );

  static void setAddress(Address address) {
    structured.value = address;
    current.value = address.displayText;
  }
}
