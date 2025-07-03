import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/shipping_info.dart';
import '../models/product_variant.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  ShippingInfo? _shippingInfo;
  String _selectedShippingAddressId = '';
  double _subtotal = 0;
  double _tax = 0;
  double _shippingCharges = 0;
  double _discount = 0;
  double _total = 0;

  List<CartItem> get cartItems => _cartItems;
  ShippingInfo? get shippingInfo => _shippingInfo;
  String get selectedShippingAddressId => _selectedShippingAddressId;
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get shippingCharges => _shippingCharges;
  double get discount => _discount;
  double get total => _total;

  void addToCart(CartItem item, {bool updateIfExists = true}) {
    final existingIndex = _cartItems.indexWhere((e) =>
      e.productId == item.productId &&
      (e.variant?.id == item.variant?.id));

    if (existingIndex != -1) {
      if (updateIfExists) {
        _cartItems[existingIndex] = item;
      }
    } else {
      _cartItems.add(item);
    }

    _calculatePrices();
    notifyListeners();
  }

  void removeFromCart(String productId, String? variantId) {
    _cartItems.removeWhere((item) =>
      item.productId == productId &&
      (variantId == null || item.variant?.id == variantId));

    _calculatePrices();
    notifyListeners();
  }

  void _calculatePrices({double deliveryPercent = 5, double taxRate = 5}) {
    _subtotal = _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    _shippingCharges = _subtotal * deliveryPercent / 100;
    _tax = _subtotal * taxRate / 100;
    _total = _subtotal + _shippingCharges + _tax - _discount;
  }

  void applyDiscount(double discount) {
    _discount = discount;
    _calculatePrices();
    notifyListeners();
  }

  void saveShippingInfo(ShippingInfo info) {
    _shippingInfo = info;
    notifyListeners();
  }

  void updateShippingAddressId(String id) {
    _selectedShippingAddressId = id;
    notifyListeners();
  }

  void resetCart() {
    _cartItems.clear();
    _shippingInfo = null;
    _selectedShippingAddressId = '';
    _subtotal = 0;
    _tax = 0;
    _shippingCharges = 0;
    _discount = 0;
    _total = 0;
    notifyListeners();
  }
}
