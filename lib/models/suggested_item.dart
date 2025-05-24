import 'dart:convert';
import 'product.dart';
class SuggestedItem {
  final Product product;

  SuggestedItem({required this.product});

   factory SuggestedItem.fromMap(Map<String, dynamic> map) {
    return SuggestedItem(
      product: Product.suggestedItemFromMap(map['productId']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.toMap(),
    };
  }
}