import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:uicons/uicons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/screens/trashPickup/data/pickup_statuses.dart';
import 'package:waste_management_app/screens/trashPickup/model/scheduled_pickup_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackPickupBookingScreen extends StatelessWidget {
  const TrackPickupBookingScreen({super.key, required this.pickupBooking});
  final ScheduledPickupModel pickupBooking;

  // This method will send the broadcast message and update Firebase
  void sendPickupConfirmationMessage(String userId) async {
    // Step 1: Get the current user data
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Fetch the user document
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // Step 2: Extract current reward points
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        int rewardPointsTillDate = userData['reward_points_till_date'] ?? 0;
        int rewardPointsClaimed = userData['reward_points_claimed'] ?? 0;
        int rewardPointsAvailable = userData['reward_points_available'] ?? 0;

        // Step 3: Calculate new reward points
        int rewardPointsToAdd = 15;
        int newRewardPointsTillDate = rewardPointsTillDate + rewardPointsToAdd;
        int newRewardPointsAvailable =
            rewardPointsAvailable + rewardPointsToAdd;

        // Step 4: Update the user's reward points in Firestore
        await userRef.update({
          'reward_points_till_date': newRewardPointsTillDate,
          'reward_points_available': newRewardPointsAvailable,
        });

        // Step 5: Show the Snackbar with confirmation message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Congratulations!",
            "Your order has been picked up. You've received 15 reward points.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(
                seconds: 3), // Set duration to show the message for 3 seconds
          );
        });
      } else {
        // Handle case where the user data is not found
        Get.snackbar(
          "Error",
          "User not found. Unable to update reward points.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Handle errors in fetching or updating data
      Get.snackbar(
        "Error",
        "An error occurred while updating reward points: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                // Google Map widget stays as it is.
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      pickupBooking.selectedLocation.latitude,
                      pickupBooking.selectedLocation.longitude,
                    ),
                    zoom: 11.4746,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('Your Location'),
                      position: LatLng(
                        pickupBooking.selectedLocation.latitude,
                        pickupBooking.selectedLocation.longitude,
                      ),
                      infoWindow: const InfoWindow(title: 'Your Location'),
                    ),
                  },
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      // Use Navigator.pop() to go back
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        UIcons.regularRounded.angle_small_left,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID:',
                        style: kTitle2LessEmphasis,
                      ),
                      Text(
                        pickupBooking.id,
                        style: kTitle2Style.copyWith(
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //* StepProgressIndicator with proper Obx usage for status updates
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pickup_bookings')
                        .doc(pickupBooking.id)
                        .snapshots(), // Listening to the updates in Firestore
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // Check if the document exists before accessing its fields
                      if (!snapshot.data!.exists) {
                        return Center(
                            child: Text(
                                'Something Went Wrong. We will update you shortly.'));
                      }

                      var pickupData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      // Check if 'status' field exists in the document
                      if (!pickupData.containsKey('status')) {
                        return Center(child: Text('Status field not found.'));
                      }

                      // Access the status field after null checks
                      int currentStep =
                          int.parse(pickupData['status'].toString());

                      // If the status has changed to 3, show the message
                      if (currentStep == 3) {
                        sendPickupConfirmationMessage(pickupData["user_id"]);
                      }

                      return StepProgressIndicator(
                        totalSteps: 4,
                        currentStep: currentStep + 1,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        size: 125,
                        selectedColor: kPrimaryColor,
                        unselectedColor: Colors.black12,
                        customStep: (index, color, _) {
                          return color == kPrimaryColor
                              ? Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color,
                                      child: Icon(
                                        UIcons.boldRounded.check,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      pickupStatuses[index],
                                      style: kSubtitle3Style,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color,
                                      child: Icon(
                                        UIcons.boldRounded.cross,
                                        size: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      pickupStatuses[index],
                                      style: kSubtitle3Style,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                        },
                      );
                    },
                  ),
                  
                  
                  const SizedBox(
                    height: 20,
                  ),
                  // Delivery Partner Info
                  Visibility(
                    visible: pickupBooking
                        .pickupPartner.value.partnerName.isNotEmpty,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      isThreeLine: true,
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: kPrimaryColor,
                        child: Icon(
                          UIcons.boldRounded.user,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Delivery Partner',
                        style: kTitle3Style,
                      ),
                      subtitle: Text(
                        '${pickupBooking.pickupPartner.value.partnerName}',
                        style: TextStyle(
                          fontSize: 14, // Example font size
                          fontWeight: FontWeight.w400, // Example weight
                          color: Colors.black54, // Adjust color as needed
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
