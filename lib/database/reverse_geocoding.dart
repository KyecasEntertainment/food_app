import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReverseGeocoding {
  static Future<String> lookup(LatLng pin) async {
    final response = await Supabase.instance.client.functions.invoke(
      'reverse-geocode',
      body: {'latitude': pin.latitude, 'longitude': pin.longitude},
    );
    if (response.status != 200 || response.data is! Map) {
      throw StateError('Address lookup failed');
    }
    final address = (response.data as Map)['formatted_address'];
    if (address is! String || address.trim().isEmpty) {
      throw StateError('No address found');
    }
    return address.trim();
  }
}
