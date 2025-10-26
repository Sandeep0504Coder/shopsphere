import "dart:convert";

import "package:shopsphere/models/cart_item.dart";
import "package:shopsphere/models/shipping_info.dart";

import "new_order_request.dart";

class Order extends NewOrderRequest {
  final String id;
  final String status;
  final Map<String, dynamic> userDetails;

  Order({
    required this.id,
    required List<CartItem> orderItems,
    ShippingInfo? shippingInfo,
    required double subtotal,
    required double tax,
    required double shippingCharges,
    required int discount,
    required double total,
    required this.userDetails,
    required this.status,
  }) : super(
    orderItems: orderItems,
    shippingInfo: null,
    subtotal: subtotal,
    tax: tax,
    shippingCharges: shippingCharges,
    discount: discount,
    total: total,
    user: userDetails["id"] ?? "",
  );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      '_id': id,
      'status': status,
      'user': userDetails,
    });
    return map;
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    dynamic userField = map['user'];
    Map<String, dynamic> userDetails;
    if (userField is Map<String, dynamic>) {
      userDetails = userField;
    } else if (userField is String) {
      userDetails = { "id": userField };
    } else {
      userDetails = {};
    }

    return Order(
      id: map['_id'] ?? '',
      orderItems: List<CartItem>.from(
        map['orderItems']?.map((item) => CartItem.fromMap(item)) ?? [],
      ),
      shippingInfo: map['shippingInfo'] != null ? ShippingInfo.fromMap(map['shippingInfo']) : null,
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      shippingCharges: map['shippingCharges']?.toDouble() ?? 0.0,
      discount: map['discount']?.toInt() ?? 0,
      total: map['total']?.toDouble() ?? 0.0,
      userDetails: userDetails,
      status: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}