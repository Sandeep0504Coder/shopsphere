import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';

class PaymentServices {
  Future<String> createPayment({
    required BuildContext context,
    required double total,
  }) async {
    String clientSecret = "";
    try {
      final http.Response response = await http.post(
        Uri.parse('$uri/api/v1/payment/create'),
        body: jsonEncode({"amount": total}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          final data = jsonDecode(response.body);
          if(data['success'] == true) {
            clientSecret = data['clientSecret'];
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return clientSecret;
  }
}