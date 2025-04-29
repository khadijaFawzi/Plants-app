class CartItem {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final String? productName;
  final double? productPrice;
  final String? productImage;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.productPrice,
    this.productImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      userId: map['userId'],
      productId: map['productId'],
      quantity: map['quantity'],
      productName: map['name'],
      productPrice: map['price'],
      productImage: map['image'],
    );
  }

  double get total => (productPrice ?? 0) * quantity;
}

