class InventoryModel {
  final String id;
  final String idProducto;
  final String nombreProducto;
  final int stockActual;
  final int stockMinimo;
  final int stockMaximo;
  final DateTime ultimaActualizacion;
  final String? notas;

  InventoryModel({
    required this.id,
    this.idProducto = '',
    this.nombreProducto = '',
    this.stockActual = 0,
    this.stockMinimo = 5,
    this.stockMaximo = 100,
    DateTime? ultimaActualizacion,
    this.notas,
  }) : ultimaActualizacion = ultimaActualizacion ?? DateTime.now();

  bool get bajoStock => stockActual <= stockMinimo;

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id']?.toString() ?? '',
      idProducto: map['idProducto']?.toString() ?? '',
      nombreProducto: map['nombreProducto']?.toString() ?? '',
      stockActual: (map['stockActual'] ?? 0).toInt(),
      stockMinimo: (map['stockMinimo'] ?? 5).toInt(),
      stockMaximo: (map['stockMaximo'] ?? 100).toInt(),
      ultimaActualizacion: (map['ultimaActualizacion'] as dynamic)?.toDate() ?? DateTime.now(),
      notas: map['notas']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idProducto': idProducto,
      'nombreProducto': nombreProducto,
      'stockActual': stockActual,
      'stockMinimo': stockMinimo,
      'stockMaximo': stockMaximo,
      'ultimaActualizacion': ultimaActualizacion,
      'notas': notas,
    };
  }

  InventoryModel copyWith({
    String? id,
    String? idProducto,
    String? nombreProducto,
    int? stockActual,
    int? stockMinimo,
    int? stockMaximo,
    DateTime? ultimaActualizacion,
    String? notas,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      idProducto: idProducto ?? this.idProducto,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      stockMaximo: stockMaximo ?? this.stockMaximo,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      notas: notas ?? this.notas,
    );
  }
}
