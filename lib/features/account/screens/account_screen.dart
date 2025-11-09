import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/features/account/services/account_services.dart';
import 'package:shopsphere/features/account/widgets/below_app_bar.dart';
// import 'package:shopsphere/features/account/widgets/orders.dart';
import 'package:shopsphere/features/account/widgets/top_buttons.dart';
import 'package:shopsphere/providers/user_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  Widget _buildStatItem(IconData icon, String label, String value, BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {String? subtitle, Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (color ?? Colors.blue).withOpacity(0.12),
        child: Icon(icon, color: color ?? Colors.blue),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40,
                child: Image.asset(
                  'assets/images/logo-transparent.png',
                  fit: BoxFit.contain,
                  // color: Colors.black,
                ),
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.notifications_outlined),
                  ),
                  Icon(Icons.search),
                ],
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BelowAppBar(),
            const SizedBox(height: 12),
            // Profile header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: user != null && user.photo != ""
                          ? NetworkImage(user!.photo)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( user?.name ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(user?.email ?? '', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Quick stats / actions
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Card(
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            //       child: Row(
            //         children: [
            //           _buildStatItem(Icons.receipt_long, 'Orders', '12', context),
            //           _buildStatItem(Icons.favorite_border, 'Wishlist', '8', context),
            //           _buildStatItem(Icons.local_offer_outlined, 'Coupons', '3', context),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 14),
            // Top buttons (keeps existing widget)
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16),
            //   child: TopButtons(),
            // ),
            const SizedBox(height: 18),
            // Account options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildTile(
                      Icons.shopping_bag_outlined,
                      'Your Orders',
                      subtitle: 'Track, return or buy again',
                      onTap: () => Navigator.pushNamed(context, '/orders')
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    _buildTile(
                      Icons.location_on_outlined,
                      'Your Addresses',
                      subtitle: 'Manage delivery addresses',
                      onTap: () => Navigator.pushNamed(context, '/addresses'),
                    ),
                    Divider(height: 1, color: Colors.grey[200],),
                    _buildTile(
                      Icons.payment_outlined, 'Payment Methods',
                      subtitle: 'Cards, UPI & wallets'
                    ),
                    Divider(height: 1, color: Colors.grey[200],),
                    _buildTile(Icons.settings_outlined, 'Account Settings'),
                    Divider(height: 1, color: Colors.grey[200],),
                    _buildTile(Icons.help_outline, 'Help & Support'),
                    Divider(height: 1, color: Colors.grey[200],),
                    user != null ? ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.logout, color: Colors.white),
                      ),
                      title: const Text('Sign out', style: TextStyle(color: Colors.redAccent)),
                      onTap: () => AccountServices().logOut(context),
                    ) : ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.login, color: Colors.white),
                      ),
                      title: const Text('Sign In', style: TextStyle(color: Colors.greenAccent)),
                      onTap: () => Navigator.pushNamed(context, '/auth-screen'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
