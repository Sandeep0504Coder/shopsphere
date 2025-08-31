import 'package:flutter/material.dart';
import 'package:shopsphere/common/widgets/stars.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/features/product_details/services/product_services.dart';
import 'package:shopsphere/common/services/address_services.dart';
import 'package:shopsphere/models/address.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/models/product_variant.dart';
import 'package:shopsphere/models/review.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final String productId;
  final String? variantId;
  const ProductDetailsScreen({Key? key, required this.productId, this.variantId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  double reviewRating = 0;
  final TextEditingController reviewController = TextEditingController();
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
    final selectedShippingAddressId = Provider.of<CartProvider>(context, listen: false).selectedShippingAddressId;
    product = await productServices.fetchProductDetails(id: widget.productId, context: context);
    reviews = await productServices.fetchReviews(productId: widget.productId, context: context);

    if(user != null){
      addresses = await addressServices.fetchAddresses(userId: user.id, context: context);
    }
    if( addresses.isNotEmpty ){
      if( selectedShippingAddressId.isNotEmpty ){
        selectedAddress = addresses.firstWhere((a) => a.id == selectedShippingAddressId, orElse: () => addresses.first);
      } else {
        selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
      }
    } else {
      selectedAddress = null;
    }

    if (widget.variantId != null) {
      ProductVariant? selectedVariant = product!.variants.isEmpty
        ? null
        :product?.variants.firstWhere(
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
    if(product!.variants.isEmpty){
      return null;
    }
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

  void _addToCart( CartItem cartItem, BuildContext context, CartProvider cartProvider) {
    if( cartItem.stock < 1 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Out of Stock.")),
      );
      return;
    }

    if( cartItem.stock < cartItem.quantity ){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only ${cartItem.stock} items available.")),
      );
      return;
    }
    
    cartProvider.addToCart(cartItem, updateIfExists: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(
        children: [
          Expanded(child: Text('${cartItem.name} added to cart')),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/actual-home', arguments: 2);
            },
            child: Text("Go to Cart", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.cyan)),
          )
        ],
      )),
    );
  }

  void _submitReview() async {
    Navigator.of(context).pop(); // Close modal

    if (reviewRating == 0 || reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and comment.")),
      );
      return;
    }

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      await productServices.addEditReview(
        context: context,
        productId: product!.id,
        userId: user!.id,
        comment: reviewController.text.trim(),
        rating: reviewRating.toInt(),
      );

      setState(() {
        reviewRating = 0;
        reviewController.clear();
      });

      _fetchProductDetails(); // refresh reviews
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting review.")),
      );
    }
  }

  void _deleteReview(String reviewId) async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      await productServices.deleteReview(
        context: context,
        reviewId: reviewId,
        userId: user!.id,
      );

      setState(() {
      });

      _fetchProductDetails(); // refresh reviews
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting review.")),
      );
    }
  }

  _handleSelectedAddressChange(Address? address, BuildContext context) {
    if (address == null) return;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateShippingAddressId(address.id);
    setState(() {
      selectedAddress = address;
    });
    Navigator.pop(context);
  }


  void navigateToProductDetailsScreen(String productId) {
    Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: ProductDetailsParams(productId,""));
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
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close icon
              Padding(
                padding: const EdgeInsets.only(
                  top: 12.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Variant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: GlobalVariables.greyBackgroundColor,
              ),

              // Variant options
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.only(
                    top: 0.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 12.0,
                  ),
                  children: product!.variants
                      .expand((variant) => variant.configuration)
                      .map((config) => config.key)
                      .toSet()
                      .map((key) {
                    final options = product!.variants
                        .expand((variant) => variant.configuration)
                        .where((c) => c.key == key)
                        .map((c) => c.value)
                        .toSet();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          "${key.toUpperCase()}: ${selectedConfig[key] ?? ''}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
        );
      },
    );
  }

  void _showReviewModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Write a Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: reviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                RatingBar.builder(
                  initialRating: reviewRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      reviewRating = rating;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text("Submit"),
            ),
            const SizedBox(height: 60),
          ],
        ),
      );
    },
  );
}


  void _openAddressSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(
                  top: 12.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: GlobalVariables.greyBackgroundColor,
              ),
            Flexible(
              child: ListView(
                children: addresses.map((a) => ListTile(
                  selected:  selectedAddress == a ? true : false,
                  selectedColor: GlobalVariables.appBarGradient.colors.first,
                  title: Text('${a.name}, ${a.pinCode}', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${a.address}, ${a.city}, ${a.state}, ${a.pinCode}"),
                  onTap: () {
                    _handleSelectedAddressChange(a, context);
                  },
                )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestedProducts() {
    if (product?.suggestedItems == null || product!.suggestedItems!.isEmpty) return const SizedBox();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: GlobalVariables.greyBackgroundColor, // Light grey border
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Suggested Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product!.suggestedItems!.length,
              itemBuilder: (context, index) {
                final item = product!.suggestedItems?[index].product;
                return GestureDetector(
                  onTap: () {
                    navigateToProductDetailsScreen(item.id);
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(item!.photos.first.url, height: 100, fit: BoxFit.cover),
                        const SizedBox(height: 4),
                        Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text("\$${item.price}", style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVariantSummary() {
    if(product!.variants.isEmpty){
      return SizedBox();
    }

    final configKeys = product!.variants
      .expand((v) => v.configuration)
      .map((c) => c.key)
      .toSet()
      .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: GlobalVariables.greyBackgroundColor, // Light grey border
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,8,16,8),
            child: const Text("Select Variant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Divider(color: GlobalVariables.greyBackgroundColor,),
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
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$otherOptionsCount more", style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 119, 119, 119))),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                ],
              ),
              onTap: () => _openVariantSelector(),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final cartProvider = Provider.of<CartProvider>(context);
    if (isLoading || product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedVariant = _getFilteredVariant();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: GlobalVariables.selectedNavBarColor,
        title: Text(product!.name)
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.all(0),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    _addToCart(
                      CartItem(
                        productId: product!.id,
                        photo: product!.photos.first.url,
                        name: product!.name,
                        price: selectedVariant?.price ?? product!.price,
                        quantity: quantity,
                        stock: selectedVariant?.stock ?? product!.stock,
                        variant: selectedVariant, // Handle variants if needed
                      ),
                      context,
                      cartProvider
                    );
                  },
                  child: Container(
                    color: Colors.amber,
                    child: Center( heightFactor: 2, child: Text(
                      isInCart ? "Update Cart" : "Add to Cart",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ))
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                height: 250,
                autoPlay: true,
                clipBehavior: Clip.none
              ),
              items: product!.photos.map((photo) {
                return ClipRRect(
                  child: Image.network(photo.url, fit: BoxFit.cover, width: double.infinity),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            
            _buildVariantSummary(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,16,16,8),
              child: Text(product!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (selectedVariant != null) Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,8),
              child: Text(getSelectedConfigName(selectedVariant)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,8),
              child: Row(
                spacing : 4,
                children: [
                  Stars(rating: product!.ratings ?? 0),
                  Text('${product!.ratings ?? 0}',style:TextStyle(color: Colors.green)),
                  Container(
                    margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      color: GlobalVariables.secondaryTextColor,
                      borderRadius: BorderRadius.all(Radius.circular(4))
                    )
                  ),
                  Text(
                    '${product!.numOfReviews ?? 0} ratings',
                    style: TextStyle(
                      color: GlobalVariables.secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    )
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,16),
              child: Text("\$${selectedVariant?.price ?? product!.price}", style: const TextStyle(fontSize: 18, color: Colors.green)),
            ),
            if(selectedAddress != null)
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: GlobalVariables.greyBackgroundColor, // Light grey border
                    width: 3,
                  ),
                  bottom: BorderSide(
                    color: GlobalVariables.greyBackgroundColor, // Light grey border
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          // if (selectedAddress != null) ...[
                            Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Deliver to: ',
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: '${selectedAddress!.name}, ${selectedAddress!.pinCode}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text("${selectedAddress!.address}, ${selectedAddress!.city}, ${selectedAddress!.state}"),
                        // ],
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: GlobalVariables.greyBackgroundColor, width: 1), // Border color and width
                    ),
                    onPressed: _openAddressSelector,
                    child: Text(
                      "Change",
                      style: TextStyle(
                        color: GlobalVariables.secondaryTextColor,
                        fontWeight: FontWeight.w600
                      )
                    )
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(product!.description ?? ""),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              width: double.maxFinite,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: GlobalVariables.greyBackgroundColor, // Light grey border
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text("Reviews", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: GlobalVariables.greyBackgroundColor, width: 1), // Border color and width
                    ),
                    onPressed: _showReviewModal,
                    child: const Text("Rate Product",
                      style: TextStyle(
                          color: GlobalVariables.secondaryTextColor,
                          fontWeight: FontWeight.w600
                      )
                    ),
                  )
                ],
              )
            ),
            if(reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text("No reviews yet"),
            ),
            ...reviews.map((r) => ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(r.user.photo)),
              title: Text(r.user.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stars(rating: r.rating.toDouble()),
                  Text(r.comment),
                ],
              ),
              trailing: user!.id == r.user.id ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteReview(r.id);
                }
              ) : null,
            )),
            SizedBox(
              height: 16,
            ),
            _buildSuggestedProducts(),
          ],
        ),
      ),
    );
  }
}
