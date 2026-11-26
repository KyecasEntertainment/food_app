import 'package:flutter/material.dart';
import 'package:food_app/address_input.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/delivery_address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressSetupScreen extends StatefulWidget {
  const AddressSetupScreen({
    super.key,
    required this.account,
    required this.onSaved,
  });

  final UserAccounts account;
  final VoidCallback onSaved;

  @override
  State<AddressSetupScreen> createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late Address _address = widget.account.address;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    if (!_address.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a pin and confirm its address.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await activeRepository.saveAccount(
        widget.account.copyWith(address: _address),
      );
      DeliveryAddress.setAddress(_address);
      if (mounted) widget.onSaved();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your address. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      DeliveryAddress.setAddress(Address.empty);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not sign out. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Set delivery address'),
      actions: [TextButton(onPressed: _signOut, child: const Text('Sign out'))],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Pin your delivery location, then confirm the address Google finds.',
                ),
                const SizedBox(height: 20),
                AddressInput(
                  initialAddress: widget.account.address,
                  onChanged: (address) => setState(() => _address = address),
                ),
                const SizedBox(height: 16),
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
  );
}
