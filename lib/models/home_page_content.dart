import 'dart:convert';
import 'package:shopsphere/models/photo.dart';
import 'package:shopsphere/models/product.dart';
import 'product_section.dart';

class HomePageContent {
  final String promotionalText;
  final String promotionalTextLabel;
  final List<Photo> banners;
  final Photo promotionalVideo;
  final String id;
  final List<ProductSection> productSections;

  HomePageContent({
    required this.promotionalText,
    required this.promotionalTextLabel,
    required this.banners,
    required this.promotionalVideo,
    required this.id,
    required this.productSections,
  });

  factory HomePageContent.fromMap(Map<String, dynamic> map) {
    return HomePageContent(
      promotionalText: map['promotionalText'] ?? '',
      promotionalTextLabel: map['promotionalTextLabel'] ?? '',
      banners: List<Photo>.from(
        (map['banners'] as List).map((x) => Photo.fromMap(x)) ?? [],
      ),
      promotionalVideo: Photo.fromMap(map['promotionalVideo']),
      id: map['_id'],
      productSections: List<ProductSection>.from(
        map['productSections']?.map((x) => ProductSection.fromMap(x)) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'promotionalText': promotionalText,
      'promotionalTextLabel': promotionalTextLabel,
      'banners': banners.map((x) => x.toMap()).toList(),
      'promotionalVideo': promotionalVideo.toMap(),
      '_id': id,
      'productSections': productSections.map((x) => x.toMap()).toList(),
    };
  }

  factory HomePageContent.fromJson(String source) =>
      HomePageContent.fromMap(json.decode(source));
}
