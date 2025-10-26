import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/models/new_order_request.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/features/checkout/services/checkout_services.dart';
class CheckoutScreen extends StatefulWidget {
  final String? clientSecret;
  static const String routeName = "/pay";
  const CheckoutScreen({ Key? key, required this.clientSecret }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutServices checkoutServices = CheckoutServices();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize Stripe PaymentSheet
    _initPaymentSheet();
  }

  Future<void> _initPaymentSheet() async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: widget.clientSecret,
          merchantDisplayName: "ShopSphere",
        ),
      );
    } catch (e) {
      debugPrint("Error initializing payment sheet: $e");
    }
  }
  Future<void> _presentPaymentSheet() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false).user;

    setState(() => _isProcessing = true);

    try {
      await Stripe.instance.presentPaymentSheet();

      /// ✅ Payment Success
      // Here you need to call your backend API to create the order
      final orderData = NewOrderRequest(
        shippingInfo: cart.shippingInfo,
        orderItems: cart.cartItems,
        subtotal: cart.subtotal,
        tax: cart.tax,
        discount: cart.discount,
        shippingCharges: cart.shippingCharges,
        total: cart.total,
        user: user?.id ?? "",
      );

      // TODO: Send orderData to backend via Dio/HTTP
      // final response = await api.createOrder(orderData);
      final  orderId = await checkoutServices.createOrder(context: context, orderData: orderData);

      cart.resetCart(); // Clear cart
print(" Order placed successfully: $orderData ");
      // Fluttertoast.showToast(msg: "Payment successful, order placed!");
      Navigator.pushReplacementNamed(
        context,
        "/order-details",
        arguments: {"orderId": orderId}
      );
    } catch (e) {
      // Fluttertoast.showToast(msg: "Payment failed: $e");
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _presentPaymentSheet,
                child: const Text("Pay Now"),
              ),
      ),
    );
  }
}