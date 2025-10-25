class Product {
  final int? id;
  final String name;
  final int quantity;
  final double price;
  final String? imagePath;
  final String createdAt;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: map['price'] as double,
      imagePath: map['imagePath'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
    String? imagePath,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, quantity: $quantity, price: $price, imagePath: $imagePath, createdAt: $createdAt}';
  }
}