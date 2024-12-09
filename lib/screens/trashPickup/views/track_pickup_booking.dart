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

  void sendPickupConfirmationMessage(String userId) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        int rewardPointsTillDate = userData['reward_points_till_date'] ?? 0;
        int rewardPointsClaimed = userData['reward_points_claimed'] ?? 0;
        int rewardPointsAvailable = userData['reward_points_available'] ?? 0;

        int rewardPointsToAdd = 15;
        int newRewardPointsTillDate = rewardPointsTillDate + rewardPointsToAdd;
        int newRewardPointsAvailable =
            rewardPointsAvailable + rewardPointsToAdd;

        await userRef.update({
          'reward_points_till_date': newRewardPointsTillDate,
          'reward_points_available': newRewardPointsAvailable,
          'reward_points_claimed': rewardPointsClaimed
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Congratulations!",
            "Your order has been picked up. You've received 15 reward points.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        });
      } else {
        Get.snackbar(
          "Error",
          "User not found. Unable to update reward points.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
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
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pickup_bookings')
                        .doc(pickupBooking.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.data!.exists) {
                        return Center(
                            child: Text(
                                'Something Went Wrong. We will update you shortly.'));
                      }

                      var pickupData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      if (!pickupData.containsKey('status')) {
                        return Center(child: Text('Status field not found.'));
                      }

                      int currentStep =
                          int.parse(pickupData['status'].toString());

                      if (currentStep == 3 ) {
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
                ],
              ),
            ),
          ),
          Visibility(
            visible: pickupBooking
                .pickupPartner.value.partnerName.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  '${pickupBooking.pickupPartner.value.partnerName} will be picking up your order.\n'
                  '${pickupBooking.pickupPartner.value.partnerName} Number: ${pickupBooking.pickupPartner.value.partnerContact}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
