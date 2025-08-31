import 'dart:convert';

import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/models/system_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CartServices {
  Future<SystemSettings> getSystemSettingDetailByUniqueName({
    required String settingUniqueName,
    required BuildContext context,
  }) async {
    SystemSettings systemSettings = SystemSettings(
      id: '',
      settingCategory: '',
      settingUniqueName: '',
      settingName: '',
      settingValue: '',
      entityId: '',
      entityDetails: null,
    );

    try {
      final res = await http.get(Uri.parse('$uri/api/v1/systemSetting/settingDetails?settingUniqueName=$settingUniqueName'));
    
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
         final data = jsonDecode(res.body);

          if (data['success']) {
            systemSettings = SystemSettings.fromMap(data['systemSetting']);
          }
        },
      ); 
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return systemSettings;
  }

  Future<int> getDiscountByCoupon({
    required String couponCode,
    required BuildContext context,
  }) async {
    int discount = 0;

    try {
      final res = await http.get(Uri.parse('$uri/api/v1/payment/discount?coupon=$couponCode'));
    print("Response: ${res.body}");
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
         final data = jsonDecode(res.body);
print("data: ${data}");
          if (data['success']) {
            discount = data['discount'];
          }
        },
      ); 
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return discount;
  }
}
