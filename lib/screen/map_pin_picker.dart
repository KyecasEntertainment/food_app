import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPinPicker extends StatefulWidget {
  const MapPinPicker({super.key, this.initialLatitude, this.initialLongitude});

  final double? initialLatitude;
  final double? initialLongitude;

  static bool get supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  State<MapPinPicker> createState() => _MapPinPickerState();
}

class _MapPinPickerState extends State<MapPinPicker> {
  late bool _hasPin =
      widget.initialLatitude != null && widget.initialLongitude != null;
  late LatLng _selected = LatLng(
    widget.initialLatitude ?? 14.5995,
    widget.initialLongitude ?? 120.9842,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose delivery pin')),
    body: Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
            onTap: (position) => setState(() {
              _selected = position;
              _hasPin = true;
            }),
            markers: {
              Marker(markerId: const MarkerId('delivery'), position: _selected),
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${_selected.latitude.toStringAsFixed(6)}, '
                  '${_selected.longitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasPin
                        ? () => Navigator.of(context).pop(_selected)
                        : null,
                    child: const Text('Use this pin'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
