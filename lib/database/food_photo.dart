import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_settings.dart';

/// Catalog rows store Storage object keys; UI artwork remains Flutter assets.
ImageProvider foodPhotoProvider(String path) {
  if (!SupabaseSettings.isConfigured || path.startsWith('assets/')) {
    return AssetImage(path);
  }
  final url = Supabase.instance.client.storage
      .from('food-photos')
      .getPublicUrl(path);
  return NetworkImage(url);
}
