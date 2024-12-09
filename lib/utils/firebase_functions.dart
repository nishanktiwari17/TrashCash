import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:waste_management_app/constants/firebase_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management_app/screens/trashPickup/model/scheduled_pickup_model.dart';

class FirebaseFunctions {
  static FirebaseFunctions get instance => FirebaseFunctions();

  //* ------------------- AUTHENTICATION FUNCTIONS: ---------------------

  Future<void> createUserDocumentWithEmailAndPassword(
      {required String name,
      required String email,
      required String password,
      required String uid}) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.USERS)
        .doc(uid)
        .set({
      'name': name,
      'email': email,
      'password': password,
      'uid': uid,
      'phoneNumber': null
    });
  }


  Future<bool> checkIfPhoneNumberExists(String phoneNumber) async {
    bool exists = false;
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.USERS)
        .doc(phoneNumber)
        .get()
        .then((value) {
      if (value.exists) {
        log("User exists");
        exists = true;
      } else {
        log("User does not exist");
      }
    });
    return exists;
  }

  Future<String> fetchProfilePic({required String uid}) async {
    String profilePicUrl = '';

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.USERS)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        profilePicUrl = userData['profile_picture'] ?? '';
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
    }

    return profilePicUrl;
  }

  Future<String> getUserName({required String? uid}) async {
    String name = '';
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.USERS)
        .doc(uid)
        .get()
        .then((value) {
      if (value.exists) {
        name = value.data()!['name'];
      }
    });
    return name;
  }

  //* ------------------- TRASH PICKUP FUNCTIONS: ---------------------
  Future<void> createPickupBooking(
      {required DateTime selectedDate,
      required TimeOfDay selectedTimeSlot,
      required List<String> selectedWasteTypes,
      required String pickUpAddress,
      required LatLng selectedLocation,
      required String contactName,
      required String contactNumber,
      required String instructions,
      required Object pickupPartner,
      required String uid}) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.PICKUP_BOOKINGS)
        .add({
      'selectedDate': selectedDate,
      'selectedTimeSlotString': DateFormat('hh:mm a').format(selectedDate),
      'selectedWasteTypes': selectedWasteTypes,
      // TODO: ADD TIMESTAMP FOR TIMESLOT
      'pickUpAddress': pickUpAddress,
      'selectedLocation':
          GeoPoint(selectedLocation.latitude, selectedLocation.longitude),
      'instructions': instructions,
      'contactName': contactName,
      'contactNumber': contactNumber,
      'status': '0',
      'user_id': uid,
      'pickupPartner': pickupPartner
    }).then((value) => {
              log('Pickup Booking Created'),
              FirebaseFirestore.instance
                  .collection(FirebaseCollections.PICKUP_BOOKINGS)
                  .doc(value.id)
                  .update({'id': value.id})
            });
  }

  Future<void> deletePickupBooking(String pickupId) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.PICKUP_BOOKINGS)
          .doc(pickupId)
          .delete();
      print('Pickup booking deleted successfully');
    } catch (e) {
      print('Error deleting pickup booking: $e');
    }
  }

  Future<List<ScheduledPickupModel>> fetchScheduledPickups(String uid) async {
    List<ScheduledPickupModel> pickups = [];

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.PICKUP_BOOKINGS)
          .where('user_id', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          pickups.add(
              ScheduledPickupModel.fromMap(doc.data() as Map<String, dynamic>));
        }
      }
    } catch (e) {
      print('Error fetching scheduled pickups: $e');
    }

    return pickups;
  }

  //* ------------------- SUBMIT FEEDBACK FUNCTIONS: ---------------------

  Future<void> submitFeedback(
      {required String subject,
      required String feedback,
      required String uid}) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.FEEDBACK)
        .add({
      'subject': subject,
      'feedback': feedback,
      'user_id': uid,
    });
  }
}
