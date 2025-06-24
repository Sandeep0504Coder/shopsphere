class Review {
  final String product;
  final ReviewUser user;
  final int rating;
  final String comment;
  final String id;

  Review({
    required this.product,
    required this.user,
    required this.rating,
    required this.comment,
    required this.id,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      product: json['product'],
      user: ReviewUser.fromJson(json['user']),
      rating: json['rating'],
      comment: json['comment'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'user': user.toJson(),
      'rating': rating,
      'comment': comment,
      '_id': id,
    };
  }
}

class ReviewUser {
  final String name;
  final String photo;
  final String id;

  ReviewUser({
    required this.name,
    required this.photo,
    required this.id,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      name: json['name'],
      photo: json['photo'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photo': photo,
      '_id': id,
    };
  }
}
