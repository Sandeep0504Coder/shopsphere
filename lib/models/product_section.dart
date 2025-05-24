import 'dart:convert';
import 'package:shopsphere/models/product.dart';

class ProductSection {
  final String sectionLabel;
  final List<dynamic> filters; // You can create a Filter model later if needed
  final String? id;
  final List<Product>? products;

  ProductSection({
    required this.sectionLabel,
    required this.filters,
    this.id,
    this.products,
  });

  factory ProductSection.fromMap(Map<String, dynamic> map) {
    return ProductSection(
      sectionLabel: map['sectionLabel'] ?? '',
      filters: map['filters'] ?? [],
      id: map['_id'],
      products: map['products'] != null
          ? List<Product>.from(
              map['products'].map((x) => Product.fromMap(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectionLabel': sectionLabel,
      'filters': filters,
      '_id': id,
      'products': products?.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory ProductSection.fromJson(String source) =>
      ProductSection.fromMap(json.decode(source));
}
