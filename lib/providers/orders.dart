import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cart.dart';

class POrderItem {
  final id;
  final double amount;
  final List<PCartItem> products;
  final DateTime dateTime;

  POrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});

  factory POrderItem.fromJson(Map<String, dynamic> json) {
    return POrderItem(
        id: json['id'],
        amount: json['amount'],
        products: (json['products'] as List<dynamic>)
            .map((item) => PCartItem(
                id: item['id'],
                title: item['title'],
                quantity: item['quantity'],
                price: item['price']))
            .toList(),
        dateTime: DateTime.parse(json['dateTime']));
  }
}

class Orders with ChangeNotifier {
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId);

  List<POrderItem> _orders = [];

  List<POrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      List<POrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      if (extractedData == null) {
        _orders = [];
        notifyListeners();
        return;
      }

      extractedData.forEach((key, value) {
        POrderItem orderItem = POrderItem.fromJson(extractedData[key]);
        loadedOrders.add(orderItem);
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<PCartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts

          // Im not sure if i need to encode to json format, seems lite firebase do it automatically...
          // 'products': cartProducts.map((cp) => {
          //       'id': cp.id,
          //       'title': cp.title,
          //       'quantity': cp.quantity,
          //       'price': cp.price
          //     })
        }));
    // print(jsonEncode(cartProducts));

    _orders.insert(
        0,
        POrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: DateTime.now()));
    notifyListeners();
  }
}
