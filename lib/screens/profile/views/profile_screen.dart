import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io'; 

import 'package:uicons/uicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/screens/login/repository/auth_repository.dart';
import 'package:waste_management_app/screens/profile/views/components/profile_list_tile.dart';
import 'package:waste_management_app/screens/profile/views/contact_support_screen.dart';
import 'package:waste_management_app/screens/profile/views/faq_screen.dart';
import 'package:waste_management_app/screens/profile/views/feedback_screen.dart';
import 'package:waste_management_app/screens/trashPickup/views/scheduled_pickups.dart';
import 'package:waste_management_app/screens/viewShopOrders/views/view_all_orders.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _image;  // Variable to hold the picked image

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);  // Use ImageSource.camera for capturing a new photo
    if (image != null) {
      setState(() {
        _image = File(image.path);  // Update the UI with the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,  // Open image picker when tapped
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: kPrimaryColor,
                          // Check if image is picked; use SVG for default
                          child: _image == null
                              ? SvgPicture.asset(
                                  'assets/images/homeScreen/profile_pic.svg', // Display SVG if no image selected
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                              : ClipOval(
                                  child: Image.file(
                                    _image!, // Show the picked image
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Center the user's name
                      Center(
                        child: Text(
                          AuthRepository.instance.firebaseUser.value?.displayName ?? 'User',  // Null safety for displayName
                          style: kTitleStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Orders And Payments',
                  style: kTitle2Style.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 10),
                ProfileListTile(
                  title: 'My Orders',
                  icon: UIcons.regularRounded.shopping_bag,
                  onTap: () => Get.to(
                    () => ViewAllOrdersScreen(),
                    transition: Transition.zoom,
                  ),
                ),
                ProfileListTile(
                  title: 'My Bookings',
                  icon: UIcons.regularRounded.boxes,
                  onTap: () => Get.to(
                    () => ScheduledPickupScreen(backButtonVisible: true),
                    transition: Transition.zoom,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Support And Feedback',
                  style: kTitle2Style.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 10),
                ProfileListTile(
                  title: 'FAQs',
                  icon: UIcons.regularRounded.comment_question,
                  onTap: () => Get.to(
                    () => FAQScreen(),
                    transition: Transition.zoom,
                  ),
                ),
                ProfileListTile(
                  title: 'Contact Support',
                  icon: UIcons.regularRounded.call_history,
                  onTap: () => Get.to(
                    () => ContactSupportScreen(),
                    transition: Transition.zoom,
                  ),
                ),
                ProfileListTile(
                  title: 'Feedback',
                  icon: UIcons.regularRounded.notebook,
                  onTap: () => Get.to(
                    () => FeedbackScreen(),
                    transition: Transition.zoom,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Settings',
                  style: kTitle2Style.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 10),
                ProfileListTile(
                  title: 'Logout',
                  icon: UIcons.regularRounded.exit,
                  onTap: () {
                    AuthRepository.instance.signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
