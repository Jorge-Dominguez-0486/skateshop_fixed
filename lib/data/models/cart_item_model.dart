class CartItemModel {
  final String idProducto;
  final String nombre;
  final double precio;
  final int cantidad;
  final String? imageUrl;

  CartItemModel({
    required this.idProducto,
    this.nombre = '',
    this.precio = 0,
    this.cantidad = 1,
    this.imageUrl,
  });

  double get subtotal => precio * cantidad;

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      idProducto: map['idProducto']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      cantidad: (map['cantidad'] ?? 1).toInt(),
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'imageUrl': imageUrl,
    };
  }

  CartItemModel copyWith({
    String? idProducto,
    String? nombre,
    double? precio,
    int? cantidad,
    String? imageUrl,
  }) {
    return CartItemModel(
      idProducto: idProducto ?? this.idProducto,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
