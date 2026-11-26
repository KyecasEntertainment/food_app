import 'package:flutter/material.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/reverse_geocoding.dart';
import 'package:food_app/database/saved_address.dart';
import 'package:food_app/database/saved_address_repository.dart';
import 'package:food_app/delivery_address.dart';
import 'package:food_app/screen/map_pin_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key, this.existing});

  final SavedAddress? existing;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _kind = widget.existing?.kind ?? 'Home';
  late final _name = TextEditingController(
    text: widget.existing?.kind == 'Custom' ? widget.existing!.name : '',
  );
  late final _unit = TextEditingController(
    text: widget.existing?.address.unitHouseLotNumber ?? '',
  );
  late final _street = TextEditingController(
    text: widget.existing?.address.street ?? '',
  );
  late final _village = TextEditingController(
    text: widget.existing?.address.subdivisionVillage ?? '',
  );
  late final _barangay = TextEditingController(
    text: widget.existing?.address.barangay ?? '',
  );
  late final _city = TextEditingController(
    text: widget.existing?.address.municipality ?? '',
  );
  late final _province = TextEditingController(
    text: widget.existing?.address.province ?? '',
  );
  late LatLng? _pin =
      widget.existing?.address.latitude == null ||
          widget.existing?.address.longitude == null
      ? null
      : LatLng(
          widget.existing!.address.latitude!,
          widget.existing!.address.longitude!,
        );
  String? _mapHint;
  bool _lookingUp = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _unit,
      _street,
      _village,
      _barangay,
      _city,
      _province,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _setPin(LatLng pin) async {
    setState(() {
      _pin = pin;
      _lookingUp = true;
      _mapHint = null;
    });
    try {
      final hint = await ReverseGeocoding.lookup(pin);
      if (mounted && _pin == pin) setState(() => _mapHint = hint);
    } catch (_) {
      if (mounted && _pin == pin) {
        setState(() => _mapHint = 'Pin saved. Enter the address below.');
      }
    } finally {
      if (mounted && _pin == pin) setState(() => _lookingUp = false);
    }
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    if (_pin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a location on the map.')),
      );
      return;
    }
    final parts = [
      _unit.text.trim(),
      _street.text.trim(),
      _village.text.trim(),
      _barangay.text.trim(),
      _city.text.trim(),
      _province.text.trim(),
    ];
    final address = Address(
      formattedAddress: parts.join(', '),
      unitHouseLotNumber: parts[0],
      street: parts[1],
      subdivisionVillage: parts[2],
      barangay: parts[3],
      municipality: parts[4],
      province: parts[5],
      latitude: _pin!.latitude,
      longitude: _pin!.longitude,
    );
    setState(() => _saving = true);
    try {
      await SavedAddressRepository.save(
        id: widget.existing?.id,
        kind: _kind,
        name: _kind == 'Custom' ? _name.text.trim() : _kind,
        address: address,
      );
      DeliveryAddress.replaceSaved(await SavedAddressRepository.load());
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your address.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String label, TextEditingController controller) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: MapPinPicker.supportedPlatform
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _pin ?? const LatLng(14.5995, 120.9842),
                    zoom: 15,
                  ),
                  onTap: _setPin,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  markers: _pin == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('address'),
                            position: _pin!,
                            draggable: true,
                            onDragEnd: _setPin,
                          ),
                        },
                )
              : const ColoredBox(
                  color: Color(0xFFE8ECE8),
                  child: Center(
                    child: Text(
                      'Map pin selection is available on Android and iOS.',
                    ),
                  ),
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DraggableScrollableSheet(
            initialChildSize: 0.46,
            minChildSize: 0.18,
            maxChildSize: 0.94,
            snap: true,
            snapSizes: const [0.46, 0.94],
            expand: false,
            builder: (context, scrollController) => Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.existing == null
                            ? 'Add address'
                            : 'Edit address',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pin == null
                            ? 'Move the map and tap to place a pin.'
                            : '${_pin!.latitude.toStringAsFixed(6)}, ${_pin!.longitude.toStringAsFixed(6)}',
                      ),
                      if (_lookingUp) const LinearProgressIndicator(),
                      if (_mapHint != null) Text(_mapHint!),
                      const SizedBox(height: 20),
                      const Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Home', 'Work', 'Custom']
                            .map(
                              (kind) => ChoiceChip(
                                label: Text(kind),
                                selected: _kind == kind,
                                onSelected: (_) => setState(() => _kind = kind),
                              ),
                            )
                            .toList(),
                      ),
                      if (_kind == 'Custom') ...[
                        const SizedBox(height: 12),
                        _field('Custom name', _name),
                      ],
                      const SizedBox(height: 12),
                      _field('Unit/Floor/Building', _unit),
                      _field('Street', _street),
                      _field('Village/Subdivision', _village),
                      _field('Barangay', _barangay),
                      _field('Municipality/City', _city),
                      _field('Province', _province),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Saving...' : 'Save address'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
