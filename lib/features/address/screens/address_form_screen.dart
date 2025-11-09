import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/common/services/address_services.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/models/region.dart';
import 'package:shopsphere/providers/user_provider.dart';

class AddressFormScreen extends StatefulWidget {
  static const String routeName = '/address-form';
  final Addresses? address;

  const AddressFormScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressServices addressServices = AddressServices();
  bool _isLoading = false;
  List<Region> _regions = [];
  Region? _selectedCountry;
  States? _selectedState;

  late TextEditingController _nameController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _addressController;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _pinCodeController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _primaryPhoneController = TextEditingController(text: widget.address?.primaryPhone.toString() ?? '');
    _secondaryPhoneController = TextEditingController(text: widget.address?.secondaryPhone?.toString() ?? '');
    _addressController = TextEditingController(text: widget.address?.address ?? '');
    _address2Controller = TextEditingController(text: widget.address?.address2 ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _pinCodeController = TextEditingController(text: widget.address?.pinCode.toString() ?? '');
    _isDefault = widget.address?.isDefault ?? false;
    _fetchRegions();
  }

  void _fetchRegions() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    final regions = await addressServices.fetchAllRegions(
      userId: userId,
      context: context,
    );
    
    setState(() {
      _regions = regions;
      if (widget.address != null) {
        _selectedCountry = regions.firstWhere(
          (region) => region.countryAbbreviation == widget.address!.country,
          orElse: () => regions.first,
        );
        if (_selectedCountry?.states != null) {
          _selectedState = _selectedCountry!.states!.firstWhere(
            (state) => state.stateAbbreviation == widget.address!.state,
            orElse: () => _selectedCountry!.states!.first,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _addressController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && _selectedCountry != null) {
      setState(() => _isLoading = true);
      
      final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
      final addressData = {
        'name': _nameController.text,
        'primaryPhone': int.parse(_primaryPhoneController.text),
        'secondaryPhone': _secondaryPhoneController.text.isEmpty
            ? null
            : int.parse(_secondaryPhoneController.text),
        'address': _addressController.text,
        'address2': _address2Controller.text,
        'city': _cityController.text,
        'state': _selectedState?.stateAbbreviation ?? '',
        'country': _selectedCountry!.countryAbbreviation,
        'pinCode': int.parse(_pinCodeController.text),
        'isDefault': _isDefault,
      };

      if (widget.address != null) {
        // Update existing address
        await addressServices.updateAddress(
          context: context,
          id: userId,
          addressId: widget.address!.id,
          addressData: addressData,
        );
      } else {
        // Create new address
        await addressServices.createAddress(
          context: context,
          id: userId,
          addressData: addressData,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          widget.address != null ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter full name',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _primaryPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Primary Phone',
                        hintText: 'Enter primary phone number',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter primary phone number';
                        }
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _secondaryPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Secondary Phone (Optional)',
                        hintText: 'Enter secondary phone number',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.phone_android),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address Line 1',
                        hintText: 'Enter street address',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _address2Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 2',
                        hintText: 'Enter apartment, suite, etc.',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        hintText: 'Enter city',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Region>(
                      value: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        hintText: 'Select country',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.public),
                      ),
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      items: _regions.map((Region region) {
                        return DropdownMenuItem<Region>(
                          value: region,
                          child: Text(region.countryName),
                        );
                      }).toList(),
                      onChanged: (Region? newValue) {
                        setState(() {
                          _selectedCountry = newValue;
                          _selectedState = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_selectedCountry?.states != null && _selectedCountry!.states!.isNotEmpty)
                      DropdownButtonFormField<States>(
                        value: _selectedState,
                        decoration: InputDecoration(
                          labelText: 'State',
                          hintText: 'Select state',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                          ),
                          prefixIcon: const Icon(Icons.map),
                        ),
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                        items: _selectedCountry!.states!.map((States state) {
                          return DropdownMenuItem<States>(
                            value: state,
                            child: Text(state.stateName),
                          );
                        }).toList(),
                        onChanged: (States? newValue) {
                          setState(() {
                            _selectedState = newValue;
                          });
                        },
                        validator: (value) {
                          if (_selectedCountry?.states != null && 
                              _selectedCountry!.states!.isNotEmpty && 
                              value == null) {
                            return 'Please select a state';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _pinCodeController,
                      decoration: InputDecoration(
                        labelText: 'PIN Code',
                        hintText: 'Enter PIN code',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GlobalVariables.secondaryColor, width: 1),
                        ),
                        prefixIcon: const Icon(Icons.pin_drop),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter PIN code';
                        }
                        if (value.length < 5) {
                          return 'PIN code must be at least 5 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Set as Default Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'This will be used as your primary delivery address',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isDefault,
                        onChanged: (bool value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                        activeColor: GlobalVariables.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: GlobalVariables.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.address != null ? 'Update Address' : 'Add Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
    );
  }
}