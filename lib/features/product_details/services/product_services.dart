import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopsphere/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/models/review.dart';
class ProductServices {
  Future<Product> fetchProductDetails({required String id, required BuildContext context}) async {
    Product productDetails = Product(
      name: '',
      stock: 0,
      photos: [],
      category: '',
      id: '',
      price: 0,
      variants: []
    );

    try {
      http.Response res = await http.get(Uri.parse('$uri/api/v1/product/$id'));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            productDetails = Product.fromJson(jsonEncode(data['product']));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }
    return productDetails;

  }

  Future<List<Review>> fetchReviews({required String productId, required BuildContext context}) async { 
    List<Review> productReviews = [];

    try {
      http.Response res = await http.get(Uri.parse('$uri/api/v1/product/reviews/$productId'));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            for (int i = 0; i < data['reviews'].length; i++) {
              productReviews.add(
                Review.fromJson(
                  data['reviews'][i],
                ),
              );
            };
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }
    return productReviews;
  }
  Future addEditReview( {required String productId, required String userId, required String comment, required int rating, required BuildContext context } ) async {
    try {
      http.Response res = await http.post(
        Uri.parse("$uri/api/v1/product/review/new/$productId?id=$userId"), // Replace with your API endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rating": rating,
          "comment": comment,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            showSnackBar(context, data['message']);
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
  Future deleteReview({required String reviewId, required String userId, required BuildContext context}) async {
    try {
      http.Response res = await http.delete(
        Uri.parse("$uri/api/v1/product/review/$reviewId?id=$userId"), // Replace with your API endpoint
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            showSnackBar(context, data['message']);
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}