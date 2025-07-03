import 'package:flutter/material.dart';
import 'package:shopsphere/common/widgets/custom_selectfield.dart';
import 'package:shopsphere/common/widgets/custom_textfield.dart';
import 'package:shopsphere/constants/global_variables.dart';
import 'package:shopsphere/features/auth/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _dobController =  TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _dobController.dispose();
    _genderController.dispose();
  }

  void signInUser() async{
    await authService.signInUser(
      context: context,
      gender: _genderController.text,
      dob: _dobController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ShopSphere",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
      backgroundColor: GlobalVariables.greyBackgroundColor,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            Form(
              key: _signInFormKey,
              child: Column(
                children: [
                  // Gender Selection
                  CustomSelectField(controller: _genderController, options: ["Male", "Female"], hintText: "Select Your Gender"),
                  SizedBox(height: 10),

                  // Date of Birth Selection
                  CustomTextField(
                    controller:_dobController,
                    hintText:  "Date of Birth",
                    onTapFunc: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _dobController.text = pickedDate.toIso8601String().split("T")[0];
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Already Signed In Once?"),
                  SizedBox(height: 20),
                  // Google Sign-in Button
                  ElevatedButton.icon(
                    icon: Image.asset("assets/images/google_logo.png", height: 24), // Add Google logo in assets
                    label: Text("Sign in with Google"),
                    onPressed: (){
                      if (_signInFormKey.currentState!.validate()) {
                        signInUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),                  
                ],
              ),
            ),
          ],
        ),
      ))
    );
  }
}