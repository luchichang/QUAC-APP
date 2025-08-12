// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// package local imports
import 'package:flutter_application_1/model/driverDashboardModel.dart';
import 'package:flutter_application_1/services/driverDashboardService.dart';
import 'package:flutter_application_1/model/order_model.dart';
import 'package:flutter_application_1/services/orderService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quac App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String orderId = 'ord-1';

  // boolean value for showing the driver Dashboard
  bool isDriverDashboard = false;

  DriverDashboardData? _dashboardData;
  bool _isDashboardLoading = false;
  OrderModel? _orderdata;
  bool _isOrderFetching = false;

  // declaring the driver dashboard service object
  final DriverDashboardService _dashboardService = DriverDashboardService();
  final OrderService _orderService = OrderService();

  // Controller for the Google Map
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Set of all markers to be displayed on the map
  Set<Marker> _markers = {};

  // Set of polylines to draw the route
  Set<Polyline> _polylines = {};

  // Default camera position
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  // User's current position
  Position? _currentPosition;

  // List of other locations to visit
  final List<LatLng> _destinationLocations = const [
    LatLng(37.427961, -122.085750),
    LatLng(37.432962, -122.088751),
    LatLng(37.430963, -122.082752),
    LatLng(37.425964, -122.079753),
    LatLng(37.420965, -122.083754),
    LatLng(37.415966, -122.087755),
    LatLng(37.418967, -122.091756),
    LatLng(37.423968, -122.095757),
    LatLng(37.428969, -122.092758),
    LatLng(37.435970, -122.089759),
  ];

  @override
  void initState() {
    super.initState();

    // fetch order data
    _fetchOrderData(orderId: orderId);

    // function for checking the location permission
    _checkLocationPermission();
  }

  // retrieving dashboard data
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isDashboardLoading = true;
      _dashboardData = null;
    });

    final data = await _dashboardService.fetchDriverDashboardData();

    setState(() {
      _dashboardData = data;
      _isDashboardLoading = false;
    });
  }

  // Method to check and request location permissions
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("_check Loc Permission, is Location service Enabled $serviceEnabled");
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    print("_geolocator request permission status, $permission");
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Get the user's current position after permissions are granted
    _getCurrentLocation();
  }

  // Method to get the user's current location and initialize the map
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Users current Poisition $position");
      setState(() {
        _currentPosition = position;
        _addMarkers();
      });
      // Move camera to the user's current location
      _animateCameraToPosition(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // Method to add all markers to the map
  void _addMarkers() {
    if (_currentPosition == null) return;

    final newMarkers = <Marker>{};

    // Add marker for the user's current location
    final userLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    newMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: userLatLng,
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Add markers for the other 10 destination locations
    for (int i = 0; i < _destinationLocations.length; i++) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('destination_$i'),
          position: _destinationLocations[i],
          infoWindow: InfoWindow(title: 'Destination ${i + 1}'),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  // Method to find the optimal route using a nearest-neighbor heuristic
  void _findOptimalRoute() {
    if (_currentPosition == null || _destinationLocations.isEmpty) {
      return;
    }

    final List<LatLng> path = [];
    final List<LatLng> unvisitedPoints = List.from(_destinationLocations);
    LatLng currentPoint = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    path.add(currentPoint);

    // Nearest-neighbor algorithm
    while (unvisitedPoints.isNotEmpty) {
      double minDistance = double.infinity;
      LatLng? nearestPoint;
      for (final point in unvisitedPoints) {
        final distance = _calculateDistance(currentPoint, point);
        if (distance < minDistance) {
          minDistance = distance;
          nearestPoint = point;
        }
      }
      if (nearestPoint != null) {
        path.add(nearestPoint);
        unvisitedPoints.remove(nearestPoint);
        currentPoint = nearestPoint;
      }
    }

    // Draw the polyline on the map
    _drawPolyline(path);
  }

  // Method to calculate the distance between two LatLng points
  double _calculateDistance(LatLng p1, LatLng p2) {
    return Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
  }

  // Method to draw the polyline for the route
  void _drawPolyline(List<LatLng> points) {
    final Polyline polyline = Polyline(
      polylineId: const PolylineId('optimal_route'),
      color: Colors.blue,
      width: 5,
      points: points,
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  // Method to animate the camera to a specific position
  Future<void> _animateCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14.0),
      ),
    );
  }

  // retrieving order data
  Future<void> _fetchOrderData({required String orderId}) async {
    setState(() {
      _isOrderFetching = true;
      _orderdata = null;
    });
    final data = await _orderService.fetchOrderData(orderId: orderId);
    setState(() {
      _orderdata = data;
      _isOrderFetching = false;
    });
  }

  // This function simulates showing an order completion dialog.
  // In a real app, this would be triggered after a successful API call.
  void _showOrderCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Order Delivered Successfully!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/celebration.png',
                height: 80,
              ), // Use an asset image or a custom icon
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showOrderStatsDialog(
                    orderId: 'ord-2',
                  ); // Show stats after "OK" is pressed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderStatsDialog({required String orderId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Order 3 Stats;',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Id    : $orderId'),
              Text('Tip Earned  : ₹ 20'), // Placeholder for tip amount
              const Text('Rating      : 4'), // Placeholder for rating
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Next Order',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                // TODO: Add logic to fetch the next order from your API
                _fetchOrderData(orderId: orderId);

                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.double_arrow_outlined,
                color: Colors.green,
              ),
              onPressed: () {
                // TODO: Add logic to fetch the next order from your API
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDriverDashboard({
    required double height,
    required double width,
  }) {
    if (_isDashboardLoading) {
      return Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_dashboardData == null) {
      return Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Container(
          height: height * 0.1,
          width: width * 0.75,
          padding: const EdgeInsets.all(10),
          // margin: const EdgeInsets.,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text('Failed Loading  Dashboard data.')),
        ),
      );
    }
    return Positioned(
      top: height * 0.025,
      left: width * 0.1,
      right: width * 0.025,
      child: Container(
        height: height * 0.15,
        width: width * 0.75,
        padding: const EdgeInsets.all(10),
        // margin: const EdgeInsets.,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(width: width * 0.05),
            // const Icon(Icons.person, size: 40),
            _buildStatusItem(
              _dashboardData!.tipsEarned,
              'Tips Earned',
              width: width,
            ),
            _buildStatusItem(
              _dashboardData!.overallRating,
              'Overall Rating',
              width: width,
            ),
            _buildStatusItem(
              _dashboardData!.orderStatus,
              'Order Status',
              width: width,
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverDashboardToggleButton({
    required double height,
    required double width,
  }) {
    return Positioned(
      top: isDriverDashboard ? height * 0.06 : height * 0.025,
      left: width * 0.03,

      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            isDriverDashboard = !isDriverDashboard;
            if (isDriverDashboard && _dashboardData == null) {
              _fetchDashboardData();
            }
          });
        },
        backgroundColor: Colors.amber,
        shape: const CircleBorder(),
        child: isDriverDashboard
            ? Icon(Icons.exit_to_app, size: width * 0.08)
            : Image.asset(
                'assets/user-Icon.png',
                fit: BoxFit.fill,
                width: width * 0.09,
                height: height * 0.035,
              ),
      ),
    );
  }

  // for order dashboard
  List<Widget> _setLabelValue({
    required String label,
    required String value,
    required double width,
  }) {
    return [
      Text(
        label,
        style: TextStyle(fontSize: width * 0.04, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(width: width * 0.01),
      Text(
        value,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.04),
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }

  // for driver dashboard
  Widget _buildStatusItem(String value, String label, {required double width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.08),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(fontSize: width * 0.04, color: Colors.grey),
        ),
      ],
    );
  }

  // action Button
  Widget _buildActionButton({
    required double height,
    required double width,
    required String imgPath,
  }) {
    return InkWell(
      onTap: () {
        _showOrderCompletionDialog();
      },
      child: SizedBox(
        height: height * 0.08,
        width: width * 0.1,
        child: Image.asset(imgPath),
      ),
    );
  }

  Widget _buildBottomOrderCard({
    required double height,
    required double width,
  }) {
    if (_isOrderFetching) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(15),
          width: width,
          height: height * 0.2,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(width * 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_orderdata == null) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(15),
          width: width,
          height: height * 0.2,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(width * 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text('Failed Loading Order Data.')),
        ),
      );
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(15),
          width: width,
          height: height * 0.2,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(width * 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: height * 0.005,
                width: width * 0.3,
                margin: EdgeInsets.only(bottom: height * 0.005),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(width * 0.1)),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    //order Details
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            _orderdata!.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.06,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              ..._setLabelValue(
                                label: 'Order:',
                                value: _orderdata!.orderName,
                                width: width,
                              ),
                              SizedBox(width: width * 0.05),
                              ..._setLabelValue(
                                label: 'Id:',
                                value: _orderdata!.orderId,
                                width: width,
                              ),
                            ],
                          ),
                          Text(
                            "${_orderdata!.userAddress.street},\n${_orderdata!.userAddress.area},\n${_orderdata!.userAddress.city}.",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // order price & caller action
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "₹ ${(double.tryParse(_orderdata!.orderPrice) ?? 0.00).toStringAsFixed(1)}",
                            style: TextStyle(
                              fontSize: width * 0.07,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildActionButton(
                                height: height,
                                width: width,
                                imgPath: 'assets/message-Icon.png',
                              ),
                              _buildActionButton(
                                height: height,
                                width: width,
                                imgPath: 'assets/phone-Icon.png',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // responsive height and width
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // This container represents the map view.
            // You would replace this with a GoogleMaps widget in a real application.
            (_currentPosition == null)
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
            Positioned(
              right: width * 0.05,
              bottom: height * 0.3,
              child: FloatingActionButton(
                onPressed: _findOptimalRoute,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.route),
              ),
            ),
            const SizedBox(height: 10),
            Positioned(
              right: width * 0.05,
              bottom: height * 0.38,
              child: FloatingActionButton(
                onPressed: () {
                  if (_currentPosition != null) {
                    _animateCameraToPosition(
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                    );
                  }
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.my_location),
              ),
            ),

            // Speed indicator on the map
            Positioned(
              bottom: 220,
              right: 25,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Text(
                  '30 Km/h',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (isDriverDashboard)
              _buildDriverDashboard(height: height, width: width),
            _driverDashboardToggleButton(height: height, width: width),
            // Top status bar with tips, rating, and order status

            // Bottom card with order details and action buttons
            _buildBottomOrderCard(height: height, width: width),
          ],
        ),
      ),
    );
  }
}
