import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/features/auth/screens/auth_screen.dart';
import 'package:shopsphere/router.dart';
import './screens/home.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/providers/auth_state_handler.dart';
import 'package:shopsphere/common/widgets/bottom_bar.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // runApp(const MyApp());
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}