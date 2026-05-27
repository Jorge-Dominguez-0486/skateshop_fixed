class SaleItemModel {
  final String idProducto;
  final String nombre;
  final int cantidad;
  final double precioUnitario;

  SaleItemModel({
    required this.idProducto,
    this.nombre = '',
    this.cantidad = 1,
    this.precioUnitario = 0,
  });

  double get subtotal => cantidad * precioUnitario;

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      idProducto: map['idProducto']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      cantidad: (map['cantidad'] ?? 1).toInt(),
      precioUnitario: (map['precioUnitario'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
    };
  }
}

class SaleModel {
  final String id;
  final String idCliente;
  final String nombreCliente;
  final List<SaleItemModel> productos;
  final double total;
  final String metodoPago; // "Efectivo", "Tarjeta", "Transferencia"
  final String estado; // "Pendiente", "Completada", "Cancelada"
  final DateTime fechaVenta;

  SaleModel({
    required this.id,
    this.idCliente = '',
    this.nombreCliente = '',
    this.productos = const [],
    this.total = 0,
    this.metodoPago = 'Efectivo',
    this.estado = 'Pendiente',
    DateTime? fechaVenta,
  }) : fechaVenta = fechaVenta ?? DateTime.now();

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id']?.toString() ?? '',
      idCliente: map['idCliente']?.toString() ?? '',
      nombreCliente: map['nombreCliente']?.toString() ?? '',
      productos: (map['productos'] as List<dynamic>?)
              ?.map((e) => SaleItemModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (map['total'] ?? 0).toDouble(),
      metodoPago: map['metodoPago']?.toString() ?? 'Efectivo',
      estado: map['estado']?.toString() ?? 'Pendiente',
      fechaVenta: (map['fechaVenta'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCliente': idCliente,
      'nombreCliente': nombreCliente,
      'productos': productos.map((e) => e.toMap()).toList(),
      'total': total,
      'metodoPago': metodoPago,
      'estado': estado,
      'fechaVenta': fechaVenta,
    };
  }
}
