import 'package:flutter/material.dart';
import 'package:shopsphere/features/product_details/services/product_services.dart';
import 'package:shopsphere/common/services/address_services.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/models/review.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final String productId;
  final String? variantId;
  const ProductDetailsScreen({Key? key, required this.productId, this.variantId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductServices productServices = ProductServices();
  final AddressServices addressServices = AddressServices();
  int quantity = 1;
  bool isInCart = false;
  bool isLoading = true;

  Product? product;
  List<Review> reviews = [];
  List<Address> addresses = [];
  Address? selectedAddress;

  Map<String, String> selectedConfig = {};

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  void _fetchProductDetails() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    product = await productServices.fetchProductDetails(id: widget.productId, context: context);
    reviews = await productServices.fetchReviews(productId: widget.productId, context: context);
    addresses = await addressServices.fetchAddresses(userId: user!.id, context: context);
    product?.variants[0].configuration.forEach((config){
       _updateConfiguration(config.key, config.value);
    });
    selectedAddress = addresses.isEmpty
        ? null
        : addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );

    isLoading = false;
    setState(() {});
  }

  void _updateConfiguration(String key, String value) {
    setState(() {
      selectedConfig[key] = value;
    });
  }

  void _addToCart() {
    // Add to cart logic
  }

  Widget _buildSuggestedProducts() {
    if (product?.suggestedItems == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text("Suggested Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: product!.suggestedItems!.length,
            itemBuilder: (context, index) {
              final item = product!.suggestedItems?[index].product;
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(item!.photos.first.url, height: 100, fit: BoxFit.cover),
                    const SizedBox(height: 4),
                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text("₹${item.price}", style: const TextStyle(color: Colors.green)),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(product!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(height: 250, autoPlay: true),
              items: product!.photos.map((photo) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(photo.url, fit: BoxFit.cover, width: double.infinity),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text(product!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("₹${product!.price}", style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(onPressed: quantity > 1 ? () => setState(() => quantity--) : null, icon: const Icon(Icons.remove)),
                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                IconButton(onPressed: () => setState(() => quantity++), icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 12),
            if (product!.variants.isNotEmpty) ...[
              const Text("Select Variant", style: TextStyle(fontWeight: FontWeight.bold)),
              ..._buildVariantSelectors(),
              const SizedBox(height: 12),
            ],
            if (selectedAddress != null) ...[
              const Text("Deliver to:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${selectedAddress!.name}, ${selectedAddress!.pinCode}"),
              Text("${selectedAddress!.address}, ${selectedAddress!.city}, ${selectedAddress!.state}"),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: _addToCart,
              child: Text(isInCart ? "Update Cart" : "Add to Cart"),
            ),
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product!.description ?? ""),
            const Divider(height: 32),
            const Text("Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...reviews.map((r) => ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(r.user.photo)),
              title: Text(r.user.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: List.generate(r.rating, (_) => const Icon(Icons.star, size: 16, color: Colors.amber))),
                  Text(r.comment),
                ],
              ),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {/* delete logic */}),
            )),
            _buildSuggestedProducts(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVariantSelectors() {
    final allKeys = product!.variants.expand((v) => v.configuration).map((c) => c.key).toSet();
    return allKeys.map((key) {
      final values = product!.variants.expand((v) => v.configuration).where((c) => c.key == key).map((c) => c.value).toSet().toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: values.map((value) {
              final isSelected = selectedConfig[key] == value;
              return ChoiceChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (_) => _updateConfiguration(key, value),
              );
            }).toList(),
          ),
        ],
      );
    }).toList();
  }
}
