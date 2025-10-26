import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopsphere/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/error_handling.dart';

class OrderDetailServices {
  Future<Order> fetchOrderDetails({required String id, required BuildContext context}) async {
    Order orderDetails = Order(
      id: '',
      status: '',
      orderItems: [],
      subtotal: 0,
      tax: 0,
      shippingCharges: 0,
      discount: 0,
      total: 0,
      userDetails: {},
      // shippingInfo: null,
    );

    try {
      http.Response res = await http.get(Uri.parse('$uri/api/v1/order/$id'));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            orderDetails = Order.fromJson(jsonEncode(data['order']));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print("error in fetching order details");
      print(e);
    }
    return orderDetails;

  }
}