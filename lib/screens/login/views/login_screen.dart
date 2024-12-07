import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_management_app/screens/login/views/login_with_email.dart';

import 'package:waste_management_app/screens/signup/views/signup_screen.dart';
import 'package:waste_management_app/sharedWidgets/custom_bordered_button.dart';

import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Login',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                Image.asset(
                  'assets/images/loginScreen/login_screen.png',
                  height: 300,
                  width: 300,
                ),
                const SizedBox(height: 20),
                // Login with Email button
                CustomBorderedButton(
                  title: 'Login With Email',
                  onPressed: () {
                    Get.to(() => LoginWithEmail());
                  },
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                // Sign Up Option
                GestureDetector(
                  onTap: () {
                    Get.to(() => SignUpScreen());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
