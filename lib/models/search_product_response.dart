import 'package:shopsphere/models/product.dart';

class SearchProductResponse {
  final List<Product> products;
  final int totalPage;

  SearchProductResponse({required this.products, required this.totalPage});
}