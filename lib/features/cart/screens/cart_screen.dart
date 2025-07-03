import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/features/cart/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = "/cart";
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: cart.cartItems.isEmpty
          ? const Center(child: Text("No items added"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.cartItems.length,
                    itemBuilder: (_, index) =>
                        CartItemTile(item: cart.cartItems[index]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Subtotal: ₹${cart.subtotal}"),
                      Text("Shipping: ₹${cart.shippingCharges}"),
                      Text("Tax: ₹${cart.tax}"),
                      Text("Discount: ₹${cart.discount}", style: const TextStyle(color: Colors.red)),
                      const Divider(),
                      Text("Total: ₹${cart.total}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(hintText: "Coupon Code"),
                        // onChanged: cart.validateCoupon,
                      ),
                      // if (cart.couponApplied)
                      //   Text("✅ Discount Applied", style: const TextStyle(color: Colors.green))
                      // else if (cart.invalidCouponEntered)
                      //   const Text("❌ Invalid Coupon", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      if (cart.cartItems.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/shipping");
                          },
                          child: const Text("Checkout"),
                        ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
