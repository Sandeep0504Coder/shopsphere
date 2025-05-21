import 'package:shopsphere/constants/utils.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AccountServices {

  void logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
