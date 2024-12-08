import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_management_app/screens/login/repository/auth_repository.dart';

class SignUpController extends GetxController {
  final signUpFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp()  {
    if (signUpFormKey.currentState!.validate()) {
      AuthRepository.instance.signUpWithEmailAndPassword(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text);
    }
  }
}
