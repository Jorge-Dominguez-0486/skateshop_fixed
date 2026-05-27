class ProductModel {
  final String id;
  final String nombre;
  final String categoria; // "Skateboard", "Ropa", "Accesorios", "Tenis"
  final String marca;
  final double precio;
  final int stock;
  final String? talla;
  final String color;
  final String material;
  final String? imageUrl;
  final DateTime fechaIngreso;
  final bool activo;

  ProductModel({
    required this.id,
    this.nombre = '',
    this.categoria = 'Skateboard',
    this.marca = '',
    this.precio = 0,
    this.stock = 0,
    this.talla,
    this.color = '',
    this.material = '',
    this.imageUrl,
    DateTime? fechaIngreso,
    this.activo = true,
  }) : fechaIngreso = fechaIngreso ?? DateTime.now();

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? 'Skateboard',
      marca: map['marca']?.toString() ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      talla: map['talla']?.toString(),
      color: map['color']?.toString() ?? '',
      material: map['material']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      fechaIngreso: (map['fechaIngreso'] as dynamic)?.toDate() ?? DateTime.now(),
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'marca': marca,
      'precio': precio,
      'stock': stock,
      'talla': talla,
      'color': color,
      'material': material,
      'imageUrl': imageUrl,
      'fechaIngreso': fechaIngreso,
      'activo': activo,
    };
  }

  ProductModel copyWith({
    String? id,
    String? nombre,
    String? categoria,
    String? marca,
    double? precio,
    int? stock,
    String? talla,
    String? color,
    String? material,
    String? imageUrl,
    DateTime? fechaIngreso,
    bool? activo,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      talla: talla ?? this.talla,
      color: color ?? this.color,
      material: material ?? this.material,
      imageUrl: imageUrl ?? this.imageUrl,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      activo: activo ?? this.activo,
    );
  }
}
