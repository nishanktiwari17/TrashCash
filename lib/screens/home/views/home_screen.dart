import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uicons/uicons.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/screens/home/controllers/location_controller.dart';
import 'package:waste_management_app/screens/home/data/carousel_blog_list.dart';
import 'package:waste_management_app/screens/home/views/components/carousel_card.dart';
import 'package:waste_management_app/screens/home/views/view_more_screen.dart';
import 'package:waste_management_app/utils/firebase_functions.dart';
import 'contact_support_screen.dart';
import 'faq_screen.dart';
import 'feedback_screen.dart';
import 'package:waste_management_app/screens/trashPickup/views/scheduled_pickups.dart';
import 'package:waste_management_app/screens/login/repository/auth_repository.dart';


class UserController extends GetxController {
  Rx<String> userName = ''.obs;
  Rx<String> profilePicUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid; 
    if (uid != null) {
      String? fetchedName = await FirebaseFunctions.instance.getUserName(uid: uid);
      String? fetchedProfilePic = await FirebaseFunctions.instance.fetchProfilePic(uid: uid);
      
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
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      drawer: Container(
  width: 250.0, 
  child: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          height: 110.0, 
          color: Colors.green, 
          child: DrawerHeader(
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
        ),
        ListTile(
          title: Text('My Bookings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduledPickupScreen(
                  backButtonVisible: true,
                ),
              ),
            );
          },
        ),
        ListTile(
          title: Text('Contact Support'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactSupportScreen()),
            );
          },
        ),
        ListTile(
          title: Text('FAQ'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FAQScreen()),
            );
          },
        ),
        ListTile(
          title: Text('Feedback'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedbackScreen()),
            );
          },
        ),
        Divider(),
        ListTile(
          title: Text('Logout'),
          leading: Icon(Icons.exit_to_app, color: Colors.red),
          onTap: () {
            AuthRepository.instance.signOut();
          },
        ),
      ],
    ),
  ),
),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetX<UserController>(
                  init: UserController(),
                  builder: (controller) {
                    return HomeScreenTopRow(
                      userName: controller.userName.value.isEmpty
                          ? 'Loading...'  
                          : controller.userName.value,
                      profilePicUrl: controller.profilePicUrl.value.isEmpty
                          ? 'default_image_url' 
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
                            print('Card tapped: ${blog.title}');
                          },
                          onViewMorePressed: () {
                            Get.to(() => ViewMoreScreen(blog: blog));
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName!',
              style: kTitle2Style.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(profilePicUrl),
          backgroundColor: Colors.grey[200],
        ),
      ],
    );
  }
}
