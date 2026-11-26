import 'package:flutter/material.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/reverse_geocoding.dart';
import 'package:food_app/screen/map_pin_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A confirmed delivery location: a readable address and one map pin.
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
  late final TextEditingController address;
  late final TextEditingController latitude;
  late final TextEditingController longitude;
  bool _lookingUp = false;
  String? _lookupError;

  @override
  void initState() {
    super.initState();
    address = TextEditingController(text: widget.initialAddress.displayText);
    latitude = TextEditingController(
      text: widget.initialAddress.latitude?.toString() ?? '',
    );
    longitude = TextEditingController(
      text: widget.initialAddress.longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    address.dispose();
    latitude.dispose();
    longitude.dispose();
    super.dispose();
  }

  void _changed([String? _]) {
    final lat = double.tryParse(latitude.text.trim());
    final lng = double.tryParse(longitude.text.trim());
    widget.onChanged(
      Address(
        formattedAddress: address.text.trim(),
        unitHouseLotNumber: '',
        subdivisionVillage: '',
        barangay: '',
        municipality: '',
        latitude: lat != null && lng != null ? lat : null,
        longitude: lat != null && lng != null ? lng : null,
      ),
    );
  }

  Future<void> _pickOnMap() async {
    final currentLatitude = double.tryParse(latitude.text);
    final currentLongitude = double.tryParse(longitude.text);
    final pin = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPinPicker(
          initialLatitude: currentLatitude,
          initialLongitude: currentLongitude,
        ),
      ),
    );
    if (pin == null || !mounted) return;
    latitude.text = pin.latitude.toStringAsFixed(6);
    longitude.text = pin.longitude.toStringAsFixed(6);
    address.clear();
    _changed();
    setState(() {
      _lookingUp = true;
      _lookupError = null;
    });
    try {
      final found = await ReverseGeocoding.lookup(pin);
      if (!mounted) return;
      address.text = found;
    } catch (_) {
      _lookupError = 'Could not find an address for this pin. Enter it below.';
    } finally {
      if (mounted) {
        setState(() => _lookingUp = false);
        _changed();
        Form.maybeOf(context)?.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _lookingUp || !MapPinPicker.supportedPlatform
              ? null
              : _pickOnMap,
          icon: const Icon(Icons.map_outlined),
          label: const Text('Pin address on Google Maps'),
        ),
      ),
      if (!MapPinPicker.supportedPlatform)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Google Maps is available on Android and iOS.'),
        ),
      if (_lookingUp) const LinearProgressIndicator(),
      if (_lookupError != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(_lookupError!),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: address,
          maxLines: 2,
          onChanged: _changed,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Confirm a delivery address'
              : null,
          decoration: const InputDecoration(
            labelText: 'Delivery address',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          latitude.text.isEmpty || longitude.text.isEmpty
              ? 'Choose a pin to fill latitude and longitude.'
              : 'Latitude: ${latitude.text}  Longitude: ${longitude.text}',
        ),
      ),
    ],
  );
}
