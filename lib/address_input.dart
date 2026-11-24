import 'package:flutter/material.dart';
import 'package:food_app/database/address.dart';

class AddressInput extends StatefulWidget {
  const AddressInput({
    super.key,
    required this.initialAddress,
    required this.onChanged,
  });

  final Address initialAddress;
  final ValueChanged<Address> onChanged;

  @override
  State<AddressInput> createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  late final TextEditingController unit;
  late final TextEditingController subdivision;
  late final TextEditingController barangay;
  late final TextEditingController municipality;
  late final TextEditingController latitude;
  late final TextEditingController longitude;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    unit = TextEditingController(text: address.unitHouseLotNumber);
    subdivision = TextEditingController(text: address.subdivisionVillage);
    barangay = TextEditingController(text: address.barangay);
    municipality = TextEditingController(text: address.municipality);
    latitude = TextEditingController(text: address.latitude?.toString() ?? '');
    longitude = TextEditingController(
      text: address.longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    for (final controller in [
      unit,
      subdivision,
      barangay,
      municipality,
      latitude,
      longitude,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changed(String _) {
    final lat = double.tryParse(latitude.text.trim());
    final lng = double.tryParse(longitude.text.trim());
    widget.onChanged(
      Address(
        unitHouseLotNumber: unit.text.trim(),
        subdivisionVillage: subdivision.text.trim(),
        barangay: barangay.text.trim(),
        municipality: municipality.text.trim(),
        latitude: lat != null && lng != null ? lat : null,
        longitude: lat != null && lng != null ? lng : null,
      ),
    );
  }

  String? _coordinateValidator(String? value, {required bool isLatitude}) {
    final text = value?.trim() ?? '';
    final other = isLatitude ? longitude.text.trim() : latitude.text.trim();
    if (text.isEmpty && other.isEmpty) return null;
    final number = double.tryParse(text);
    final limit = isLatitude ? 90 : 180;
    if (number == null || !number.isFinite || number.abs() > limit) {
      return 'Enter a valid ${isLatitude ? 'latitude' : 'longitude'}';
    }
    return null;
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: _changed,
      validator:
          validator ??
          (value) => required && (value == null || value.trim().isEmpty)
              ? 'Required'
              : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _field('Unit / House / Lot number', unit, required: true),
      _field('Subdivision / Village', subdivision),
      _field('Barangay', barangay, required: true),
      _field('Municipality', municipality, required: true),
      _field(
        'Map pin latitude (optional)',
        latitude,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        validator: (value) => _coordinateValidator(value, isLatitude: true),
      ),
      _field(
        'Map pin longitude (optional)',
        longitude,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        validator: (value) => _coordinateValidator(value, isLatitude: false),
      ),
    ],
  );
}
