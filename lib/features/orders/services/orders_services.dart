import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/models/order.dart';

class OrdersServices {
  Future<List<Order>> fetchMyOrders({required String userId, required BuildContext context}) async {
    List<Order> orders = [];
    try {
      final res = await http.get(Uri.parse('$uri/api/v1/order/my?id=$userId'));
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            for (var order in data['orders']) {
              orders.add(Order.fromMap(order));
            }
          }
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
    return orders;
  }
}