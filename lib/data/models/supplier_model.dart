class SupplierModel {
  final String id;
  final String nombre;
  final String contacto;
  final String telefono;
  final String correo;
  final String direccion;
  final List<String> categorias;
  final bool activo;

  SupplierModel({
    required this.id,
    this.nombre = '',
    this.contacto = '',
    this.telefono = '',
    this.correo = '',
    this.direccion = '',
    this.categorias = const [],
    this.activo = true,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      contacto: map['contacto']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      direccion: map['direccion']?.toString() ?? '',
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
      'contacto': contacto,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
      'categorias': categorias,
      'activo': activo,
    };
  }

  SupplierModel copyWith({
    String? id,
    String? nombre,
    String? contacto,
    String? telefono,
    String? correo,
    String? direccion,
    List<String>? categorias,
    bool? activo,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
      categorias: categorias ?? this.categorias,
      activo: activo ?? this.activo,
    );
  }
}
