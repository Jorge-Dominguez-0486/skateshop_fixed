# 🛹 SkateShop App

Aplicación Flutter e-commerce para una tienda de skate con temática oscura Urban Street. Incluye autenticación, catálogo, carrito/checkout, pedidos, perfil y panel de administración CRUD completo.

---

## Configuración de Firebase

### Paso 1: Crear proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Haz clic en **Crear un proyecto**
3. Ingresa el nombre: `skateshop-app`
4. Desactiva **Google Analytics** (no es necesario para este proyecto)
5. Haz clic en **Crear proyecto**

### Paso 2: Registrar apps en Firebase

#### Android
1. En la vista general del proyecto, haz clic en el icono **Android** (`</>`)
2. Package name: `com.example.skateshop_app`
3. Apodo de la app (opcional): `SkateShop Android`
4. Haz clic en **Registrar app**
5. Descarga el archivo `google-services.json`
6. Colócalo en: `android/app/google-services.json`
7. Haz clic en **Siguiente** y luego en **Continuar en la consola**

#### iOS
1. En la vista general del proyecto, haz clic en el icono **iOS** (`</>`)
2. Bundle ID: `com.example.skateshopApp`
3. Apodo de la app (opcional): `SkateShop iOS`
4. Haz clic en **Registrar app**
5. Descarga el archivo `GoogleService-Info.plist`
6. Colócalo en: `ios/Runner/GoogleService-Info.plist` (usando Xcode)
7. Haz clic en **Continuar en la consola**

> **⚠️ Importante:** Nunca subas `google-services.json` ni `GoogleService-Info.plist` a un repositorio público. Ambos archivos ya están incluidos en `.gitignore`.

### Paso 3: Instalar FlutterFire CLI y configurar

```bash
# Activar FlutterFire CLI globalmente
flutter pub global activate flutterfire_cli

# Configurar Firebase en el proyecto
# Reemplaza TU_PROJECT_ID con el ID real de tu proyecto Firebase
flutterfire configure --project=skateshop-app
```

Este comando:
- Lee la configuración de tus apps Android/iOS registradas
- Genera automáticamente `lib/firebase_options.dart` con las credenciales
- Actualiza los archivos de configuración nativos si es necesario

### Paso 4: Habilitar Authentication

1. En Firebase Console → **Authentication** → **Sign-in method**
2. Haz clic en **Email/Password**
3. Activa el interruptor **Habilitar**
4. Haz clic en **Guardar**

### Paso 5: Crear Firestore Database

1. Firebase Console → **Firestore Database** → **Crear base de datos**
2. Selecciona **Modo producción**
3. Elige una ubicación del servidor (ej. `us-central1`)
4. Haz clic en **Crear**

### Paso 6: Publicar reglas de seguridad

El archivo `firestore.rules` en la raíz del proyecto contiene las reglas de seguridad. Las reglas permiten:
- **Usuarios autenticados**: leer todas las colecciones de negocio
- **Usuarios autenticados**: crear su propio documento en `usuarios` (registro)
- **Admins**: lectura/escritura total en todas las colecciones
- **Ventas**: los clientes pueden leer SOLO sus propias ventas

Para publicarlas:

```bash
# Opción A: Usar Firebase CLI
firebase deploy --only firestore:rules

# Opción B: Copiar manualmente desde firestore.rules
# en Firebase Console → Firestore → Rules
```

### Paso 7: Ejecutar seed data (opcional)

En modo debug (`flutter run --debug`), la app inserta automáticamente datos de demostración si las colecciones están vacías:

| Colección | Items |
|-----------|-------|
| `productos` | 8 productos (Tabla Element 8.0, Ruedas Spitfire 52mm, Hoodie Thrasher M, etc.) |
| `marcas` | 5 marcas (Element, Santa Cruz, Thrasher, Vans, Independent) |
| `empleados` | 3 empleados (Carlos Ramírez/Vendedor, Ana López/Cajera, Roberto Soto/Almacenista) |

Para desactivar el seed data, elimina o comenta este bloque en `lib/main.dart`:

```dart
if (kDebugMode) {
  await insertSeedData(FirebaseFirestore.instance);
}
```

### Paso 8: Crear el primer usuario administrador

1. Ejecuta la aplicación: `flutter run`
2. Regístrate con tu correo electrónico y contraseña
3. Ve a Firebase Console → **Firestore** → Colección `usuarios`
4. Encuentra el documento con tu correo
5. Cambia el campo `isAdmin: false` → `isAdmin: true`
6. Cierra sesión en la app y vuelve a iniciarla
7. Ahora verás el ícono **⚡** en la barra superior y acceso al **Panel Admin** en el menú lateral

---

## Colecciones en Firestore

| Colección | Descripción | Acceso |
|-----------|-------------|--------|
| `usuarios` | Usuarios registrados (Firebase Auth + Firestore) | Lectura propia; admins: todo |
| `productos` | Catálogo de productos | Lectura: todos; escritura: admins |
| `clientes` | Clientes registrados | Solo admins |
| `ventas` | Órdenes generadas desde checkout | Lectura: propias; creación: todos; modificación: admins |
| `empleados` | Empleados de la tienda | Solo admins |
| `proveedores` | Proveedores de productos | Solo admins |
| `inventario` | Control de inventario | Solo admins |
| `marcas` | Marcas de productos | Lectura: todos; escritura: admins |

---

## Comandos útiles

```bash
# Ejecutar la aplicación
flutter run

# Ejecutar en modo debug (con seed data automático)
flutter run --debug

# Verificar análisis de código (0 errores, 0 warnings)
flutter analyze

# Obtener dependencias
flutter pub get

# Generar firebase_options.dart (después de cambiar la config de Firebase)
flutterfire configure --project=skateshop-app

# Publicar Firestore Rules
firebase deploy --only firestore:rules
```

---

## Notas importantes

- **Flutter 3.33+**: El proyecto usa `CardThemeData`, `DrawerThemeData` y APIs modernas sin deprecated warnings
- **Provider + ChangeNotifier**: Manejo de estado sin dependencias externas pesadas
- **`showModalBottomSheet`**: Todas las llamadas usan `useRootNavigator: true` para evitar problemas con el Navigator
- **`GoogleFonts.rajdhani()`** y **`GoogleFonts.inter()`** son llamadas en runtime — no se usan en contextos `const`
- **Badges 3.x**: Se importa como `package:badges/badges.dart as badges`
- **Admin CRUD genérico**: `AdminCrudScreen` con `AdminField`/`AdminFieldType` enum genera formularios dinámicos desde configuración
- **Users screen**: Usa `AuthService` directamente — la creación de usuarios desde el panel admin es limitada por Firebase Auth (el método `createUserWithEmailAndPassword` inicia sesión como el nuevo usuario, cerrando la sesión del admin actual)
