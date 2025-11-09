// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:shopsphere/common/widgets/bottom_bar.dart';
import 'package:shopsphere/constants/error_handling.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/constants/utils.dart';
// import 'package:shopsphere/models/user.dart';
import 'package:shopsphere/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // sign in user
  Future signInUser({
    required BuildContext context,
    required String gender,
    required String dob,
  }) async {
    // try {
    //   http.Response res = await http.post(
    //     Uri.parse('$uri/api/signin'),
    //     body: jsonEncode({
    //       'email': email,
    //       'password': password,
    //     }),
    //     headers: <String, String>{
    //       'Content-Type': 'application/json; charset=UTF-8',
    //     },
    //   );
      //   httpErrorHandle(
      //   response: res,
      //   context: context,
      //   onSuccess: () async {
      //     SharedPreferences prefs = await SharedPreferences.getInstance();
      //     Provider.of<UserProvider>(context, listen: false).setUser(res.body);
      //     await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
      //     Navigator.pushNamedAndRemoveUntil(
      //       context,
      //       BottomBar.routeName,
      //       (route) => false,
      //     );
      //   },
      // );
    // } catch (e) {
    //   showSnackBar(context, e.toString());
    // }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn .signIn();

      if (googleUser == null) {
        showSnackBar(context, "Sign-in cancelled");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // API call to backend
        final response = await http.post(
          Uri.parse("$uri/api/v1/user/new"), // Replace with your API endpoint
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": user.displayName,
            "email": user.email,
            "photo": user.photoURL,
            "gender": gender,
            "role": "user",
            "dob": dob,
            "_id": user.uid,
          }),
        );

        httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () async {
          final userDetails = await getUserData(user.uid);
          Provider.of<UserProvider>(context, listen: false).setUser(jsonEncode(jsonDecode(userDetails.body)['user']));
          showSnackBar(context, "Sign-in successful.");
          Navigator.pushNamedAndRemoveUntil(
            context,
            BottomBar.routeName,
            (route) => false,
          );
        },
      );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
  static Future getUserData(
    String id,
  ) async {
    try {
        return await http.get(
          Uri.parse("$uri/api/v1/user/$id"),
          headers: {'Content-Type': 'application/json'},
        );
    } catch (e) {
      throw e;
    }
  }
}