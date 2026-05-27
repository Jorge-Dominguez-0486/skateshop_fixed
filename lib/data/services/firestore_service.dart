import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  FirebaseFirestore? _instance;
  final Uuid _uuid = const Uuid();

  FirebaseFirestore get _db {
    _instance ??= FirebaseFirestore.instance;
    return _instance!;
  }

  static const String productos = 'productos';
  static const String clientes = 'clientes';
  static const String ventas = 'ventas';
  static const String empleados = 'empleados';
  static const String proveedores = 'proveedores';
  static const String inventario = 'inventario';
  static const String marcas = 'marcas';
  static const String usuarios = 'usuarios';
  static const String categorias = 'categorias';

  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    try {
      final snapshot =
          await _db.collection(collection).orderBy('nombre').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw 'Error al obtener documentos de $collection: $e';
    }
  }

  Future<Map<String, dynamic>?> getById(
      String collection, String id) async {
    try {
      final doc = await _db.collection(collection).doc(id).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw 'Error al obtener documento de $collection: $e';
    }
  }

  Future<String> add(String collection, Map<String, dynamic> data) async {
    try {
      final id = _uuid.v4();
      data['id'] = id;
      await _db.collection(collection).doc(id).set(data);
      return id;
    } catch (e) {
      throw 'Error al agregar documento a $collection: $e';
    }
  }

  Future<void> update(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(id).update(data);
    } catch (e) {
      throw 'Error al actualizar documento en $collection: $e';
    }
  }

  Future<void> delete(String collection, String id) async {
    try {
      await _db.collection(collection).doc(id).delete();
    } catch (e) {
      throw 'Error al eliminar documento de $collection: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> streamAll(String collection) {
    return _db
        .collection(collection)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
