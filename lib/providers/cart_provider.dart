import 'package:flutter/material.dart';
import 'package:shopsphere/models/system_settings.dart';
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
  int _discount = 0;
  double _total = 0;
  double _taxRate = 5; // Default tax rate
  SystemSettings? _deliveryFee; // Default delivery percentage

  List<CartItem> get cartItems => _cartItems;
  ShippingInfo? get shippingInfo => _shippingInfo;
  String get selectedShippingAddressId => _selectedShippingAddressId;
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get shippingCharges => _shippingCharges;
  int get discount => _discount;
  double get total => _total;
  double get taxRate => _taxRate;
  SystemSettings? get deliveryFee => _deliveryFee;

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

  void _calculatePrices() {
    double shippingCharges = 0;
    _subtotal = _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

    if( _deliveryFee?.settingValue == "true" && _subtotal >= _deliveryFee?.entityDetails.subtotalMinRange
        && ( _deliveryFee?.entityDetails.subtotalMaxRange == null || _subtotal <= _deliveryFee?.entityDetails.subtotalMaxRange )
    ){
      double shippingChargeByPercent = _deliveryFee?.entityDetails.percentage * _subtotal / 100;
      shippingCharges = _deliveryFee?.entityDetails.setDeliveryFeeTo == "Greater"
          ? shippingChargeByPercent >= _deliveryFee?.entityDetails.amount ? shippingChargeByPercent : _deliveryFee?.entityDetails.amount
          : shippingChargeByPercent < _deliveryFee?.entityDetails.amount ? shippingChargeByPercent : _deliveryFee?.entityDetails.amount;
    }

    _shippingCharges = shippingCharges.roundToDouble();
    _tax = (_subtotal * _taxRate / 100).roundToDouble();
    _total = _subtotal + _shippingCharges + _tax - _discount;
  }

  void applyDiscount(int discount) {
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

  void setTaxRate(double rate) {
    _taxRate = rate;
    _calculatePrices();
    notifyListeners();
  }

  void setDeliveryFee(SystemSettings deliveryFee) {
    _deliveryFee = deliveryFee;
    _calculatePrices();
    notifyListeners();
  }
}
