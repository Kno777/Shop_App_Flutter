import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.dateTime,
    required this.amount,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this._orders, {required this.authToken, required this.userId});

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-update-f4bf7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(Uri.parse(url));
    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    if(extractedData == null) return;
    final List<OrderItem> loadedOrders = [];
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          dateTime: DateTime.parse(orderData['dateTime']),
          amount: double.parse(orderData['amount']),
          products: (orderData['products'] as List<dynamic>).map(
            (item) => CartItem(
              id: item['id'],
              title: item['title'],
              price: item['price'],
              quantity: item['quantity'],
            ),
          ).toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-update-f4bf7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';

    final response = await http.post(Uri.parse(url),
        body: jsonEncode({
          'amount': total.toString(),
          'dateTime': DateTime.now().toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(response.body)['name'],
        dateTime: DateTime.now(),
        amount: total,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
