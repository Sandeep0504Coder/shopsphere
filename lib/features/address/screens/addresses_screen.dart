import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/features/address/screens/address_form_screen.dart';
import 'package:shopsphere/features/address/widgets/address_card.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/common/services/address_services.dart';

class AddressesScreen extends StatefulWidget {
  static const String routeName = '/addresses';
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Addresses> addresses = [];
  bool isLoading = true;
  final AddressServices addressServices = AddressServices();

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final fetchedAddresses = await addressServices.fetchAddresses(
        userId: user.id, 
        context: context
      );
      if (mounted) {
        setState(() {
          addresses = fetchedAddresses;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          addresses = [];
          isLoading = false;
        });
      }
    }
  }

  void navigateToAddressForm([Addresses? address]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(address: address),
      ),
    );

    if (result == true) {
      setState(() => isLoading = true);
      fetchAddresses();
    }
  }

  Future<void> handleDelete(Addresses address) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        setState(() => isLoading = true);
        final success = await addressServices.deleteAddress(
          context: context,
          userId: user.id,
          addressId: address.id,
        );
        
        if (mounted) {
          if (success) {
            await fetchAddresses();
          } else {
            setState(() => isLoading = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => navigateToAddressForm(),
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : addresses.isEmpty
          ? const Center(child: Text('No addresses found'))
          : SafeArea(
            child:
            ListView.builder(
              itemCount: addresses.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => AddressCard(
                address: addresses[index],
                onEdit: () => navigateToAddressForm(addresses[index]),
                onDelete: () => handleDelete(addresses[index]),
              ),
            ),
    ));
  }
}