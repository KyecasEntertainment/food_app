import 'address.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.kind,
    required this.name,
    required this.address,
    this.isSelected = false,
  });

  final String id;
  final String kind;
  final String name;
  final Address address;
  final bool isSelected;

  bool get needsReview =>
      !address.isComplete ||
      address.unitHouseLotNumber.trim().isEmpty ||
      address.street.trim().isEmpty ||
      address.subdivisionVillage.trim().isEmpty ||
      address.barangay.trim().isEmpty ||
      address.municipality.trim().isEmpty ||
      address.province.trim().isEmpty;

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as String,
    kind: json['label_kind'] as String? ?? 'Custom',
    name: json['name'] as String? ?? 'Address',
    address: Address.fromJson(json),
    isSelected: json['is_selected'] as bool? ?? false,
  );
}
