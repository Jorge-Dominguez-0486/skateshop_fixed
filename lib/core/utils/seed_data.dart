import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

Future<void> insertSeedData(FirebaseFirestore db) async {
  await _insertCategories(db);
  await _insertProducts(db);
  await _insertBrands(db);
  await _insertEmployees(db);
}

Future<void> _insertCategories(FirebaseFirestore db) async {
  final existing = await db.collection('categorias').limit(1).get();
  if (existing.docs.isNotEmpty) return;

  final categories = [
    {'nombre': 'Skateboard', 'descripcion': 'Tablas, ejes y ruedas', 'icono': 'skateboarding', 'orden': 1},
    {'nombre': 'Ropa', 'descripcion': 'Camisetas, hoodies y pantalones', 'icono': 'checkroom', 'orden': 2},
    {'nombre': 'Accesorios', 'descripcion': 'Cascos, rodilleras y herramientas', 'icono': 'settings', 'orden': 3},
    {'nombre': 'Tenis', 'descripcion': 'Calzado especializado para skate', 'icono': 'directions_run', 'orden': 4},
  ];

  final batch = db.batch();
  for (final c in categories) {
    final docRef = db.collection('categorias').doc(_uuid.v4());
    batch.set(docRef, {
      'id': docRef.id,
      'nombre': c['nombre'],
      'descripcion': c['descripcion'],
      'icono': c['icono'],
      'orden': c['orden'],
      'activo': true,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}

Future<void> _insertProducts(FirebaseFirestore db) async {
  final existing = await db.collection('productos').limit(1).get();
  if (existing.docs.isNotEmpty) return;

  final products = [
    {
      'nombre': 'Tabla Element 8.0',
      'categoria': 'Skateboard',
      'marca': 'Element',
      'precio': 1299.99,
      'stock': 15,
      'color': 'Negro',
      'talla': null,
    },
    {
      'nombre': 'Tabla Santa Cruz 8.25',
      'categoria': 'Skateboard',
      'marca': 'Santa Cruz',
      'precio': 1499.00,
      'stock': 8,
      'color': '',
      'talla': null,
    },
    {
      'nombre': 'Ruedas Spitfire 52mm',
      'categoria': 'Accesorios',
      'marca': 'Spitfire',
      'precio': 499.00,
      'stock': 30,
      'color': '',
      'talla': null,
    },
    {
      'nombre': 'Trucks Independent 149',
      'categoria': 'Accesorios',
      'marca': 'Independent',
      'precio': 699.00,
      'stock': 20,
      'color': '',
      'talla': null,
    },
    {
      'nombre': 'Hoodie Thrasher M',
      'categoria': 'Ropa',
      'marca': 'Thrasher',
      'precio': 850.00,
      'stock': 12,
      'color': '',
      'talla': 'M',
    },
    {
      'nombre': 'Camiseta Element L',
      'categoria': 'Ropa',
      'marca': 'Element',
      'precio': 349.00,
      'stock': 25,
      'color': '',
      'talla': 'L',
    },
    {
      'nombre': 'Tenis Vans Old Skool 27',
      'categoria': 'Tenis',
      'marca': 'Vans',
      'precio': 1200.00,
      'stock': 6,
      'color': '',
      'talla': '27',
    },
    {
      'nombre': 'Casco Pro-Tec M',
      'categoria': 'Accesorios',
      'marca': 'Pro-Tec',
      'precio': 750.00,
      'stock': 10,
      'color': '',
      'talla': 'M',
    },
  ];

  final batch = db.batch();
  for (final p in products) {
    final docRef = db.collection('productos').doc(_uuid.v4());
    batch.set(docRef, {
      'id': docRef.id,
      'nombre': p['nombre'],
      'categoria': p['categoria'],
      'marca': p['marca'],
      'precio': p['precio'],
      'stock': p['stock'],
      'color': p['color'],
      'talla': p['talla'],
      'material': '',
      'imageUrl': null,
      'fechaIngreso': FieldValue.serverTimestamp(),
      'activo': true,
    });
  }
  await batch.commit();
}

Future<void> _insertBrands(FirebaseFirestore db) async {
  final existing = await db.collection('marcas').limit(1).get();
  if (existing.docs.isNotEmpty) return;

  final brands = [
    {'nombre': 'Element', 'pais': 'USA'},
    {'nombre': 'Santa Cruz', 'pais': 'USA'},
    {'nombre': 'Thrasher', 'pais': 'USA'},
    {'nombre': 'Vans', 'pais': 'USA'},
    {'nombre': 'Independent', 'pais': 'USA'},
  ];

  final batch = db.batch();
  for (final b in brands) {
    final docRef = db.collection('marcas').doc(_uuid.v4());
    batch.set(docRef, {
      'id': docRef.id,
      'nombre': b['nombre'],
      'pais': b['pais'],
      'logoUrl': null,
      'descripcion': '',
      'categorias': [],
      'activo': true,
    });
  }
  await batch.commit();
}

Future<void> _insertEmployees(FirebaseFirestore db) async {
  final existing = await db.collection('empleados').limit(1).get();
  if (existing.docs.isNotEmpty) return;

  final employees = [
    {'nombre': 'Carlos Ramírez', 'puesto': 'Vendedor', 'sueldo': 6500.00},
    {'nombre': 'Ana López', 'puesto': 'Cajera', 'sueldo': 5800.00},
    {'nombre': 'Roberto Soto', 'puesto': 'Almacenista', 'sueldo': 5200.00},
  ];

  final batch = db.batch();
  for (final e in employees) {
    final docRef = db.collection('empleados').doc(_uuid.v4());
    batch.set(docRef, {
      'id': docRef.id,
      'nombre': e['nombre'],
      'puesto': e['puesto'],
      'sueldo': e['sueldo'],
      'telefono': '',
      'correo': '',
      'fechaIngreso': FieldValue.serverTimestamp(),
      'activo': true,
    });
  }
  await batch.commit();
}
