import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uicons/uicons.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/screens/home/controllers/location_controller.dart';
import 'package:waste_management_app/screens/home/data/carousel_blog_list.dart';
import 'package:waste_management_app/screens/home/views/components/carousel_card.dart';
import 'package:waste_management_app/screens/home/views/components/top_row.dart';
import 'package:waste_management_app/screens/home/views/view_more_screen.dart';
import 'package:waste_management_app/utils/firebase_functions.dart';

class UserController extends GetxController {
  Rx<String> userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserName();
  }

  // Fetch user name from Firestore using FirebaseFunctions
  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid; // Replace with dynamic user UID (e.g., from FirebaseAuth)
    String? fetchedName = await FirebaseFunctions.instance.getUserName(uid: uid);
    userName.value = fetchedName;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use GetX to fetch and display the user's name
                GetX<UserController>(
                  init: UserController(),
                  builder: (controller) {
                    return HomeScreenTopRow(
                      userName: controller.userName.value.isEmpty
                          ? 'Loading...'  // Placeholder text while loading
                          : controller.userName.value,
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Let\'s clean our environment',
                  style: kTitle2LessEmphasis,
                ),
                SizedBox(
                  height: 20,
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: false,
                    viewportFraction: 1.0,
                  ),
                  items: blogList.map((blog) {
                    return Builder(
                      builder: (BuildContext context) {
                        return CarouselCard(
                          title: blog.title,
                          description: blog.description,
                          imagePath: blog.imagePath,
                          onTap: () {
                            // Define the action for the entire card (e.g., navigate to a detail screen)
                            print('Card tapped: ${blog.title}');
                          },
                          onViewMorePressed: () {
                            // Pass the selected blog to ViewMoreScreen
                            Get.to(ViewMoreScreen(blogs: blogList));
                          }
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                GetX<LocationController>(
                  init: LocationController(),
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          onTap: () {
                            controller.getCurrentPosition();
                          },
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 0,
                          title: Text(
                            'Your Location',
                            style: kTitle2Style,
                          ),
                          subtitle: Text(
                            controller.userAddress.value == ''
                                ? 'Tap to get your location'
                                : controller.userAddress.value,
                            style: kSubtitleStyle,
                          ),
                          leading: Icon(
                            UIcons.regularRounded.location_alt,
                            color: kPrimaryColor,
                          ),
                        ),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: GoogleMap(
                            mapType: MapType.normal,
                            onMapCreated: (mapController) {
                              controller.mapController = mapController;
                            },
                            initialCameraPosition: CameraPosition(
                              target: controller.userLatLng.value,
                              zoom: 14.4746,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('userLocation'),
                                position: controller.userLatLng.value,
                              )
                            },
                          ),
                        ),
                      ],
                    );
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