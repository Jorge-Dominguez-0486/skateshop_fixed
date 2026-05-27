import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/services/firestore_service.dart';

class ProductsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<ProductModel> get filteredProducts {
    var result = _products.where((p) => p.activo).toList();
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result =
          result.where((p) => p.categoria == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data =
          await _firestoreService.getAll(FirestoreService.productos);
      _products = data.map((e) => ProductModel.fromMap(e)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestoreService.add(FirestoreService.productos, product.toMap());
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestoreService.update(
        FirestoreService.productos, product.id, product.toMap());
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _firestoreService.delete(FirestoreService.productos, id);
    await loadProducts();
  }
}
