import 'package:flutter/material.dart';
import 'package:shopsphere/features/product_details/services/product_services.dart';
import 'package:shopsphere/common/services/address_services.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/models/product_variant.dart';
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
    selectedAddress = addresses.isEmpty
        ? null
        : addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
    if (widget.variantId != null) {
      final selectedVariant = product?.variants.firstWhere(
        (v) => v.id == widget.variantId,
        orElse: () => product!.variants.first,
      );
      if (selectedVariant != null) {
        selectedConfig = {for (var c in selectedVariant.configuration) c.key: c.value};
      }
    }

    isLoading = false;
    setState(() {});
  }

  void _updateConfiguration(String key, String value) {
    setState(() {
      selectedConfig[key] = value;
    });
  }

  ProductVariant? _getFilteredVariant() {
    final variants = product?.variants ?? [];
    return variants.firstWhere(
      (variant) => variant.configuration.every(
        (config) => selectedConfig[config.key] == config.value,
      ),
      orElse: () => _getClosestVariant(variants)!,
    );
  }

  ProductVariant? _getClosestVariant(List<ProductVariant> variants) {
    final configKeys = selectedConfig.keys.toList();
    ProductVariant? bestVariant;
    int bestScore = -1;

    for (final variant in variants) {
      int score = 0;
      for (final config in variant.configuration) {
        final priority = configKeys.indexOf(config.key);
        if (priority != -1 && selectedConfig[config.key] == config.value) {
          score += configKeys.length - priority;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestVariant = variant;
      }
    }

    if (bestVariant != null) {
      setState(() {
        selectedConfig = {
          for (var c in bestVariant!.configuration) c.key: c.value,
        };
      });
    }

    return bestVariant;
  }

  void _addToCart() {
    final variant = _getFilteredVariant();
    if (variant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No matching variant found.")),
      );
      return;
    }

    print("Adding to cart: ${variant.toJson()}");
  }

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

  void _openVariantSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: product!.variants.expand((variant) => variant.configuration).map((config) => config.key).toSet().map((key) {
              final options = product!.variants
                  .expand((variant) => variant.configuration)
                  .where((c) => c.key == key)
                  .map((c) => c.value)
                  .toSet();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: options.map((option) {
                      final isSelected = selectedConfig[key] == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (_) {
                          _updateConfiguration(key, option);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  )
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _openAddressSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: addresses.map((a) => ListTile(
            title: Text(a.name),
            subtitle: Text("${a.address}, ${a.city}, ${a.state}, ${a.pinCode}"),
            onTap: () {
              setState(() => selectedAddress = a);
              Navigator.pop(context);
            },
          )).toList(),
        );
      },
    );
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

  Widget _buildVariantSummary() {
  final configKeys = product!.variants
      .expand((v) => v.configuration)
      .map((c) => c.key)
      .toSet()
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Select Variant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ...configKeys.map((key) {
        final options = product!.variants
            .expand((v) => v.configuration)
            .where((c) => c.key == key)
            .map((c) => c.value)
            .toSet()
            .toList();

        final selectedValue = selectedConfig[key] ?? options.first;
        final otherOptionsCount = options.length - 1;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: RichText(
            text: TextSpan(
              text: "$key: ",
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: selectedValue,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$otherOptionsCount more", style: const TextStyle(color: Colors.grey)),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          onTap: () => _openVariantSelector(),
        );
      }),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    if (isLoading || product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedVariant = _getFilteredVariant();

    return Scaffold(
      appBar: AppBar(title: Text(product!.name)),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _addToCart,
                child: Text(isInCart ? "Update Cart" : "Add to Cart"),
              )
            ],
          ),
        ),
      ),
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
            
            _buildVariantSummary(),
            const SizedBox(height: 8),
            Text(product!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (selectedVariant != null) Text(getSelectedConfigName(selectedVariant)),
            const SizedBox(height: 4),
            Text("₹${selectedVariant?.price ?? product!.price}", style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _openAddressSelector,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Deliver to:", style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (selectedAddress != null) ...[
                    Text("${selectedAddress!.name}, ${selectedAddress!.pinCode}"),
                    Text("${selectedAddress!.address}, ${selectedAddress!.city}, ${selectedAddress!.state}"),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text("Description", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(product!.description ?? ""),
            const Divider(height: 32),
            Text("Reviews", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
}
