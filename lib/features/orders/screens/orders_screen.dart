import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/features/orders/services/orders_services.dart';
import 'package:shopsphere/features/orders/widgets/order_card.dart';
import 'package:shopsphere/models/order.dart';
import 'package:shopsphere/providers/user_provider.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      orders = await OrdersServices().fetchMyOrders(userId: user.id, context: context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) => OrderCard(order: orders[index]),
                ),
    );
  }
}