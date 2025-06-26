class Address {
  final String id;
  final String name;
  final int primaryPhone;
  final int? secondaryPhone;
  final String address;
  final String address2;
  final String city;
  final String state;
  final String country;
  final int pinCode;
  final String user;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.address,
    required this.address2,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.user,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      name: json['name'],
      primaryPhone: json['primaryPhone'],
      secondaryPhone: json['secondaryPhone'],
      address: json['address'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pinCode: json['pinCode'],
      user: json['user'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'address': address,
      'address2': address2,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'user': user,
      'isDefault': isDefault,
    };
  }
}
