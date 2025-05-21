import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String photo;
  final String role;
  final String dob;
  final String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.photo,
    required this.role,
    required this.dob,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo': photo,
      'role': role,
      'dob': dob,
      'gender': gender,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'] ?? '',
      role: map['role'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? '',
      // cart: List<Map<String, dynamic>>.from(
      //   map['cart']?.map(
      //     (x) => Map<String, dynamic>.from(x),
      //   ),
      // ),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photo,
    String? role,
    String? dob,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
    );
  }
}