import 'dart:convert';

import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/models/home_page_content.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/models/photo.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeServices {
  Future<List<String>> getProductCategories({
    required BuildContext context,
  }) async {
    List<String> categories = [];

    try {
      final res = await http.get(Uri.parse('$uri/api/v1/product/categories'));
    
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
         final data = jsonDecode(res.body);

          if (data['success']) {
            categories = List<String>.from(data['categories']);
          }
        },
      ); 
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return categories;
  }

  Future<HomePageContent> getHeroSectionData({
    required BuildContext context,
  }) async {
    HomePageContent homePageContent = HomePageContent(
      promotionalText: '',
      promotionalTextLabel: '',
      banners: [],
      promotionalVideo: Photo(public_id:'',url:''),
      id: '',
      productSections: [],
    );

    try {
      http.Response res = await http.get(Uri.parse('$uri/api/v1/homePageContent/hero'));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);

          if (data['success']) {
            homePageContent = HomePageContent.fromJson(jsonEncode(data['homePageContent']));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }
    return homePageContent;
  }
}
