import 'package:flutter/material.dart';

class PCartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  PCartItem(
      {
      //
      required this.id,
      required this.title,
      required this.quantity,
      required this.price
      //
      });

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'quantity': quantity, 'price': price};
}

class Cart with ChangeNotifier {
  Map<String, PCartItem> _items = {};

  Map<String, PCartItem> get items {
    return {..._items}; //return a copy
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productID, double price, String title) {
    if (_items.containsKey(productID)) {
      //change quantity
      _items.update(
        productID,
        (existingCartItem) => PCartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
          productID,
          () => PCartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  void removeItem(String productID) {
    _items.remove(productID);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void removeSingeItem(String productID) {
    if (!_items.containsKey(productID)) {
      return;
    }
    if (_items[productID]!.quantity > 1) {
      items.update(
        productID,
        (existingCartItem) => PCartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity - 1,
            price: existingCartItem.price),
      );
    } else {
      _items.remove(productID);
    }
    notifyListeners();
  }
}
