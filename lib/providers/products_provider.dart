import '../models/http_exception.dart';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String? authToken;
  final String? userId;
  Products(this.authToken, this._items, this.userId);

  // var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData =
          await json.decode(response.body) as Map<String, dynamic>;

      url = Uri.parse(
          'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.insert(
            0,
            Product(
                id: prodId,
                title: prodData['title'],
                description: prodData['description'],
                price: prodData['price'],
                isFavorite: favoriteData == null
                    ? false
                    : favoriteData[prodId] ?? false,
                imageUrl: prodData['imageUrl']));
      });
      _items = loadedProducts;

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'userId': userId
        }),
      );
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price
        }));
    final prodIndex = _items.indexWhere((element) => element.id == id);
    _items[prodIndex] = newProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('could not delete product');
    } else
      existingProduct = null;
  }

  Future<String> markFavorite(String productId) async {
    final url = Uri.parse(
        'https://maxshopapp-ed216-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$productId/.json?auth=$authToken');

    //We make here a rollback in case something will be wrong with the server

    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    Product? existingProduct =
        _items.firstWhere((element) => element.id == productId);
    _items[existingProductIndex].isFavorite =
        !_items[existingProductIndex].isFavorite;

    final response =
        await http.put(url, body: json.encode(existingProduct.isFavorite));

    if (response.statusCode >= 400) {
      _items[existingProductIndex].isFavorite =
          !_items[existingProductIndex].isFavorite;
      _items[existingProductIndex].throwError = true;
      return 'Error';
    } else {
      existingProduct = null;
    }

    notifyListeners();
    return 'Success';
  }
}
