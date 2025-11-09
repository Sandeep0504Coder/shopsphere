import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopsphere/models/address.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/models/region.dart';

class AddressServices {
  Future<List<Addresses>> fetchAddresses({required String userId, required BuildContext context}) async {
    List<Addresses> addresses = [];

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
                Addresses.fromJson(
                  data['addresses'][i],
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

  Future<List<Region>> fetchAllRegions({required String userId, required BuildContext context}) async {
    List<Region> regions = [];

    try {
      http.Response res = await http.get(Uri.parse('$uri/api/v1/region/all'));
      
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            for (int i = 0; i < data['regions'].length; i++) {
              regions.add(
                Region.fromJson(
                  data['regions'][i],
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
    return regions;
  }

  Future updateAddress({
    required BuildContext context,
    required String id,
    required String addressId,
    required Map<String, dynamic> addressData,
  }) async {
    try {
      final http.Response response = await http.put(
        Uri.parse('$uri/api/v1/user/address/$addressId?id=$id'),
        body: jsonEncode(addressData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {},
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<String> createAddress({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> addressData,
  }) async {
    String addressId = "";
    try {
      final http.Response response = await http.post(
        Uri.parse('$uri/api/v1/user/address/new?id=$id'),
        body: jsonEncode(addressData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          final data = jsonDecode(response.body);
          addressId = data['addressId'];
          showSnackBar(context, "Address Created successfully");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return addressId;
  }

  Future<bool> deleteAddress({
    required BuildContext context,
    required String userId,
    required String addressId,
  }) async {
    bool success = false;
    try {
      final http.Response response = await http.delete(
        Uri.parse('$uri/api/v1/user/address/$addressId?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          success = true;
          showSnackBar(context, "Address deleted successfully");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return success;
  }
}