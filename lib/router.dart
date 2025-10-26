import 'package:flutter/material.dart';
import 'package:shopsphere/models/new_order_request.dart';
import 'features/auth/screens/auth_screen.dart';
import 'package:shopsphere/features/home/screens/home_screen.dart';
import 'package:shopsphere/features/search/screens/search_screen.dart';
import 'package:shopsphere/features/checkout/screens/checkout_screen.dart';
import 'package:shopsphere/features/cart/screens/cart_screen.dart';
import 'package:shopsphere/features/product_details/screens/product_details_screen.dart';
import 'package:shopsphere/features/shipping/screens/shipping_address.dart';
import 'package:shopsphere/features/order_details/screens/order_detail_screen.dart';
import 'package:shopsphere/common/widgets/bottom_bar.dart';
import 'package:shopsphere/models/search_query.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/features/orders/screens/orders_screen.dart';

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
      int page = routeSettings.arguments as int? ?? 0;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => BottomBar( selectedPage: page ),
      );
    case CartScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CartScreen(),
      );

    case CheckoutScreen.routeName:
      var clientSecret = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => CheckoutScreen(
          clientSecret: clientSecret,
        ),
      );
    
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
    case ShippingPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ShippingPage(
        ),
      );
    case TrackingOrderScreen.routeName:
      var orderId = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => TrackingOrderScreen(
          orderId: orderId,
        ),
      );
    case OrdersScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const OrdersScreen(),
      );
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