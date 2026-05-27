class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final bool isAdmin;
  final DateTime fechaRegistro;

  UserModel({
    required this.id,
    this.nombre = '',
    this.correo = '',
    this.telefono = '',
    this.isAdmin = false,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      isAdmin: map['isAdmin'] ?? false,
      fechaRegistro: (map['fechaRegistro'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'isAdmin': isAdmin,
      'fechaRegistro': fechaRegistro,
    };
  }

  UserModel copyWith({
    String? id,
    String? nombre,
    String? correo,
    String? telefono,
    bool? isAdmin,
    DateTime? fechaRegistro,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      isAdmin: isAdmin ?? this.isAdmin,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
