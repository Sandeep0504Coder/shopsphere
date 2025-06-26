import 'configuration.dart';
import 'dart:convert';

class ProductVariant {
  final List<Configuration> configuration;
  final double price;
  final int stock;
  final String? id;

  ProductVariant({
    required this.configuration,
    required this.price,
    required this.stock,
    this.id,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      configuration: List<Configuration>.from(
        map['configuration']?.map((x) => Configuration.fromMap(x)) ?? [],
      ),
      price: map['price']?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
      id: map['_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'configuration': configuration.map((x) => x.toMap()).toList(),
      'price': price,
      'stock': stock,
      if (id != null) '_id': id,
    };
  }
  String toJson() => json.encode(toMap());
}
