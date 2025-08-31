import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/models/product_variant.dart';
import 'package:shopsphere/features/product_details/screens/product_details_screen.dart';
import 'package:shopsphere/models/product.dart';
class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  String getSelectedConfigName(ProductVariant variant) {
    final configList = variant.configuration;
    if (configList.isEmpty) return "";

    final buffer = StringBuffer(" ( ");
    for (int i = 0; i < configList.length; i++) {
      final config = configList[i];
      final key = config.key.toUpperCase();
      final value = config.value.toUpperCase();
      final showKey = !(key == "COLOR" || key == "DISPLAY SIZE");
      buffer.write("$value${showKey ? " $key" : ""}");
      if (i != configList.length - 1) {
        buffer.write(", ");
      }
    }
    buffer.write(" )");
    return buffer.toString();
  }

  void _incrementItem(CartItem item, CartProvider cartProvider, BuildContext context) {
    if( item.stock <= item.quantity ){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Out of Stock.")),
      );
      return;
    };
      
    cartProvider.addToCart(
      CartItem(
        productId: item.productId,
        photo: item.photo,
        name: item.name,
        price: item.price,
        quantity: item.quantity + 1,
        stock: item.stock,
        variant: item.variant,
      ),
      updateIfExists: true,
    );
  }

  void _decrementItem(CartItem item, CartProvider cartProvider, BuildContext context) {
    if( item.quantity <= 1 ){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum quantity is 1.")),
      );
      return;
    };
      
    cartProvider.addToCart(
      CartItem(
        productId: item.productId,
        photo: item.photo,
        name: item.name,
        price: item.price,
        quantity: item.quantity - 1,
        stock: item.stock,
        variant: item.variant,
      ),
      updateIfExists: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final product = item;
    final variant = item.variant;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: ProductDetailsParams(product.productId, variant?.id ?? ""));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.photo,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: ProductDetailsParams(product.productId, variant?.id ?? ""));
                  },
                  child:Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          cartProvider.removeFromCart(item.productId, item.variant?.id);
                        },
                      ),
                    ],
                  )
                ),
                if (variant != null && variant.configuration.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: ProductDetailsParams(product.productId, variant?.id ?? ""));
                  },
                  child:Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(getSelectedConfigName(item.variant!),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  )
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "\$${variant?.price ?? product.price}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            _decrementItem(item, cartProvider, context);
                          },
                        ),
                        Text(
                          "${item.quantity}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            _incrementItem(item, cartProvider, context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}