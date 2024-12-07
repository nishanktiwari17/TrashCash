import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/sharedWidgets/top_header_with_back.dart';
import 'package:waste_management_app/screens/trashPickup/views/book_a_pickup.dart';
import 'package:waste_management_app/screens/trashPickup/views/components/scheduled_booking_tile.dart';
import 'package:waste_management_app/utils/firebase_functions.dart';
import 'package:waste_management_app/screens/trashPickup/model/scheduled_pickup_model.dart';

class ScheduledPickupScreen extends StatefulWidget {
  const ScheduledPickupScreen({super.key, required this.backButtonVisible});
  final bool backButtonVisible;

  @override
  _ScheduledPickupScreenState createState() => _ScheduledPickupScreenState();
}

class _ScheduledPickupScreenState extends State<ScheduledPickupScreen> {
  bool isLoading = true; // This will indicate whether data is being fetched
  List<ScheduledPickupModel> scheduledPickups =
      []; // List to store scheduled pickups

  @override
  void initState() {
    super.initState();
    fetchScheduledPickups(); // Fetch the scheduled pickups when the screen is initialized
  }

  // Fetch the scheduled pickups from Firebase
  Future<void> fetchScheduledPickups() async {
    try {
      Future<String> fetchUserName() async {
        final user = FirebaseAuth.instance.currentUser;

        // If user is null, throw an exception or return a default value
        if (user == null) {
          throw Exception('No user is currently signed in');
        }

        // Return the UID as a non-nullable string
        return user.uid;
      }

      String uid = await fetchUserName(); // Get the UID of the current user
      var pickups = await FirebaseFunctions.instance.fetchScheduledPickups(uid);

      // After fetching the data, update the UI
      setState(() {
        scheduledPickups = pickups;  // Update the list of scheduled pickups
        isLoading = false;  // Stop showing the loading spinner
      });
    } catch (e) {
      print('Error fetching scheduled pickups: $e');
      setState(() {
        isLoading = false;  // Stop loading spinner in case of an error
      });
    }
  }

  // Function to handle the deletion of a scheduled pickup
  Future<void> deleteScheduledPickup(String pickupId) async {
    try {
      // Call Firebase function to delete the pickup booking
      await FirebaseFunctions.instance.deletePickupBooking(pickupId);

      // After deletion, refresh the list
      fetchScheduledPickups();
    } catch (e) {
      print('Error deleting pickup booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () {
          Get.to(
            () => BookTrashPickupScreen(),
            transition: Transition.zoom,
          );
        },
        child: Icon(
          UIcons.regularRounded.calendar_plus,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.backButtonVisible
                  ? TopHeaderWithBackButton(title: 'Scheduled Pickups')
                  : Center(
                      child: Text(
                        'Scheduled Pickups',
                        style: kTitle2Style.copyWith(color: Colors.black),
                      ),
                    ),
              const SizedBox(height: 20),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    )
                  : scheduledPickups.isEmpty
                      ? Center(
                          child: Text(
                            'No scheduled pickups',
                            style: kSubtitleStyle,
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: scheduledPickups.length,
                            itemBuilder: (context, index) {
                              var pickup = scheduledPickups[index];
                              return ScheduledBookingTile(
                                scheduledPickup: pickup,
                                onCancel: () async {
                                  // Call deleteScheduledPickup function to delete the booking
                                  await deleteScheduledPickup(pickup.id);
                                },
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
