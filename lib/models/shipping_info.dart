import 'dart:convert';

class ShippingInfo {
  final String name;
  final int primaryPhone;
  final int? secondaryPhone;
  final String address;
  final String address2;
  final String city;
  final String state;
  final String country;
  final int pinCode;

  ShippingInfo({
    required this.name,
    required this.primaryPhone,
    this.secondaryPhone,
    required this.address,
    required this.address2,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'address': address,
      'address2': address2,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
    };
  }

  factory ShippingInfo.fromMap(Map<String, dynamic> json) {
    return ShippingInfo(
      name: json['name'],
      primaryPhone: json['primaryPhone'],
      secondaryPhone: json['secondaryPhone'],
      address: json['address'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pinCode: json['pinCode'],
    );
  }

  String toJson() => json.encode(toMap());
  factory ShippingInfo.fromJson(String source) =>
      ShippingInfo.fromMap(source as Map<String, dynamic>);
}
