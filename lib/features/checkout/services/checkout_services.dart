import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/models/new_order_request.dart';
import 'package:shopsphere/models/shipping_info.dart';

class CheckoutServices {
Future<String> createOrder({
    required BuildContext context,
    required NewOrderRequest orderData,
  }) async {
    String orderId = "";
    try {
      print(orderData.toJson());
      final http.Response response = await http.post(
        Uri.parse('$uri/api/v1/order/new'),
        body: orderData.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          final data = jsonDecode(response.body);
          if(data['success'] == true) {
            orderId = data['orderId'];
          }
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return orderId;
  }
}