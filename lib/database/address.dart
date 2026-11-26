class Address {
  final String formattedAddress;
  final String unitHouseLotNumber;
  final String street;
  final String subdivisionVillage;
  final String barangay;
  final String municipality;
  final String province;
  final double? latitude;
  final double? longitude;

  const Address({
    this.formattedAddress = '',
    required this.unitHouseLotNumber,
    this.street = '',
    required this.subdivisionVillage,
    required this.barangay,
    required this.municipality,
    this.province = '',
    this.latitude,
    this.longitude,
  }) : assert((latitude == null) == (longitude == null));

  static const empty = Address(
    unitHouseLotNumber: '',
    subdivisionVillage: '',
    barangay: '',
    municipality: '',
  );

  String get displayText => formattedAddress.trim().isNotEmpty
      ? formattedAddress.trim()
      : [
          unitHouseLotNumber,
          street,
          subdivisionVillage,
          barangay,
          municipality,
          province,
        ].where((part) => part.trim().isNotEmpty).join(', ');

  bool get isComplete =>
      displayText.isNotEmpty &&
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude!.abs() <= 90 &&
      longitude!.abs() <= 180;

  Map<String, dynamic> toJson() => {
    'formatted_address': displayText,
    'unit_house_lot_number': unitHouseLotNumber,
    'street': street,
    'subdivision_village': subdivisionVillage,
    'barangay': barangay,
    'municipality': municipality,
    'province': province,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    formattedAddress: json['formatted_address'] as String? ?? '',
    unitHouseLotNumber: json['unit_house_lot_number'] as String? ?? '',
    street: json['street'] as String? ?? '',
    subdivisionVillage: json['subdivision_village'] as String? ?? '',
    barangay: json['barangay'] as String? ?? '',
    municipality: json['municipality'] as String? ?? '',
    province: json['province'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}
