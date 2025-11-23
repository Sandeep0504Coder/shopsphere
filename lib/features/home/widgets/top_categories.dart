import 'package:shopsphere/common/widgets/shimmer_loader.dart';
import 'package:shopsphere/features/search/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/features/home/services/home_services.dart';
import 'package:shopsphere/models/search_query.dart';

class TopCategories extends StatefulWidget {
  const TopCategories({Key? key}) : super(key: key);

  @override
  State<TopCategories> createState() => _TopCategoriesState();
}

class _TopCategoriesState extends State<TopCategories> {
  void navigateToCategoryPage(BuildContext context, String category) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchQuery("", category));
  }

   List<String> categories = [];
  final HomeServices homeServices = HomeServices();

  @override
  void initState() {
    fetchProductCategories();
    // TODO: implement initState
    super.initState();
  }

  fetchProductCategories() async {
    categories = await homeServices.getProductCategories(context: context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return categories.isEmpty ? ShimmerLoader(itemCount: 12) : Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => navigateToCategoryPage(context, categories[index]),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color.fromARGB(255, 114, 226, 221).withOpacity(0.3),
                            const Color.fromARGB(255, 162, 236, 233).withOpacity(0.3),
                          ],
                        ),
                        border: Border.all(
                          color: const Color.fromARGB(255, 114, 226, 221).withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => navigateToCategoryPage(context, categories[index]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  _getCategoryIcon(categories[index]),
                                  height: 28,
                                  // color: const Color.fromARGB(255, 114, 226, 221),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  categories[index].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mobiles':
        return 'assets/images/mobiles.jpeg';
      case 'camera':
        return 'assets/images/camera.png';
      case 'appliances':
      case 'home':
        return 'assets/icons/appliances.png';
      case 'sports':
        return 'assets/icons/sports.png';
      case 'fashion':
        return 'assets/images/fashion.jpeg';
      case 'air conditioner':
        return 'assets/images/air_conditioner.png';
      case 'earphones':
        return 'assets/images/earphone.png';
      case 'furniture accessories':
        return 'assets/images/home-appliance.png';
      case 'laptops':
        return 'assets/images/laptop.png';
      case 'mobile accessories':
        return 'assets/images/phone-case.png';
      case 'refrigerator':
        return 'assets/images/refrigarator.png';
      case 'speakers':
        return 'assets/images/audio-system.png';
      case 'television':
        return 'assets/images/television.png';
      case 'washing machine':
        return 'assets/images/washing-machine.png';
      default:
        return 'assets/images/appliances.jpeg';
    }
  }
}

