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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo and Welcome Text
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo-transparent.png',
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Welcome to ShopSphere",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: GlobalVariables.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Let's get started with your shopping journey",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form Container with shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
              key: _signInFormKey,
              child: Column(
                children: [
                  // Gender Selection
                  // Gender Selection with modern style
                  CustomSelectField(
                    controller: _genderController,
                    options: ["Male", "Female"],
                    hintText: "Select Your Gender",
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth Selection with modern style
                  CustomTextField(
                    controller: _dobController,
                    hintText: "Date of Birth",
                    onTapFunc: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: GlobalVariables.secondaryColor,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        _dobController.text = pickedDate.toIso8601String().split("T")[0];
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Modern Google Sign-in Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Image.asset(
                          "assets/images/google_logo.png",
                          height: 24,
                        ),
                      ),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      onPressed: () {
                        if (_signInFormKey.currentState!.validate()) {
                          signInUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms and Privacy text
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  ),
),
    );
  }
}