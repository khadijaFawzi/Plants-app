class Product {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String image;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'],
      image: map['image'],
    );
  }
}

