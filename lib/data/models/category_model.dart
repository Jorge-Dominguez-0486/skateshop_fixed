import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int orden;
  final bool activo;
  final DateTime fechaCreacion;

  CategoryModel({
    required this.id,
    this.nombre = '',
    this.descripcion = '',
    this.icono = 'skateboarding',
    this.orden = 1,
    this.activo = true,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      icono: map['icono']?.toString() ?? 'skateboarding',
      orden: (map['orden'] ?? 1).toInt(),
      activo: map['activo'] ?? true,
      fechaCreacion: (map['fechaCreacion'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'orden': orden,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    int? orden,
    bool? activo,
    DateTime? fechaCreacion,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  IconData get iconData {
    switch (icono) {
      case 'skateboarding': return Icons.skateboarding;
      case 'checkroom': return Icons.checkroom;
      case 'settings': return Icons.settings;
      case 'directions_run': return Icons.directions_run;
      case 'star': return Icons.star;
      case 'new_releases': return Icons.new_releases;
      default: return Icons.category;
    }
  }
}
