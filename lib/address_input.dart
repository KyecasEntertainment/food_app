import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/screen/map_pin_picker.dart';

class AddressInput extends StatefulWidget {
  const AddressInput({
    super.key,
    required this.initialAddress,
    required this.onChanged,
    this.requirePin = false,
    this.requireSubdivision = false,
    this.showMapPicker = false,
  });

  final Address initialAddress;
  final ValueChanged<Address> onChanged;
  final bool requirePin;
  final bool requireSubdivision;
  final bool showMapPicker;

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
    if (text.isEmpty && other.isEmpty && !widget.requirePin) return null;
    final number = double.tryParse(text);
    final limit = isLatitude ? 90 : 180;
    if (number == null || !number.isFinite || number.abs() > limit) {
      return 'Enter a valid ${isLatitude ? 'latitude' : 'longitude'}';
    }
    return null;
  }

  Future<void> _pickOnMap() async {
    final lat = double.tryParse(latitude.text);
    final lng = double.tryParse(longitude.text);
    final pin = await Navigator.of(context).push(
      MaterialPageRoute<LatLng>(
        builder: (_) => MapPinPicker(
          initialLatitude: lat != null && lat.isFinite && lat.abs() <= 90
              ? lat
              : null,
          initialLongitude: lng != null && lng.isFinite && lng.abs() <= 180
              ? lng
              : null,
        ),
      ),
    );
    if (pin == null || !mounted) return;
    latitude.text = pin.latitude.toStringAsFixed(6);
    longitude.text = pin.longitude.toStringAsFixed(6);
    _changed('');
    Form.of(context).validate();
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
      _field(
        'Subdivision / Village',
        subdivision,
        required: widget.requireSubdivision,
      ),
      _field('Barangay', barangay, required: true),
      _field('Municipality', municipality, required: true),
      if (widget.showMapPicker) ...[
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: MapPinPicker.enabled && MapPinPicker.supportedPlatform
                ? _pickOnMap
                : null,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Pick pin on Google Maps'),
          ),
        ),
        if (!MapPinPicker.enabled || !MapPinPicker.supportedPlatform)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Map picker needs a Google Maps API key. '
              'Enter the coordinates below for now.',
            ),
          ),
      ],
      _field(
        widget.requirePin ? 'Map pin latitude' : 'Map pin latitude (optional)',
        latitude,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        validator: (value) => _coordinateValidator(value, isLatitude: true),
      ),
      _field(
        widget.requirePin
            ? 'Map pin longitude'
            : 'Map pin longitude (optional)',
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
