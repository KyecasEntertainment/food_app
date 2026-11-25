import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_app/app_colors.dart';
import 'package:food_app/avatar_image.dart';
import 'package:food_app/address_input.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/supabase_settings.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/delivery_address.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  final UserAccounts? loggedInUser;
  final VoidCallback onCartPressed;
  final CartManager cartManager;

  const ProfilePage({
    super.key,
    this.loggedInUser,
    required this.onCartPressed,
    required this.cartManager,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserAccounts? _account;
  bool _uploadingAvatar = false;
  late String firstName;
  late String lastName;
  late String email;
  late String contact;

  @override
  void initState() {
    super.initState();
    _account = widget.loggedInUser;
    firstName = widget.loggedInUser?.firstName ?? 'John';
    lastName = widget.loggedInUser?.lastName ?? 'Doe';
    email = widget.loggedInUser?.email ?? 'johndoe@example.com';
    contact = '+639934229236';
  }

  String get name => '$firstName $lastName'.trim();

  Future<bool> _saveProfile({
    String? first,
    String? last,
    String? newEmail,
    Address? address,
  }) async {
    final account = _account;
    if (account == null) return false;
    try {
      final updated = account.copyWith(
        firstName: first ?? firstName,
        lastName: last ?? lastName,
        email: newEmail ?? email,
        address: address ?? DeliveryAddress.structured.value,
      );
      await activeRepository.saveAccount(updated);
      if (mounted) setState(() => _account = updated);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile changes.')),
        );
      }
      return false;
    }
  }

  Future<void> _pickAvatar() async {
    final account = _account;
    if (account == null || _uploadingAvatar || !SupabaseSettings.isConfigured) {
      return;
    }
    final selected = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (selected == null || !mounted) return;
    final extension = selected.name.split('.').last.toLowerCase();
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => null,
    };
    if (mimeType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a JPG, PNG, or WebP image.')),
      );
      return;
    }
    setState(() => _uploadingAvatar = true);
    final storage = Supabase.instance.client.storage.from('user-avatars');
    String? uploadedPath;
    try {
      final bytes = await selected.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw StateError('Avatar must be 5 MB or smaller');
      }
      uploadedPath = '${account.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';
      await storage.uploadBinary(
        uploadedPath,
        bytes,
        fileOptions: FileOptions(contentType: mimeType),
      );
      final updated = account.copyWith(avatar: uploadedPath);
      await activeRepository.saveAccount(updated);
      if (mounted) setState(() => _account = updated);
      final previous = account.avatar;
      if (previous.startsWith('${account.id}/')) {
        try {
          await storage.remove([previous]);
        } catch (_) {
          // The new avatar is already saved; old-object cleanup can be retried.
        }
      }
    } catch (_) {
      if (uploadedPath != null) {
        try {
          await storage.remove([uploadedPath]);
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload your photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _editAddress() async {
    final address = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          _AddressSheet(initialAddress: DeliveryAddress.structured.value),
    );
    if (address == null || !mounted) return;
    if (await _saveProfile(address: address)) {
      DeliveryAddress.setAddress(address);
    }
  }

  Future<void> _editField({
    required String label,
    required String value,
    required ValueChanged<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final updated = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _EditFieldSheet(
        label: label,
        initialValue: value,
        keyboardType: keyboardType,
      ),
    );

    if (mounted && updated != null) onSaved(updated);
  }

  Future<void> _logOut() async {
    try {
      if (SupabaseSettings.isConfigured) {
        await Supabase.instance.client.auth.signOut();
      }
      DeliveryAddress.setAddress(Address.empty);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not sign out. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showAddress: true,
        onCartPressed: widget.onCartPressed,
        cartManager: widget.cartManager,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _profileHero(),
            const SizedBox(height: 28),
            _sectionHeading('Personal details', 'Tap a field to update it'),
            const SizedBox(height: 12),
            Material(
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _detailRow(
                    icon: Icons.person_outline,
                    label: 'First name',
                    value: firstName,
                    onTap: () => _editField(
                      label: 'First name',
                      value: firstName,
                      onSaved: (value) {
                        setState(() => firstName = value);
                        _saveProfile(first: value);
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  _detailRow(
                    icon: Icons.person_outline,
                    label: 'Last name',
                    value: lastName,
                    onTap: () => _editField(
                      label: 'Last name',
                      value: lastName,
                      onSaved: (value) {
                        setState(() => lastName = value);
                        _saveProfile(last: value);
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  _detailRow(
                    icon: Icons.mail_outline,
                    label: 'Email address',
                    value: email,
                    onTap: () => _editField(
                      label: 'Email address',
                      value: email,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        setState(() => email = value);
                        _saveProfile(newEmail: value);
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  _detailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    value: contact,
                    onTap: () => _editField(
                      label: 'Phone number',
                      value: contact,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => setState(() => contact = value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _sectionHeading('Delivery', 'Your saved delivery location'),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: DeliveryAddress.current,
              builder: (context, address, _) => Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: _detailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Delivery address',
                  value: address.trim().isEmpty
                      ? 'Add delivery address'
                      : address,
                  onTap: _editAddress,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logOut,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textOnPrimary,
                  backgroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHero() {
    final avatar = _account?.avatar;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryPressed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: SupabaseSettings.isConfigured ? _pickAvatar : null,
            child: Stack(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: AvatarImage(
                      path: avatar,
                      placeholder: _avatarPlaceholder(),
                    ),
                  ),
                ),
                if (SupabaseSettings.isConfigured)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      _uploadingAvatar ? Icons.hourglass_top : Icons.camera_alt,
                      size: 19,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY PROFILE',
                  style: TextStyle(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return const ColoredBox(
      color: AppColors.surface,
      child: Icon(Icons.person, color: AppColors.primary, size: 32),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.edit_outlined, color: AppColors.primary, size: 19),
          ],
        ),
      ),
    );
  }
}

class _EditFieldSheet extends StatefulWidget {
  final String label;
  final String initialValue;
  final TextInputType keyboardType;

  const _EditFieldSheet({
    required this.label,
    required this.initialValue,
    required this.keyboardType,
  });

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({required this.initialAddress});
  final Address initialAddress;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late Address _address = widget.initialAddress;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Delivery address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AddressInput(
              initialAddress: widget.initialAddress,
              requireSubdivision: SupabaseSettings.isConfigured,
              requirePin: SupabaseSettings.isConfigured,
              showMapPicker: true,
              onChanged: (address) => _address = address,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(_address);
                  }
                },
                child: const Text('Save address'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '${widget.label} cannot be empty';
    if (widget.keyboardType == TextInputType.emailAddress &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Edit ${widget.label.toLowerCase()}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: widget.keyboardType,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                validator: _validate,
                decoration: InputDecoration(
                  labelText: widget.label,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
