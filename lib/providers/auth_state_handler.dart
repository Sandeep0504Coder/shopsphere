import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:shopsphere/features/auth/services/auth_service.dart';

class AuthStateHandler extends StatefulWidget {
  final Widget child;

  const AuthStateHandler({super.key, required this.child});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen(_handleAuthChange, onError: (error) {
      debugPrint('Auth state error: $error');
      Provider.of<UserProvider>(context, listen: false).clearUser();
    });
  }

  Future<void> _handleAuthChange(User? firebaseUser) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (firebaseUser != null) {
        final res = await AuthService.getUserData(firebaseUser.uid);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          userProvider.setUser(jsonEncode(data['user']));
        } else {
          userProvider.clearUser();
          _auth.signOut(); // Sign out if backend validation fails
        }
      } else {
        userProvider.clearUser();
      }
    } catch (e) {
      debugPrint('Error handling auth state: $e');
      Provider.of<UserProvider>(context, listen: false).clearUser();
    } finally {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return widget.child;
    }
    // Return an empty container or transparent screen while initializing
    // The splash screen from flutter_native_splash will remain visible
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage('assets/images/logo-transparent.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: const Center(
        child: SizedBox.shrink(),
      ),
    );
  }
}
