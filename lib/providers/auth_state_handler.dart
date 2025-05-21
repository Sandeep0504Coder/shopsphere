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

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen(_handleAuthChange);
  }

  Future<void> _handleAuthChange(User? firebaseUser) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (firebaseUser != null) {
      try {
        final res = await AuthService.getUserData(firebaseUser.uid);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          userProvider.setUser(jsonEncode(data['user']));
        } else {
          userProvider.clearUser();
        }
      } catch (e) {
        userProvider.clearUser();
      }
    } else {
      userProvider.clearUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
