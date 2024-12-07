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
import 'package:waste_management_app/screens/profile/views/profile_screen.dart';
import 'package:waste_management_app/utils/firebase_functions.dart';

class UserController extends GetxController {
  Rx<String> userName = ''.obs;
  Rx<String> profilePicUrl = ''.obs;  // Add a variable to store profile picture URL

  @override
  void onInit() {
    super.onInit();
    fetchUserDetails();  // Fetch both user name and profile picture on initialization
  }

  // Fetch user details (name and profile picture) from Firestore using FirebaseFunctions
  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid; // Replace with dynamic user UID (e.g., from FirebaseAuth)
    
    if (uid != null) {
      // Fetch user name and profile picture URL from Firebase Functions or Firestore
      String? fetchedName = await FirebaseFunctions.instance.getUserName(uid: uid);
      String? fetchedProfilePic = await FirebaseFunctions.instance.fetchProfilePic(uid: uid);
      
      // Update the controller's state with the fetched details
      userName.value = fetchedName ?? '';
      profilePicUrl.value = fetchedProfilePic ?? '';
    }
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
                // Use GetX to fetch and display the user's name and profile picture
                GetX<UserController>(
                  init: UserController(),
                  builder: (controller) {
                    return HomeScreenTopRow(
                      userName: controller.userName.value.isEmpty
                          ? 'Loading...'  // Placeholder text while loading
                          : controller.userName.value,
                      profilePicUrl: controller.profilePicUrl.value.isEmpty
                          ? 'default_image_url'  // Placeholder if no profile picture is set
                          : controller.profilePicUrl.value,
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

class HomeScreenTopRow extends StatelessWidget {
  final String userName;
  final String profilePicUrl;

  const HomeScreenTopRow({
    required this.userName,
    required this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Align items on opposite sides
      children: [
        // User name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName!',
              style: kTitle2Style.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Profile picture on the right
        GestureDetector(
          onTap: () {
            // Navigate to the profile page when the profile picture is tapped
            Get.to(() => ProfileScreen());  // Replace ProfilePage() with your actual profile page widget
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profilePicUrl),  // Load profile picture from URL
            backgroundColor: Colors.grey[200],  // Set a fallback color if the image fails to load
          ),
        ),
      ],
    );
  }
}
