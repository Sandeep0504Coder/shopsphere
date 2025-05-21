import 'dart:convert';

import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SearchServices {
  Future<List<Product>> fetchSearchedProduct({
    required BuildContext context,
    required String searchQuery,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/v1/product/all?$searchQuery'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
  // print(res.body);
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // print(jsonDecode(res.body).products);
          for (int i = 0; i < jsonDecode(res.body)['products'].length; i++) {
            productList.add(
              Product.fromJson(
                jsonEncode(
                  jsonDecode(res.body)['products'][i],
                ),
              ),
            );
          }
          print(productList);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }
}
