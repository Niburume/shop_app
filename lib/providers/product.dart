import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './products_provider.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  bool throwError = false;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<String> toggleFavoriteStatus(BuildContext ctx, String id) {
    return Provider.of<Products>(ctx, listen: false).markFavorite(id);
  }
}
