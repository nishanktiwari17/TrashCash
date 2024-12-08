import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_management_app/utils/firebase_functions.dart';

class ProfileController extends GetxController {

  final subjectTextController = TextEditingController();
  final feedbackTextController = TextEditingController();

  final feedbackFormKey = GlobalKey<FormState>();

  void submitFeedback(
      {required String uid,
      required String subject,
      required String feedback}) async {
    if (feedbackFormKey.currentState!.validate()) {
      await FirebaseFunctions.instance
          .submitFeedback(uid: uid, subject: subject, feedback: feedback);
      Get.back();
    }
  }
}
