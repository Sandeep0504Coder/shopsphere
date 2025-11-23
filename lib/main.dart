import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/router.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/providers/auth_state_handler.dart';
import 'package:shopsphere/common/widgets/bottom_bar.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  // Set publishable key from Stripe dashboard
  Stripe.publishableKey = dotenv.env['FLUTTER_PUBLIC_KEY']!;
  
  // Pre-create cart provider to load persisted data
  final cartProvider = CartProvider();
  await cartProvider.loadCartFromStorage();
  
  runApp(MyApp(cartProvider: cartProvider));
}

class MyApp extends StatelessWidget {
  final CartProvider cartProvider;
  
  const MyApp({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ],
      child: MaterialApp(
        title: 'ShopSphere',
        theme: ThemeData(
          scaffoldBackgroundColor: GlobalVariables.backgroundColor,
          colorScheme: ColorScheme.light(primary: GlobalVariables.secondaryColor),
          appBarTheme: AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            )
          ),
          useMaterial3: true,
          fontFamily: 'Lato', 
        ),
        onGenerateRoute: (setting) => generateRoute(setting),
        home: AuthStateHandler(
          child: BottomBar(), // <-- your actual app screen logic goes here
        ),
        routes: <String,WidgetBuilder>{},
        debugShowCheckedModeBanner: false
      ),
    );
  }
}