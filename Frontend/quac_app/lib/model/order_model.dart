class OrderModel {
  final String userName;
  final String userMobile;
  final AddressModel userAddress;
  final String orderName;
  final String orderId;
  final String orderPrice;

  // constructor
  OrderModel({
    required this.orderId,
    required this.orderName,
    required this.orderPrice,
    required this.userAddress,
    required this.userMobile,
    required this.userName,
  });

  // factory function for JSON serialization
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    print("Order Model Json Serialization");
    return OrderModel(
      orderId: json['order']['order_id'] ?? 'N/A',
      orderName: json['order']['order_name'] ?? 'N/A',
      orderPrice: json['order']['order_price'] ?? '₹ 0',
      userAddress: AddressModel.fromJson(json['user']['user_address']),
      userMobile: json['user']['user_mobile'] ?? '00000',
      userName: json['user']['user_name'] ?? 'N/A',
    );
  }
}

// Address Class

class AddressModel {
  final String street;
  final String area;
  final String city;

  // constructor
  AddressModel({required this.area, required this.city, required this.street});

  // factory constructor
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
    );
  }

  @override
  String toString() => '$street, $area, $city';
}
