import 'package:shopsphere/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopsphere/providers/user_provider.dart';

class AccountServices {
  
  void logOut(BuildContext context) async {
    try {
      // Sign out from Google first
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Then sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear provider state
      Provider.of<UserProvider>(context, listen: false).clearUser();
      
      showSnackBar(context, 'Logged out successfully');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
