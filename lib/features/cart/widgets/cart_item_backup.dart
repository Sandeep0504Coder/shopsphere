import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/models/product_variant.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Image.network(item.photo, width: 50, height: 50),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${item.price}'),
            Text('Stock: ${item.stock}'),
            if (item.variant != null) Text('Variant: ${getSelectedConfigName(item.variant!)}'),
          ],
        ),
        trailing: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _incrementItem(item, cartProvider, context),
            ),
            Text(item.quantity.toString()),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _decrementItem(item, cartProvider, context),
            ),
          ],
        ),
      ),
    );
  }
}
