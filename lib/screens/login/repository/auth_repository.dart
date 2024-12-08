import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_management_app/landing_screen.dart';
import 'package:waste_management_app/sharedWidgets/bottom_navbar.dart';
import 'package:waste_management_app/utils/firebase_functions.dart';

class AuthRepository extends GetxController {
  static AuthRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialRoute);
    super.onReady();
  }

  _setInitialRoute(User? user) {
    if (user == null) {
      Get.offAll(const LandingScreen());
    } else {
      Future.delayed(
        const Duration(
          seconds: 2,
        ),
      );
      Get.offAll(const BottomNavBar(
        initailIndex: 0,
      ));
    }
  }

  //* ------- WITH EMAIL AND PASSWORD: --------------------
  void signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e == 'user-not-found') {
        Get.snackbar(
          'Error',
          'No user found for that email.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else if (e == 'wrong-password') {
        Get.snackbar(
          'Error',
          'Incorrect password.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  void signUpWithEmailAndPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        value.user!.updateDisplayName(name);
        await FirebaseFunctions.instance.createUserDocumentWithEmailAndPassword(
          name: name,
          email: email,
          password: password,
          uid: value.user!.uid,
        );
      });
    } catch (e) {
      if (e == 'weak-password') {
        Get.snackbar(
          'Error',
          'The password provided is too weak.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else if (e == 'email-already-in-use') {
        Get.snackbar(
          'Error',
          'The account already exists for that email.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  //* ------ LOGOUT: --------------------
  void signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
