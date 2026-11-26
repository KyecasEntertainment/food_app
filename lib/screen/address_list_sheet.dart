import 'package:flutter/material.dart';
import 'package:food_app/database/saved_address.dart';
import 'package:food_app/database/saved_address_repository.dart';
import 'package:food_app/delivery_address.dart';
import 'package:food_app/screen/address_screen.dart';

Future<void> showAddressList(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddressListSheet(parentContext: context),
    );

class _AddressListSheet extends StatefulWidget {
  const _AddressListSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  State<_AddressListSheet> createState() => _AddressListSheetState();
}

class _AddressListSheetState extends State<_AddressListSheet> {
  bool _selecting = false;

  Future<void> _openForm([SavedAddress? existing]) async {
    Navigator.of(context).pop();
    await Navigator.of(widget.parentContext).push<bool>(
      MaterialPageRoute(builder: (_) => AddressScreen(existing: existing)),
    );
  }

  Future<void> _select(SavedAddress entry) async {
    if (_selecting || entry.needsReview) return;
    setState(() => _selecting = true);
    try {
      await SavedAddressRepository.select(entry.id);
      DeliveryAddress.replaceSaved(await SavedAddressRepository.load());
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not select this address.')),
        );
      }
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: ValueListenableBuilder<List<SavedAddress>>(
        valueListenable: DeliveryAddress.saved,
        builder: (context, addresses, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your addresses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (addresses.isEmpty)
              ListTile(
                leading: const Icon(Icons.add_location_alt_outlined),
                title: const Text('+ Set your address'),
                onTap: () => _openForm(),
              )
            else ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final entry = addresses[index];
                    return ListTile(
                      leading: Icon(
                        entry.isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(entry.name),
                      subtitle: Text(
                        entry.needsReview
                            ? 'Review address details before selecting'
                            : entry.address.displayText,
                      ),
                      isThreeLine: true,
                      onTap: entry.needsReview
                          ? () => _openForm(entry)
                          : () => _select(entry),
                      trailing: IconButton(
                        tooltip: 'Edit ${entry.name}',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(entry),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('+ Add Address'),
                onTap: () => _openForm(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
