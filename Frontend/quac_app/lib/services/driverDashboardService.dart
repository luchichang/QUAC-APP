// services/driver_dashboard_service.dart

import 'dart:convert';
import 'package:flutter_application_1/const.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/driverDashboardModel.dart';

class DriverDashboardService {
  // get driver dashboard data function from service
  Future<DriverDashboardData?> fetchDriverDashboardData() async {
    // Replace this with your actual API endpoint URL.
    final uri = Uri.parse('$baseUrl/api/driverDashboard/drv-1');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DriverDashboardData.fromJson(jsonData);
      } else {
        // You can throw an exception or return null to handle errors gracefully.
        print(
          'Failed to load dashboard data with status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return null;
    }
  }

  
}
