class Address {
  final String unitHouseLotNumber;
  final String subdivisionVillage;
  final String barangay;
  final String municipality;
  final double? latitude;
  final double? longitude;

  const Address({
    required this.unitHouseLotNumber,
    required this.subdivisionVillage,
    required this.barangay,
    required this.municipality,
    this.latitude,
    this.longitude,
  }) : assert((latitude == null) == (longitude == null));

  static const empty = Address(
    unitHouseLotNumber: '',
    subdivisionVillage: '',
    barangay: '',
    municipality: '',
  );

  String get displayText => [
    unitHouseLotNumber,
    subdivisionVillage,
    barangay,
    municipality,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  bool get isComplete =>
      unitHouseLotNumber.trim().isNotEmpty &&
      barangay.trim().isNotEmpty &&
      municipality.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    'unit_house_lot_number': unitHouseLotNumber,
    'subdivision_village': subdivisionVillage,
    'barangay': barangay,
    'municipality': municipality,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    unitHouseLotNumber: json['unit_house_lot_number'] as String? ?? '',
    subdivisionVillage: json['subdivision_village'] as String? ?? '',
    barangay: json['barangay'] as String? ?? '',
    municipality: json['municipality'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}
