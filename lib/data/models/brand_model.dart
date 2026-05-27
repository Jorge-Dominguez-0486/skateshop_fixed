class BrandModel {
  final String id;
  final String nombre;
  final String pais;
  final String? logoUrl;
  final String descripcion;
  final List<String> categorias;
  final bool activo;

  BrandModel({
    required this.id,
    this.nombre = '',
    this.pais = '',
    this.logoUrl,
    this.descripcion = '',
    this.categorias = const [],
    this.activo = true,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      pais: map['pais']?.toString() ?? '',
      logoUrl: map['logoUrl']?.toString(),
      descripcion: map['descripcion']?.toString() ?? '',
      categorias: (map['categorias'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'pais': pais,
      'logoUrl': logoUrl,
      'descripcion': descripcion,
      'categorias': categorias,
      'activo': activo,
    };
  }

  BrandModel copyWith({
    String? id,
    String? nombre,
    String? pais,
    String? logoUrl,
    String? descripcion,
    List<String>? categorias,
    bool? activo,
  }) {
    return BrandModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      pais: pais ?? this.pais,
      logoUrl: logoUrl ?? this.logoUrl,
      descripcion: descripcion ?? this.descripcion,
      categorias: categorias ?? this.categorias,
      activo: activo ?? this.activo,
    );
  }
}
