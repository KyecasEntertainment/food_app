import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database/supabase_settings.dart';

class AvatarImage extends StatefulWidget {
  const AvatarImage({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final Widget placeholder;
  final BoxFit fit;

  @override
  State<AvatarImage> createState() => _AvatarImageState();
}

class _AvatarImageState extends State<AvatarImage> {
  Future<String>? _signedUrl;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(covariant AvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _refresh();
  }

  void _refresh() {
    _refreshTimer?.cancel();
    final path = widget.path;
    _signedUrl = path == null || path.isEmpty || path.startsWith('assets/') ||
            !SupabaseSettings.isConfigured
        ? null
        : Supabase.instance.client.storage
              .from('user-avatars')
              .createSignedUrl(path, 3600);
    if (_signedUrl != null) {
      _refreshTimer = Timer(const Duration(minutes: 55), () {
        if (mounted) setState(_refresh);
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    if (path == null || path.isEmpty) return widget.placeholder;
    if (!SupabaseSettings.isConfigured || path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: widget.fit,
        errorBuilder: (_, _, _) => widget.placeholder,
      );
    }
    return FutureBuilder<String>(
      future: _signedUrl,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return widget.placeholder;
        return Image.network(
          snapshot.data!,
          fit: widget.fit,
          errorBuilder: (_, _, _) => widget.placeholder,
        );
      },
    );
  }
}
