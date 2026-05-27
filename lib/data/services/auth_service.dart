import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth? _authInstance;
  FirebaseFirestore? _firestoreInstance;

  FirebaseAuth get _auth {
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }

  FirebaseFirestore get _firestore {
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance!;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<UserModel?> register(
      String email, String password, String nombre, String telefono) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        id: credential.user!.uid,
        nombre: nombre,
        correo: email,
        telefono: telefono,
        isAdmin: false,
      );
      await _firestore.collection('usuarios').doc(user.id).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _getUserFromFirestore(user.uid);
  }

  Future<void> updateUserAdminStatus(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('usuarios').doc(userId).update({
        'isAdmin': isAdmin,
      });
    } catch (e) {
      throw 'Error al actualizar el rol del usuario: $e';
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('usuarios').doc(userId).delete();
    } catch (e) {
      throw 'Error al eliminar el usuario: $e';
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot =
          await _firestore.collection('usuarios').orderBy('nombre').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw 'Error al obtener usuarios: $e';
    }
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc =
          await _firestore.collection('usuarios').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw 'Error al obtener datos del usuario: $e';
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
