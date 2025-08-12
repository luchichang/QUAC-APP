import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/model/order_model.dart';
import 'package:flutter_application_1/const.dart';

class OrderService {
  // Future
  Future<OrderModel?> fetchOrderData({required String orderId}) async {
    final uri = Uri.parse('$baseUrl/api/getOrder/$orderId');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('order data $jsonData');
        return OrderModel.fromJson(jsonData);
      } else {
        // You can throw an exception or return null to handle errors gracefully.
        print(
          'Failed to load dashboard data with status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print("Error Fetching Order Service: $e");
      return null;
    }
  }
}
