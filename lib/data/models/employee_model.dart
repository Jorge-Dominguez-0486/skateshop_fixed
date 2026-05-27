class EmployeeModel {
  final String id;
  final String nombre;
  final String puesto;
  final double sueldo;
  final String telefono;
  final String correo;
  final DateTime fechaIngreso;
  final bool activo;

  EmployeeModel({
    required this.id,
    this.nombre = '',
    this.puesto = '',
    this.sueldo = 0,
    this.telefono = '',
    this.correo = '',
    DateTime? fechaIngreso,
    this.activo = true,
  }) : fechaIngreso = fechaIngreso ?? DateTime.now();

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      puesto: map['puesto']?.toString() ?? '',
      sueldo: (map['sueldo'] ?? 0).toDouble(),
      telefono: map['telefono']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      fechaIngreso: (map['fechaIngreso'] as dynamic)?.toDate() ?? DateTime.now(),
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'puesto': puesto,
      'sueldo': sueldo,
      'telefono': telefono,
      'correo': correo,
      'fechaIngreso': fechaIngreso,
      'activo': activo,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? nombre,
    String? puesto,
    double? sueldo,
    String? telefono,
    String? correo,
    DateTime? fechaIngreso,
    bool? activo,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      puesto: puesto ?? this.puesto,
      sueldo: sueldo ?? this.sueldo,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      activo: activo ?? this.activo,
    );
  }
}
