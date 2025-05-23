import 'package:shopsphere/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? _user = User(
    id: '',
    name: '',
    email: '',
    photo: '',
    gender: '',
    role: '',
    dob: '',
  );

  User? get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}