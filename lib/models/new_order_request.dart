import 'dart:convert';

import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/models/shipping_info.dart';

class NewOrderRequest{
  final List<CartItem> orderItems;
  final ShippingInfo? shippingInfo;
  final double subtotal;
  final double tax;
  final double shippingCharges;
  final int discount;
  final double total;
  final String user;

  NewOrderRequest({
    required this.orderItems,
    this.shippingInfo,
    required this.subtotal,
    required this.tax,
    required this.shippingCharges,
    required this.discount,
    required this.total,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderItems': orderItems.map((item) => item.toMap()).toList(),
      'shippingInfo': shippingInfo?.toMap(),
      'subtotal': subtotal,
      'tax': tax,
      'shippingCharges': shippingCharges,
      'discount': discount,
      'total': total,
      'user': user,
    };
  }

  factory NewOrderRequest.fromMap(Map<String, dynamic> map) {
    return NewOrderRequest(
      orderItems: List<CartItem>.from(
        map['orderItems']?.map((item) => CartItem.fromMap(item)) ?? [],
      ),
      shippingInfo: map['shippingInfo'] != null ? ShippingInfo.fromMap(map['shippingInfo']) : null,
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      shippingCharges: map['shippingCharges']?.toDouble() ?? 0.0,
      discount: map['discount']?.toInt() ?? 0,
      total: map['total']?.toDouble() ?? 0.0,
      user: map['user'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
}