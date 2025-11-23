import 'package:flutter/material.dart';
import 'package:shopsphere/common/widgets/loader.dart';
import 'package:shopsphere/features/home/services/home_services.dart';
import 'package:shopsphere/features/home/widgets/promotional_video_player.dart';
import 'package:shopsphere/features/product_details/screens/product_details_screen.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/models/home_page_content.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/models/search_query.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  HomePageContent? homePageContent;
  final HomeServices homeServices = HomeServices();

  @override
  void initState() {
    super.initState();
    fetchHeroSection();
  }

  void fetchHeroSection() async {
    homePageContent = await homeServices.getHeroSectionData(context: context);
    setState(() {});
  }
  
  void navigateToProductDetailsScreen(String productId) {
    Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: ProductDetailsParams(productId,""));
  }

  void _addToCart(CartItem cartItem, BuildContext context, CartProvider cartProvider) {
    if( cartItem.stock < 1 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Out of Stock.")),
      );
      return;
    }
    
      cartProvider.addToCart(cartItem, updateIfExists: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cartItem.name} added to cart')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return homePageContent == null ? const Loader() : Column(
      children: [
        // Banners Slider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              child: CarouselSlider(
                items: homePageContent!.banners.map((b) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      b.url,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  viewportFraction: 1,
                  height: 180,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                ),
              ),
            ),
          ),
        ),

        // Product Sections
        ...homePageContent!.productSections.map((section) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.sectionLabel,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 114, 226, 221),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/search-screen',
                          arguments: SearchQuery(
                            "",
                            section.filters.firstWhere(
                              (filter) => filter['key'] == 'category',
                              orElse: () => {
                                'value': ''
                              }
                            )['value']
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text("View All"),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 114, 226, 221),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: section.products!.length,
                    itemBuilder: (context, index) {
                      final product = section.products![index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            navigateToProductDetailsScreen(product.id);
                          },
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Image Container
                                Container(
                                  height: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[100]!,
                                        Colors.grey[50]!,
                                      ],
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      product.photos[0].url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Product Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                                const SizedBox(width: 2),
                                                Text(
                                                  "${product.ratings ?? 0}",
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "\$${product.variants.isNotEmpty ? product.variants[0].price : product.price}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromARGB(255, 114, 226, 221),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 32,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(255, 114, 226, 221),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                onPressed: () {
                                                  _addToCart(
                                                    CartItem(
                                                      productId: product.id,
                                                      photo: product.photos[0].url,
                                                      name: product.name,
                                                      price: product.variants.isNotEmpty
                                                          ? product.variants[0].price
                                                          : product.price,
                                                      quantity: 1,
                                                      stock: product.variants.isNotEmpty
                                                          ? product.variants[0].stock
                                                          : product.stock,
                                                      variant: product.variants.isNotEmpty
                                                          ? product.variants[0]
                                                          : null,
                                                    ),
                                                    context,
                                                    cartProvider,
                                                  );
                                                },
                                                child: const Text(
                                                  "Add to Cart",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),

        // Promotional Section
        if (homePageContent!.promotionalTextLabel.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 114, 226, 221).withOpacity(0.15),
                  const Color.fromARGB(255, 162, 236, 233).withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: const Color.fromARGB(255, 114, 226, 221).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homePageContent!.promotionalTextLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  homePageContent!.promotionalText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: PromotionalVideoPlayer(
                  videoUrl: homePageContent!.promotionalVideo.url,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}