import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  List<Product> _items = dummyProducts;
  final _baseURL = "https://shop-rest-api-default-rtdb.firebaseio.com/";
  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  int get itemsCount {
    return _items.length;
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) {
    // PARA ADICIONAR/ ENVIAR INFORMAÇÕES PARA O BANCO DE DADOS
    // UTILIZANDO UMA API REST É NECESSÁRIO UTILIZAR O post();
    // O POST RECEBE UM URI QUE RECEBE UM CAMINHO NESSE CASO O
    // /products.json, ESSE CAMINHO VAI PARA O BANCO DE DADOS QUE É
    // EM FORMATO JSON, SENDO OBRIGATORIO TER O .json no final
    // O URI TMB RECEBE UM BODY COM UM MAP QUE É CRIADO COM {},
    // PARA ISSO UTILIZA-SE O jsonEncode(), COM O MAP PASSAMOS
    // OS VALORES QUE QUEREMOS ENVIAR PARA O BANCO DE DADOS QUE SÃO
    // AS INFORMAÇÕES DE CADA PRODUTO!
    final future = http.post(Uri.parse("$_baseURL/products.json"),
        body: jsonEncode({
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        }));
    return future.then((value) {
      // O THEN É EXECUTADO DEPOIS QUE AS INFORMAÇÕES
      // IREM PARA O BACKEND E RETORNAREM AO USUÁRIO
      _items.add(Product(
          id: jsonDecode(value.body)['name'],
          name: product.name,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl));
      notifyListeners();
    });
  }

  Future<void> updateProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
    return Future.value(); // RETORNARÁ NADA(VOID)!
  }

  void removeProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _items.removeWhere((p) => p.id == product.id);
      notifyListeners();
    }
  }
}

// bool _showFavoriteOnly = false;

// List<Product> get items {
//   if (_showFavoriteOnly) {
//     return _items.where((prod) => prod.isFavorite).toList();
//   }
//   return [..._items];
// }

// void showFavoriteOnly() {
//   _showFavoriteOnly = true;
//   notifyListeners();
// }

// void showAll() {
//   _showFavoriteOnly = false;
//   notifyListeners();
// }
