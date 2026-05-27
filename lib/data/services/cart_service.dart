import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  double get total => _items.fold<double>(0, (acc, item) => acc + item.subtotal);

  int get itemCount => _items.length;

  void addItem(CartItemModel item) {
    final index = _items.indexWhere((i) => i.idProducto == item.idProducto);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        cantidad: _items[index].cantidad + item.cantidad,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String idProducto) {
    _items.removeWhere((i) => i.idProducto == idProducto);
    notifyListeners();
  }

  void updateQuantity(String idProducto, int cantidad) {
    final index = _items.indexWhere((i) => i.idProducto == idProducto);
    if (index >= 0) {
      if (cantidad <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(cantidad: cantidad);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
