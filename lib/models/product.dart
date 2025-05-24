import 'dart:convert';

import 'package:shopsphere/models/photo.dart';
import 'package:shopsphere/models/product_variant.dart';
import 'package:shopsphere/models/suggested_item.dart';



class Product {
  final String name;
  final String? description;
  final int stock;
  final List<Photo> photos;
  final String category;
  final double price;
  final String id;
  final int? numOfReviews;
  final double? ratings;
  final List<SuggestedItem>? suggestedItems;
  final List<ProductVariant>variants;
  Product({
    required this.name,
    this.description,
    required this.stock,
    required this.photos,
    required this.category,
    required this.price,
    required this.id,
    this.numOfReviews,
    this.ratings,
    this.suggestedItems,
    required this.variants
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'stock': stock,
      'photos': photos,
      'category': category,
      'price': price,
      'id': id,
      'numOfReviews': numOfReviews,
      'ratings': ratings,
      'suggestedItems': suggestedItems?.map((x) => x.toMap()).toList(),
      'variants': variants.map((x) => x.toMap()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      stock: map['stock'] ?? 0,
      photos: List<Photo>.from(
        map['photos']?.map(
          (x) => Photo.fromMap(x)
        )
      ),
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      id: map['_id'],
      numOfReviews: map['numOfReviews'] ?? 0,
      ratings: map['ratings']?.toDouble() ?? 0.0,
      suggestedItems: List<SuggestedItem>.from(
        map['suggestedItems']?.map((x) => SuggestedItem.fromMap(x)) ?? [],
      ),
      variants: List<ProductVariant>.from(
        map['variants']?.map((x) => ProductVariant.fromMap(x)) ?? [],
      ),
    );
  }

  factory Product.suggestedItemFromMap(Map<String, dynamic> map) {
  return Product(
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    stock: map['stock'] ?? 0,
    photos: List<Photo>.from(
      map['photos']?.map((x) => Photo.fromMap(x)),
    ),
    category: map['category'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    id: map['_id'] ?? '',
    numOfReviews: map['numOfReviews'] ?? 0,
    ratings: (map['ratings'] ?? 0).toDouble(),
    variants: List<ProductVariant>.from(
      map['variants']?.map((x) => ProductVariant.fromMap(x)) ?? [],
    ),
  );
}

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
