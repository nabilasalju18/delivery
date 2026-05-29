import 'package:flutter/material.dart';

class FavoritProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favoritItem = [];
  List<Map<String, dynamic>> get favoritItem => _favoritItem;
  void toggleFavorit(Map<String, dynamic> product) {
    final isExist = _favoritItem.any(
      (item) => item['id'] == product['id'],
    );
    if (isExist) {
      _favoritItem.removeWhere(
        (item) => item['id'] == product['id'],
      );
    } else {
      _favoritItem.add(product);
    }
    notifyListeners();
  }
  bool isFavorit(Map<String, dynamic> product) {
    return _favoritItem.any(
      (item) => item['id'] == product['id'],
    );
  }
}