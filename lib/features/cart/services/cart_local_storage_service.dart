import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopsphere/models/cart_item.dart';

class CartLocalStorageService {
  static const String _cartKey = 'cart_items';
  
  final _secureStorage = const FlutterSecureStorage();

  Future<void> saveCartItems(List<CartItem> items) async {
    try {
      final jsonList = items.map((item) => item.toMap()).toList();
      final jsonString = jsonEncode(jsonList);
      await _secureStorage.write(key: _cartKey, value: jsonString);
      print('✅ Cart saved: ${items.length} items');
    } catch (e) {
      print('❌ Error saving cart: $e');
    }
  }

  Future<List<CartItem>> loadCartItems() async {
    try {
      final jsonString = await _secureStorage.read(key: _cartKey);
      if (jsonString == null || jsonString.isEmpty) {
        print('⚠️ No cart data found');
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final items = jsonList.map((item) => CartItem.fromMap(item)).toList();
      print('✅ Cart loaded: ${items.length} items');
      return items;
    } catch (e) {
      print('❌ Error loading cart: $e');
      return [];
    }
  }

  Future<void> clearCart() async {
    try {
      await _secureStorage.delete(key: _cartKey);
      print('✅ Cart cleared');
    } catch (e) {
      print('❌ Error clearing cart: $e');
    }
  }
}
