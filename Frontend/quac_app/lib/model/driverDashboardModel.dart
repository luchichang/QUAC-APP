// import 'dart:convert';

// Data model for the driver dashboard information.
class DriverDashboardData {
  final String tipsEarned;
  final String overallRating;
  final String orderStatus;

  DriverDashboardData({
    required this.tipsEarned,
    required this.overallRating,
    required this.orderStatus,
  });

  // json Serialization
  factory DriverDashboardData.fromJson(Map<String, dynamic> json) {
    // print("JsonSerialization");
    return DriverDashboardData(
      tipsEarned: json['driver_tip'] ?? '₹ 0',
      overallRating: json['driver_rating'] ?? '0.0/5',
      orderStatus:
          '${json['completed_orders'] ?? 0}/${json['total_order'] ?? 0} ',
    );
  }
}
