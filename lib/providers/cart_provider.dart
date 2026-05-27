import 'package:flutter/foundation.dart';
import '../data/models/cart_item_model.dart';
import '../data/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> get items => _cartService.items;
  int get itemCount => _cartService.itemCount;
  double get total => _cartService.total;
  bool get isEmpty => _cartService.itemCount == 0;

  CartProvider() {
    _cartService.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    notifyListeners();
  }

  void addItem(CartItemModel item) {
    _cartService.addItem(item);
  }

  void removeItem(String idProducto) {
    _cartService.removeItem(idProducto);
  }

  void updateQuantity(String idProducto, int cantidad) {
    _cartService.updateQuantity(idProducto, cantidad);
  }

  void clearCart() {
    _cartService.clearCart();
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }
}
