import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/common/services/address_services.dart';
import 'package:shopsphere/models/address.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressBox extends StatefulWidget {
  const AddressBox({Key? key}) : super(key: key);

  @override
  State<AddressBox> createState() => _AddressBoxState();
}

class _AddressBoxState extends State<AddressBox> {
  Addresses? selectedAddress;
  List<Addresses> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final selectedAddressId = Provider.of<CartProvider>(context, listen: false).selectedShippingAddressId;
    if (user == null) return;

    addresses = await AddressServices().fetchAddresses(userId: user.id, context: context);

    if (addresses.isNotEmpty) {
      if (selectedAddressId.isNotEmpty) {
        selectedAddress = addresses.firstWhere(
          (a) => a.id == selectedAddressId,
          orElse: () => addresses.first,
        );
      } else {
        selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }
    } else {
      selectedAddress = null;
    }
    setState(() {
      isLoading = false;
    });
  }

  void _handleSelectedAddressChange(Addresses? address) {
    if (address == null) return;
    Provider.of<CartProvider>(context, listen: false).updateShippingAddressId(address.id);
    setState(() {
      selectedAddress = address;
    });
    Navigator.pop(context);
  }

  void _openAddressSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
                left: 16.0,
                right: 16.0,
                bottom: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                children: addresses.map((a) => ListTile(
                  selected: selectedAddress == a,
                  selectedColor: Colors.cyan,
                  title: Text('${a.name}, ${a.pinCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${a.address}, ${a.city}, ${a.state}, ${a.pinCode}"),
                  onTap: () => _handleSelectedAddressChange(a),
                )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    // If user is not logged in, show login message
    if (user == null) {
      return Container(
        height: 40,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 114, 226, 221),
              Color.fromARGB(255, 162, 236, 233),
            ],
            stops: [0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: () {
            // Navigate to login screen
            Navigator.pushNamed(context, '/auth-screen');
          },
          child: Row(
            children: [
              Icon(
                Icons.login_outlined,
                size: 20,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    'Sign in to see saved addresses',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }

    String addressText;
    if (isLoading) {
      addressText = 'Loading address...';
    } else if (selectedAddress != null) {
      addressText =
          '${selectedAddress!.name}, ${selectedAddress!.address}, ${selectedAddress!.city}, ${selectedAddress!.state}, ${selectedAddress!.pinCode}';
    } else {
      addressText = 'Delivery to ${user.name}';
    }

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 114, 226, 221),
            Color.fromARGB(255, 162, 236, 233),
          ],
          stops: [0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                addressText,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
              top: 2,
            ),
            child: IconButton(
              onPressed: _openAddressSelector,
              icon: const Icon(
              Icons.arrow_drop_down_outlined,
              size: 18,
            ),
            )
          )
        ],
      ),
    );
  }
}
