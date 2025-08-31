import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/features/shipping/screens/shipping_address.dart';
import 'package:shopsphere/models/system_settings.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/features/cart/widgets/cart_item.dart';
import 'package:shopsphere/features/cart/services/cart_services.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = "/cart";
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = true;
  SystemSettings? deliveryFeeData;
  SystemSettings? taxFeeData;
  final CartServices cartServices = CartServices();
  final TextEditingController couponController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFeeData();
  }

  Future<void> getFeeData() async {
    deliveryFeeData = await cartServices.getSystemSettingDetailByUniqueName(
      settingUniqueName: 'deliveryFee',
      context: context,
    );
    taxFeeData = await cartServices.getSystemSettingDetailByUniqueName(
      settingUniqueName: 'taxRate',
      context: context,
    );

    if( deliveryFeeData != null ) {
      Provider.of<CartProvider>(context, listen: false).setDeliveryFee(deliveryFeeData!);
    }

    if( taxFeeData != null ) {
      Provider.of<CartProvider>(context, listen: false).setTaxRate(
        double.parse(taxFeeData!.settingValue),
      );
    }
    isLoading = false;
    setState(() {});
  }

  applyCoupon() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    print("Applying coupon: ${couponController.text}");
    final discount = await cartServices.getDiscountByCoupon(
      couponCode: couponController.text,
      context: context,
    );

    print("Discount received: $discount");
    cartProvider.applyDiscount(discount);
    if (discount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Coupon applied! Discount: \$${discount}")),
      );
    }
  }



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
                            Expanded(
                              child: SizedBox(
                                height: 30,
                                child: TextField(
                                  controller: couponController,
                                  decoration: InputDecoration(
                                    
                                    border: InputBorder.none,
                                    hintText: "Enter Your Offer Code",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios, size: 16),
                                onPressed: () {
                                  // Handle coupon code submission
                                  applyCoupon();
                                },
                              ),
                            ),
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
                          Navigator.pushNamed(context, ShippingPage.routeName);
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
