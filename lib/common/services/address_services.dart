import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/models/review.dart';

class AddressServices {
  Future<List<Address>> fetchAddresses({required String userId, required BuildContext context}) async {
    List<Address> addresses = [];

    try {
      http.Response res = await http.get(Uri.parse('$uri/api/v1/user/address/my?id=$userId'));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            for (int i = 0; i < data['addresses'].length; i++) {
              addresses.add(
                Address.fromJson(
                  data['reviews'][i],
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }
    return addresses;
  }
}