import 'package:flutter/material.dart';
import 'package:shopsphere/common/widgets/loader.dart';
import 'package:shopsphere/features/home/services/home_services.dart';
import 'package:shopsphere/features/home/widgets/promotional_video_player.dart';
import 'package:shopsphere/models/home_page_content.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  @override
  Widget build(BuildContext context) {
    return homePageContent == null ? Loader() : Column(
      children: [
        // Banners Slider - You can use a PageView or CarouselSlider package
        Container(
          height: 200,
          child: CarouselSlider(
            items: homePageContent!.banners.map((b) {
              return Image.network(b.url, fit: BoxFit.cover);
            }).toList(),
            options: CarouselOptions(
              viewportFraction: 1,
              height: 200,
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
                    return Card(
                      child: Column(
                        children: [
                          Image.network(product.photos[0].url, height: 100, width: 100, fit: BoxFit.cover),
                          Text(product.name),
                          Text("\$${product.price}"),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("Add to Cart"),
                          )
                        ],
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