import 'dart:convert';

import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/models/search_product_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchServices {
  Future<SearchProductResponse> fetchSearchedProduct({
    required BuildContext context,
    required String search,
    required String sort,
    required String maxPrice,
    required String minPrice,
    required String category,
    required int page
  }) async {
    List<Product> productList = [];
    int totalPage = 1;
    String searchQuery = 'maxPrice=$maxPrice&minPrice=$minPrice&page=$page';
    if(category.isNotEmpty) searchQuery += '&category=$category';
    if(sort.isNotEmpty) searchQuery += '&sort=$sort';
    if(search.isNotEmpty) searchQuery += '&search=$search';

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/v1/product/all?$searchQuery'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body)['products'].length; i++) {
            productList.add(
              Product.fromJson(
                jsonEncode(
                  jsonDecode(res.body)['products'][i],
                ),
              ),
            );
          }
          totalPage = jsonDecode(res.body)['totalPage'] ?? 1;
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return SearchProductResponse(products: productList, totalPage: totalPage);
  }
}
