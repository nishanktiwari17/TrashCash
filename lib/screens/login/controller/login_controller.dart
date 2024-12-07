import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_management_app/screens/login/repository/auth_repository.dart';

class LoginController extends GetxController {
  //* Email
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();

  //* FUNCTIONS:

  //* ------- WITH EMAIL ID: --------------------
  void loginWithEmailAndPassword() {
    if (emailFormKey.currentState!.validate()) {
      AuthRepository.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
    }
  }
}
