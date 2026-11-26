import 'package:flutter/foundation.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/saved_address.dart';

class DeliveryAddress {
  static const String defaultAddress = '';

  static final ValueNotifier<Address> structured = ValueNotifier(Address.empty);
  static final ValueNotifier<List<SavedAddress>> saved =
      ValueNotifier<List<SavedAddress>>(const []);

  static final ValueNotifier<String> current = ValueNotifier<String>(
    defaultAddress,
  );

  static void setAddress(Address address) {
    structured.value = address;
    current.value = address.displayText;
  }

  static SavedAddress? get selected {
    for (final entry in saved.value) {
      if (entry.isSelected) return entry;
    }
    return null;
  }

  static void replaceSaved(List<SavedAddress> addresses) {
    saved.value = List.unmodifiable(addresses);
    setAddress(selected?.address ?? Address.empty);
  }

  static void clear() => replaceSaved(const []);
}
