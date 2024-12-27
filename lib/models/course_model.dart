class CourseModel {
  final String id;
  final String title;
  final String price;
  final String imageUrl;

  const CourseModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    price: json['price'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'imageUrl': imageUrl,
  };

  CourseModel copyWith({
    String? id,
    String? title,
    String? price,
    String? imageUrl,
  }) => CourseModel(
    id: id ?? this.id,
    title: title ?? this.title,
    price: price ?? this.price,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}
