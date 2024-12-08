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
  ScheduledPickupScreenState createState() => ScheduledPickupScreenState();
}

class ScheduledPickupScreenState extends State<ScheduledPickupScreen> {
  bool isLoading = true;
  List<ScheduledPickupModel> scheduledPickups = [];

  @override
  void initState() {
    super.initState();
    fetchScheduledPickups();
  }

  Future<void> fetchScheduledPickups() async {
    try {
      Future<String> fetchUserName() async {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          throw Exception('No user is currently signed in');
        }

        return user.uid;
      }

      String uid = await fetchUserName();
      var pickups = await FirebaseFunctions.instance.fetchScheduledPickups(uid);

      setState(() {
        scheduledPickups = pickups;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching scheduled pickups: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteScheduledPickup(String pickupId) async {
    try {
      await FirebaseFunctions.instance.deletePickupBooking(pickupId);

      fetchScheduledPickups();
    } catch (e) {
      print('Error deleting pickup booking: $e');
    }
  }

  Future<void> showConfirmationDialog(String pickupId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete this scheduled pickup?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteScheduledPickup(pickupId);
              },
            ),
          ],
        );
      },
    );
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
                                  await showConfirmationDialog(pickup.id);
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
