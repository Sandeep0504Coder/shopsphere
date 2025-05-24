import 'package:shopsphere/features/account/services/account_services.dart';
import 'package:shopsphere/features/account/widgets/account_button.dart';
import 'package:shopsphere/features/auth/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:provider/provider.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return   user != null ? Column(
      children: [
        Row(
          children: [
            AccountButton(
              text: 'Your Orders',
              onTap: () {},
            ),
            AccountButton(
              text: 'Turn Seller',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            AccountButton(
              text: 'Log Out',
              onTap: () => AccountServices().logOut(context),
            ),
            AccountButton(
              text: 'Your Wish List',
              onTap: () {},
            ),
          ],
        ),
      ],
    ) : Column(
      children: [
        Row(
          children: [
            AccountButton(
              text: 'Log In',
              onTap: () => Navigator.of(context).pushNamed(AuthScreen.routeName),
            ),
          ],
        ),
      ]
    );
  }
}
