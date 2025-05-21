import 'package:flutter/material.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/features/auth/screens/auth_screen.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  static const String routeName = '/home';
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Scaffold(
        appBar: AppBar(
          title: const Text("ShopSphere", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold) ),
          centerTitle: true,
          backgroundColor: GlobalVariables.secondaryColor,
        ),
        body: Column(
          children: [
            const Center(
              child: Text("flutter Home page"),
            ),
            Builder(
              builder: (context) {
                return Column(
                  children: [
                    Text('${user?.name}'),
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pushNamed(AuthScreen.routeName);
                    }, child: Text("click"),),
                  ],
                );
              }
            )
          ],
        ),
      );
  }
}
