class ClientModel {
  final String id;
  final String nombre;
  final String telefono;
  final String correo;
  final String calle;
  final String ciudad;
  final String estado;
  final DateTime fechaRegistro;
  final bool frecuente;

  ClientModel({
    required this.id,
    this.nombre = '',
    this.telefono = '',
    this.correo = '',
    this.calle = '',
    this.ciudad = '',
    this.estado = '',
    DateTime? fechaRegistro,
    this.frecuente = false,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      calle: map['calle']?.toString() ?? '',
      ciudad: map['ciudad']?.toString() ?? '',
      estado: map['estado']?.toString() ?? '',
      fechaRegistro: (map['fechaRegistro'] as dynamic)?.toDate() ?? DateTime.now(),
      frecuente: map['frecuente'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'calle': calle,
      'ciudad': ciudad,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
      'frecuente': frecuente,
    };
  }

  ClientModel copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? correo,
    String? calle,
    String? ciudad,
    String? estado,
    DateTime? fechaRegistro,
    bool? frecuente,
  }) {
    return ClientModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      calle: calle ?? this.calle,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      frecuente: frecuente ?? this.frecuente,
    );
  }
}
