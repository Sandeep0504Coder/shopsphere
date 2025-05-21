import 'dart:convert';

import 'package:shopsphere/models/photo.dart';



class Product {
  final String name;
  final String description;
  final int stock;
  final List<Photo> photos;
  final String category;
  final double price;
  final String id;
  final int numOfReviews;
  final double ratings;
  // suggestedItems,
  // variants
  // final List<Rating>? rating;
  Product({
    required this.name,
    required this.description,
    required this.stock,
    required this.photos,
    required this.category,
    required this.price,
    required this.id,
    required this.numOfReviews,
    required this.ratings
    // this.rating,
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
      'ratings': ratings
      // 'rating': rating,
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
      numOfReviews: map['numOfReviews'],
      ratings: map['ratings'].toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
