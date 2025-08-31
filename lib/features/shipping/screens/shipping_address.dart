import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/common/services/address_services.dart';
import 'package:shopsphere/common/widgets/custom_textfield.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/models/region.dart';
import 'package:shopsphere/models/shipping_info.dart';
import 'package:shopsphere/models/user.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/constants/global_variables.dart';

class ShippingPage extends StatefulWidget {
  static const String routeName = "/shipping";
  const ShippingPage({super.key});

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController primaryPhoneController = TextEditingController();
  final TextEditingController secondaryPhoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  

  final AddressServices addressServices = AddressServices();

  String saveAs = "addAddress";
  String selectedCountryAbbr = "";
  String selectedStateAbbr = "";
  Address? selectedShippingAddress;

  // var shippingInfo = {
  //   "name": "",
  //   "primaryPhone": "",
  //   "secondaryPhone": "",
  //   "address": "",
  //   "address2": "",
  //   "city": "",
  //   "state": "",
  //   "country": "",
  //   "pinCode": "",
  // };

  List<States> stateOptions = [];
  List<Region> countries = []; // Populate from API
  List<Address> addresses = []; // Populate from API

  _handleSelectedAddressChange(Address? address, BuildContext context) {
    if (address == null) return;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateShippingAddressId(address.id);
    setState(() {
      selectedShippingAddress = address;
      selectedCountryAbbr = address.country;
      nameController.text = address.name;
      primaryPhoneController.text = address.primaryPhone.toString();
      secondaryPhoneController.text = address.secondaryPhone?.toString() ?? "";
      addressController.text = address.address;
      address2Controller.text = address.address2;
      cityController.text = address.city;
      selectedStateAbbr = address.state;
      pinCodeController.text = address.pinCode.toString();
      saveAs = "updateAddress";
      stateOptions = countries.firstWhere(
        (region) => region.countryAbbreviation == selectedCountryAbbr,
        orElse: () => Region(
          id: "",
          countryName: "",
          countryAbbreviation: "",
          states: [],
        ),
      ).states ?? [];
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
              const Divider(
                color: GlobalVariables.greyBackgroundColor,
              ),
            Flexible(
              child: ListView(
                children: addresses.map((a) => ListTile(
                  selected: selectedShippingAddress?.id == a.id,
                  selectedColor: GlobalVariables.appBarGradient.colors.first,
                  title: Text('${a.name}, ${a.pinCode}', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${a.address}, ${a.city}, ${a.state}, ${a.pinCode}"),
                  onTap: () {
                    _handleSelectedAddressChange(a, context);
                  },
                )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.saveShippingInfo(
      ShippingInfo(
        name: nameController.text,
        primaryPhone: primaryPhoneController.text,
        secondaryPhone: secondaryPhoneController.text.isNotEmpty ? secondaryPhoneController.text : "",
        address: addressController.text,
        address2: address2Controller.text,
        city: cityController.text,
        state: selectedStateAbbr,
        country: selectedCountryAbbr,
        pinCode: pinCodeController.text,
      )
    );

    final user = Provider.of<UserProvider>(context, listen: false).user;

    // Handle add/update logic here based on `saveAs`
    if( saveAs == "updateAddress" ){
      addressServices.updateAddress(
      context: context,
        id: user!.id,
        addressId: selectedShippingAddress!.id,
        addressData: {
          "name": nameController.text,
          "primaryPhone": primaryPhoneController.text,
          "secondaryPhone": secondaryPhoneController.text.isNotEmpty ? secondaryPhoneController.text : null,
          "address": addressController.text,
          "address2": address2Controller.text,
          "city": cityController.text,
          "state": selectedStateAbbr,
          "country": selectedCountryAbbr,
          "pinCode": pinCodeController.text,
          "isDefault": selectedShippingAddress!.isDefault
        },
      );
    } else if( saveAs == "addAddress" ){
      final addressId =  addressServices.createAddress(
        context: context,
        id: user!.id,
        addressData: {
          "name": nameController.text,
          "primaryPhone": primaryPhoneController.text,
          "secondaryPhone": secondaryPhoneController.text.isNotEmpty ? secondaryPhoneController.text : null,
          "address": addressController.text,
          "address2": address2Controller.text,
          "city": cityController.text,
          "state": selectedStateAbbr,
          "country": selectedCountryAbbr,
          "pinCode": pinCodeController.text,
          "isDefault": selectedShippingAddress!.isDefault
        },
      );

      cart.updateShippingAddressId( addressId as String );
    }

    // Send to backend or navigate to payment

    // const { data } = await axios.post( `${server}/api/v1/payment/create`,
    //     {
    //         amount: total
    //     }, {
    //         headers: {
    //         "Content-Type": "application/json",
    //         },
    //     } 
    // );

    // navigate( "/pay", {
    //     state: data.clientSecret,
    // } );
    Navigator.pushNamed(context, "/pay");
  }


  Future getShippingPageData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final cart = Provider.of<CartProvider>(context, listen: false);
    // Fetch addresses from API
    addresses = await addressServices.fetchAddresses(
      userId: user!.id,
      context: context,
    );

    final selectedAddress = addresses.firstWhere(
      (address) => cart.selectedShippingAddressId != "" ? address.id == cart.selectedShippingAddressId : address.isDefault,
      orElse: () => Address(
        id: "",
        name: "",
        primaryPhone: 0,
        secondaryPhone: null,
        address: "",
        address2: "",
        city: "",
        state: "",
        country: "",
        pinCode: 0,
        user: user.id,
        isDefault: false,
      ),
    );

    if (selectedAddress.id.isNotEmpty) {
      selectedShippingAddress = selectedAddress;
      selectedCountryAbbr = selectedAddress.country;
      nameController.text = selectedAddress.name;
      primaryPhoneController.text = selectedAddress.primaryPhone.toString();
      secondaryPhoneController.text = selectedAddress.secondaryPhone?.toString() ?? "";
      addressController.text = selectedAddress.address;
      address2Controller.text = selectedAddress.address2;
      cityController.text = selectedAddress.city;
      selectedStateAbbr = selectedAddress.state;
      pinCodeController.text = selectedAddress.pinCode.toString();
      saveAs = "updateAddress";
    }  

    countries = await addressServices.fetchAllRegions(
      userId: user.id,
      context: context,
    );

    if (selectedCountryAbbr != "") {
      stateOptions = countries.firstWhere(
        (region) => region.countryAbbreviation == selectedCountryAbbr,
        orElse: () => Region(
          id: "",
          countryName: "",
          countryAbbreviation: "",
          states: [],
        ),
      ).states ?? [];
    }

    setState(() {
    });
  }

  @override
  initState() {
    super.initState();
    // Load countries, states, and addresses from API
    getShippingPageData();
  }

  @override
  void dispose() {
    nameController.dispose();
    primaryPhoneController.dispose();
    secondaryPhoneController.dispose();
    addressController.dispose();
    address2Controller.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipping Address", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: GlobalVariables.greyBackgroundColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: GlobalVariables.sectionTitleColor,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalVariables.selectedNavBarColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (selectedShippingAddress?.id != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("Delivering to ${selectedShippingAddress?.name}", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${selectedShippingAddress?.address}, ${selectedShippingAddress?.city}, ${selectedShippingAddress?.state}, ${selectedShippingAddress?.pinCode}"),
                        ],
                      )),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: GlobalVariables.greyBackgroundColor, width: 1), // Border color and width
                        ),
                        onPressed: _openAddressSelector,
                        child: Text(
                          "Change",
                          style: TextStyle(
                            color: GlobalVariables.secondaryTextColor,
                            fontWeight: FontWeight.w600
                          )
                        )
                      ),
                    ],
                  ),
                  // const Divider(color: GlobalVariables.greyBackgroundColor),
                ],
              ),
            const SizedBox(height: 16),
            Text("Contact Details", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
            const Divider(color: GlobalVariables.greyBackgroundColor),
            SizedBox(height: 8),
            _label("Full Name"),
            SizedBox(height: 8),
            CustomTextField(
              controller: nameController,
              decoration: _inputDecoration("Type Your Name"),
              validator: (name) {
                if (name == null || name.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            _label("Phone Number"),
            SizedBox(height: 8),
            CustomTextField(
              controller: primaryPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Type Your Phone No."),
              validator: (phone) {
                if (phone == null || phone.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            _label("Alternate Phone Number"),
            SizedBox(height: 8),
            CustomTextField(
              controller: secondaryPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Alternate Phone Number"),
              validator: (phone) {
                if (phone != null && phone.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phone)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Text("Address", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
            const Divider(color: GlobalVariables.greyBackgroundColor),
            SizedBox(height: 8),
            _label("Pin Code"),
            SizedBox(height: 8),
            CustomTextField(
              controller: pinCodeController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Pin Code"),
              validator: (pin) {
                if (pin == null || pin.isEmpty) {
                  return 'Please enter your pin code';
                }
                if (!RegExp(r'^\d{5,6}$').hasMatch(pin)) {
                  return 'Please enter a valid pin code';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            _label("Road name, Area, Colony"),
            SizedBox(height: 8),
            CustomTextField(
              controller: addressController,
              decoration: _inputDecoration("Road name, Area, Colony"),
              validator: (address) {
                if (address == null || address.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            _label("House No, Building Name"),
            SizedBox(height: 8),
            CustomTextField(
              controller: address2Controller,
              decoration: _inputDecoration("House No, Building Name"),
            ),
            SizedBox(height: 8),
            _label("City"),
            SizedBox(height: 8),
            CustomTextField(
              controller: cityController,
              decoration: _inputDecoration("City"),
              validator: (city) {
                if (city == null || city.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            _label("State"),
            SizedBox(height: 8),
            DropdownButtonFormField(
              decoration: _inputDecoration("Select State"),
              value: selectedStateAbbr.isEmpty ? null : selectedStateAbbr,
              items:[
                const DropdownMenuItem(
                  value: "",
                  child: Text("Select State"),
                ),
                ...stateOptions.map((state) => DropdownMenuItem(
                  value: state.stateAbbreviation,
                  child: Text(state.stateName),
                ))
              ],
              onChanged: (val) => setState(() {
                selectedStateAbbr = val as String;
              }),
              validator: (value) => value == null || value.isEmpty ? 'Please select a state' : null,
            ),
            SizedBox(height: 8),
            _label("Country"),
            SizedBox(height: 8),
            DropdownButtonFormField(
              decoration: _inputDecoration("Select Country"),
              value: selectedCountryAbbr.isEmpty ? null : selectedCountryAbbr,
              items: [
                const DropdownMenuItem(
                  value: "",
                  child: Text("Select Country"),
                ),
                ...countries.map((region) => DropdownMenuItem(
                      value: region.countryAbbreviation,
                      child: Text(region.countryName),
                    ))
              ],
              onChanged: (val) => setState(() {
                selectedCountryAbbr = val as String;
                selectedStateAbbr = "";
                stateOptions = countries.firstWhere(
                  (region) => region.countryAbbreviation == selectedCountryAbbr,
                  orElse: () => Region(
                    id: "",
                    countryName: "",
                    countryAbbreviation: "",
                    states: [],
                  ),
                ).states ?? [];
              }),
              validator: (value) => value == null || value.isEmpty ? 'Please select a Country' : null,
            ),
            // DropdownButtonFormField(
            //   decoration: const InputDecoration(labelText: "Country"),
            //   value: selectedCountryAbbr.isEmpty ? null : selectedCountryAbbr,
            //   items: countries
            //       .map((region) => DropdownMenuItem(
            //             value: region["countryAbbreviation"],
            //             child: Text(region["countryName"]!),
            //           ))
            //       .toList(),
            //   onChanged: (val) => setState(() {
            //     selectedCountryAbbr = val as String;
            //     shippingInfo["country"] = selectedCountryAbbr;
            //     // TODO: Update `stateOptions` based on selected country
            //   }),
            // ),
            const SizedBox(height: 16),
            if (selectedShippingAddress?.id != null)
              RadioListTile(
                value: "updateAddress",
                groupValue: saveAs,
                title: const Text("Update Existing Delivery Address"),
                onChanged: (val) => setState(() => saveAs = val.toString()),
              ),
            RadioListTile(
              value: "addAddress",
              groupValue: saveAs,
              title: const Text("Save as New Delivery Address"),
              onChanged: (val) => setState(() => saveAs = val.toString()),
            ),
            // const SizedBox(height: 12),
            // ElevatedButton(onPressed: submit, child: const Text("Pay Now")),
          ],
        ),
      ),
    );
  }
}

Widget _label(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF575460),
    ),
  );
}

InputDecoration _inputDecoration(String placeholder) {
  return InputDecoration(
    hintText: placeholder,
    hintStyle: const TextStyle(
      color: GlobalVariables.placeholderColor,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: GlobalVariables.inputFill,
    contentPadding:
        const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: GlobalVariables.greyBackgroundColor,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: GlobalVariables.greyBackgroundColor,
      ),
    ),
  );
}
