import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/features/cart/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = "/cart";
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        centerTitle: true,
        elevation: 0,
      ),
      body: cart.cartItems.isEmpty
          ? const Center(child: Text("No items added"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.cartItems.length,
                    itemBuilder: (_, index) =>
                        CartItemTile(item: cart.cartItems[index]),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, -1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Have a coupon code ? enter here",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                          // borderStyle: BorderStyle.solid,
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer_outlined,
                                size: 18, color: GlobalVariables.selectedNavBarColor),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Enter Your Offer Code",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Subtotal :"),
                          Text("\$${cart.subtotal.toStringAsFixed(2)}")
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Shipping Charges :"),
                          Text('\$${cart.shippingCharges}')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tax :"),
                          Text('\$${cart.tax}')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Discount :"),
                          Text('-\$${cart.discount}')
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            "\$${cart.total.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/shipping");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: GlobalVariables.selectedNavBarColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Center(
                          child: Text(
                            "Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                              ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
