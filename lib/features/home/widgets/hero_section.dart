import 'package:flutter/material.dart';
import 'package:shopsphere/common/widgets/loader.dart';
import 'package:shopsphere/features/home/services/home_services.dart';
import 'package:shopsphere/features/home/widgets/promotional_video_player.dart';
import 'package:shopsphere/features/product_details/screens/product_details_screen.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/models/home_page_content.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shopsphere/models/product.dart';
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
    return homePageContent == null ? Loader() : Column(
      children: [
        // Banners Slider - You can use a PageView or CarouselSlider package
        SizedBox(
          height: 200,
          child: CarouselSlider(
            items: homePageContent!.banners.map((b) {
              return Image.network(b.url, fit: BoxFit.cover);
            }).toList(),
            options: CarouselOptions(
              viewportFraction: 1,
              height: 200,
              autoPlay: true
            ),
          ),
        ),

        // Product Sections
        ...homePageContent!.productSections.map((section) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(section.sectionLabel),
                trailing: const Text("More"),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: section.products!.length,
                  itemBuilder: (context, index) {
                    final product = section.products![index];
                    return SizedBox(
                      width: 160,
                      child: GestureDetector(
                        onTap: () {
                          navigateToProductDetailsScreen(product.id);
                        },
                        child:Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(product.photos[0].url, height: 100, width: 100, fit: BoxFit.cover),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:Text("\$${product.variants.isNotEmpty ? product.variants[0].price : product.price}"),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {_addToCart(
                                    CartItem(
                                      productId: product.id,
                                      photo: product.photos[0].url,
                                      name: product.name,
                                      price: product.variants.isNotEmpty ? product.variants[0].price : product.price,
                                      quantity: 1,
                                      stock: product.variants.isNotEmpty ? product.variants[0].stock : product.stock,
                                      variant: product.variants.isNotEmpty ? product.variants[0] : null, // Handle variants if needed
                                    ),
                                    context,
                                    cartProvider
                                  );},
                                  child: const Text("Add to Cart"),
                                )
                              )
                            ],
                          ),
                        )
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),

        // Promotional Video + Text (You can use video_player package)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            homePageContent!.promotionalTextLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(homePageContent!.promotionalText),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: PromotionalVideoPlayer(videoUrl: homePageContent!.promotionalVideo.url)), // Replace with video player
          ),
        ),

        // Clients & Services: You can create separate widgets
        const Divider(),
        const Center(child: Text("Our Clients")),
        const SizedBox(height: 10),
        const Center(child: Text("Our Services")),
      ],
    );
  }
}