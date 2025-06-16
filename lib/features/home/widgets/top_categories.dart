import 'package:shopsphere/common/widgets/loader.dart';
import 'package:shopsphere/common/widgets/shimmer_loader.dart';
import 'package:shopsphere/constants/global_variables.dart';
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
    return categories.isEmpty ? ShimmerLoader( itemCount: 12 ) : SizedBox(
      height: 30,
      child: ListView.builder(
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        // itemExtent: 75,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => navigateToCategoryPage(
              context,
              categories[index],
            ),
            child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing : 2.0,
              children: [
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(50),
                //     child: Image.asset(
                //       GlobalVariables.categoryImages[index]['image']!,
                //       fit: BoxFit.cover,
                //       height: 40,
                //       width: 40,
                //     ),
                //   ),
                // ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  // width: 65.0,
                  child: Text(
                    categories[index].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

