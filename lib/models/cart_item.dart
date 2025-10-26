import 'dart:convert';

import 'product_variant.dart';

class CartItem {
  final String productId;
  final String photo;
  final String name;
  final double price;
  final int quantity;
  final int stock;
  final ProductVariant? variant;

  CartItem({
    required this.productId,
    required this.photo,
    required this.name,
    required this.price,
    required this.quantity,
    required this.stock,
    this.variant,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'photo': photo,
      'name': name,
      'price': price,
      'quantity': quantity,
      'stock': stock,
      'variant': variant?.toMap(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      photo: map['photo'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      stock: map['stock']?.toInt() ?? 0,
      variant: map['variant'] != null ? ProductVariant.fromMap(map['variant']) : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory CartItem.fromJson(String source) => CartItem.fromMap(json.decode(source));
}
