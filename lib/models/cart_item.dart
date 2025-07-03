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
}
