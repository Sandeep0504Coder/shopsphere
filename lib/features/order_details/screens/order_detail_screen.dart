import 'package:flutter/material.dart';
import 'package:shopsphere/constants/utils.dart';
import 'package:shopsphere/features/order_details/services/order_detail_services.dart';
import 'package:shopsphere/models/order.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingOrderScreen extends StatefulWidget {
  static const String routeName = '/order-details';
  final String orderId;

  const TrackingOrderScreen({required this.orderId, super.key});

  @override
  State<TrackingOrderScreen> createState() => _TrackingOrderScreenState();
}

class _TrackingOrderScreenState extends State<TrackingOrderScreen> {
  Order? order;
  OrderDetailServices orderDetailServices = OrderDetailServices();
  // GoogleMapController? mapController;

  // final LatLng _center = const LatLng(37.7749, -122.4194); // San Francisco

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Fetch order details using widget.orderId
    print("Order ID: ${widget.orderId}");
    _fetchOrderDetails();
    
  }

  void _fetchOrderDetails() async {
    order = await orderDetailServices.fetchOrderDetails(id: widget.orderId, context: context);
    print("Fetched Order: ${order?.toJson()}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Column(
          children: [
            Text(
              "Tracking Orders",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              "#0123456",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 8),
        ],
      ),
      body: order == null ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(
          children: [
            ...order!.orderItems.map((item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.photo,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        item.variant != null ? Text(getSelectedConfigName(item.variant!),
                            style: TextStyle(color: Colors.grey, fontSize: 12)) : const SizedBox.shrink(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(item.price.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(width: 6),
                            // const Text("\$200.10",
                            //     style: TextStyle(
                            //       color: Colors.grey,
                            //       fontSize: 12,
                            //       decoration: TextDecoration.lineThrough,
                            //     )),
                            const Spacer(),
                            Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.15),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.shopping_bag, size: 18, color: Colors.pink.shade400),
      const SizedBox(width: 6),
      Text(
        item.quantity.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    ],
  ),
)
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),),
            // // Product card
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: const BoxDecoration(
            //     color: Colors.white,
            //     boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            //   ),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       ClipRRect(
            //         borderRadius: BorderRadius.circular(8),
            //         child: Image.network(
            //           "https://cdn.pixabay.com/photo/2017/08/06/00/10/people-2588594_1280.jpg",
            //           width: 70,
            //           height: 70,
            //           fit: BoxFit.cover,
            //         ),
            //       ),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             const Text("Peter England Casual",
            //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            //             const SizedBox(height: 4),
            //             const Text("Peter Longline Pure Cotten Tshirt",
            //                 style: TextStyle(color: Colors.grey, fontSize: 12)),
            //             const SizedBox(height: 8),
            //             Row(
            //               children: [
            //                 const Text("\$158.15",
            //                     style: TextStyle(
            //                         color: Colors.black,
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 16)),
            //                 const SizedBox(width: 6),
            //                 const Text("\$200.10",
            //                     style: TextStyle(
            //                       color: Colors.grey,
            //                       fontSize: 12,
            //                       decoration: TextDecoration.lineThrough,
            //                     )),
            //                 const Spacer(),
            //                 Container(
            //                   decoration: BoxDecoration(
            //                     border: Border.all(color: Colors.grey.shade300),
            //                     borderRadius: BorderRadius.circular(6),
            //                   ),
            //                   child: Row(
            //                     children: [
            //                       IconButton(
            //                         onPressed: () {},
            //                         icon: const Icon(Icons.remove, size: 18),
            //                       ),
            //                       const Text("0"),
            //                       IconButton(
            //                         onPressed: () {},
            //                         icon: const Icon(Icons.add, size: 18),
            //                       ),
            //                     ],
            //                   ),
            //                 )
            //               ],
            //             )
            //           ],
            //         ),
            //       )
            //     ],
            //   ),
            // ),

            // Map
            // SizedBox(
            //   height: 200,
            //   child: GoogleMap(
            //     onMapCreated: _onMapCreated,
            //     initialCameraPosition: CameraPosition(
            //       target: _center,
            //       zoom: 13.0,
            //     ),
            //     markers: {
            //       const Marker(
            //         markerId: MarkerId("paintedLadies"),
            //         position: LatLng(37.776, -122.434),
            //       )
            //     },
            //   ),
            // ),

            // Order Status
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Status",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 20),

                  // Dynamic Timeline based on order.status
                  _buildStatusTimeline(order!.status),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String subtitle,
    Widget? child,
    bool active = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: active ? Colors.pink : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: active ? Colors.pink : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (child != null) ...[
                  const SizedBox(height: 8),
                  child,
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Replace static timeline with this dynamic builder
  Widget _buildStatusTimeline(String status) {
    // Only three statuses
    final List<Map<String, dynamic>> statusSteps = [
      {
        "title": "Processing",
        "subtitle": "Your order is being prepared.",
      },
      {
        "title": "Shipped",
        "subtitle": "Your order has been shipped.",
      },
      {
        "title": "Delivered",
        "subtitle": "Order delivered successfully.",
      },
    ];

    int currentStep = statusSteps.indexWhere((step) => step["title"] == status);
    if (currentStep == -1) currentStep = 0;

    List<Map<String, dynamic>> visibleSteps = statusSteps.sublist(0, currentStep + 1);

    return Column(
      children: [
        for (int i = 0; i < visibleSteps.length; i++)
          _buildStatusItem(
            active: i == currentStep,
            title: visibleSteps[i]["title"],
            subtitle: visibleSteps[i]["subtitle"],
            // You can add a child widget for "Shipped" if needed
          ),
      ],
    );
  }
}
