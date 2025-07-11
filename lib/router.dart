import 'package:flutter/material.dart';
import 'features/auth/screens/auth_screen.dart';
import 'package:shopsphere/features/home/screens/home_screen.dart';
import 'package:shopsphere/features/search/screens/search_screen.dart';
import 'package:shopsphere/features/cart/screens/cart_screen.dart';
import 'package:shopsphere/features/product_details/screens/product_details_screen.dart';
import 'package:shopsphere/common/widgets/bottom_bar.dart';
import 'package:shopsphere/models/search_query.dart';
import 'package:shopsphere/models/product.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );

    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(),
      );
    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomBar(),
      );
    case CartScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CartScreen(),
      );

    // case CategoryDealsScreen.routeName:
    //   var category = routeSettings.arguments as String;
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => CategoryDealsScreen(
    //       category: category,
    //     ),
    //   );
    case SearchScreen.routeName:
      var searchQuery = routeSettings.arguments as SearchQuery;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SearchScreen(
          initialSearch: searchQuery.serach,
          initialCategory: searchQuery.category
        ),
      );
    case ProductDetailsScreen.routeName:
      var productDetailsParams = routeSettings.arguments as ProductDetailsParams;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ProductDetailsScreen(
          productId: productDetailsParams.productId,
          variantId: productDetailsParams.variantId,
        ),
      );
    // case AddressScreen.routeName:
    //   var totalAmount = routeSettings.arguments as String;
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => AddressScreen(
    //       totalAmount: totalAmount,
    //     ),
    //   );
    // case OrderDetailScreen.routeName:
    //   var order = routeSettings.arguments as Order;
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => OrderDetailScreen(
    //       order: order,
    //     ),
    //   );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Screen does not exist!'),
          ),
        ),
      );
  }
}