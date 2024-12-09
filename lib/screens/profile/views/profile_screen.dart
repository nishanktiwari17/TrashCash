import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:waste_management_app/constants/colors.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/screens/login/repository/auth_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? profileImageUrl;
  String? userName;
  String? userPhoneNumber;

  String? originalUserName;
  String? originalUserPhoneNumber;
  String? originalAge;
  String? originalGender;
  String? originalNickname;

  int? availableRewardPoints;
  int? redeemedRewardPoints;
  int? totalRewardPoints;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  String selectedGender = "Men";

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is signed in');
      }

      String fileName = 'profile_pictures/${user.uid}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      await storageRef.putFile(_image!);

      String downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profile_picture': downloadUrl,
      });

      setState(() {
        profileImageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print("indide");
      print(user);
      if (user != null) {
        DocumentSnapshot docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {

            redeemedRewardPoints = docSnapshot['reward_points_claimed'] ?? 0;
            availableRewardPoints = docSnapshot['reward_points_available']?? 0;
            totalRewardPoints = docSnapshot['reward_points_till_date'] ?? 0;

          setState(() {
            profileImageUrl = docSnapshot['profile_picture'];
            userName = docSnapshot['name'] ?? '';
            userPhoneNumber = docSnapshot['phoneNumber'] ?? '';
            originalUserName = userName;
            originalUserPhoneNumber = userPhoneNumber;

            nameController.text = userName!;
            phoneController.text = userPhoneNumber!;
            ageController.text = docSnapshot['age'] ?? '';
            nicknameController.text = docSnapshot['nickname'] ?? '';
            selectedGender = docSnapshot['gender'] ?? 'Men';
          });
        } else {
          print("Snapshot doesn't exist");
        }
      } else {
        print("User data failed");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> updateUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text,
          'phoneNumber': phoneController.text,
          'age': ageController.text,
          'gender': selectedGender,
          'nickname': nicknameController.text,
        });

        Get.snackbar(
          "Hooray! ",
          "Details have been saved.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          borderRadius: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        );
      }
    } catch (e) {
      print("Error updating user details: $e");
    }
  }

  Widget buildGenderField() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            selectedGender = newValue;
          }
        });
      },
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      isDense: true,
      items: ['Men', 'Women', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  bool _hasChanges() {
    return nameController.text != originalUserName ||
        phoneController.text != originalUserPhoneNumber ||
        ageController.text != originalAge ||
        nicknameController.text != originalNickname ||
        selectedGender != originalGender;
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();

    nameController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
    ageController.addListener(_checkForChanges);
    nicknameController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {});
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType:
            label == 'Age' ? TextInputType.number : TextInputType.text,
      ),
    );
  }

Widget _buildNonEditableField(String label, int? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
  );
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
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: kPrimaryColor,
                              child: profileImageUrl == null
                                  ? SvgPicture.asset(
                                      'assets/images/homeScreen/profile_pic.svg',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        profileImageUrl!,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          AuthRepository
                                  .instance.firebaseUser.value?.displayName ??
                              'User',
                          style: kTitleStyle,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditableField('Name', nameController),
                const SizedBox(height: 10),
                _buildEditableField('Phone Number', phoneController),
                const SizedBox(height: 10),
                _buildEditableField('Nickname', nicknameController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildEditableField('Age', ageController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 9.0),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical:
                                    9.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedGender,
                              isExpanded: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (newValue != null) {
                                    selectedGender = newValue;
                                  }
                                });
                              },
                              items: [
                                'Men',
                                'Women',
                                'Other'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _hasChanges()
                        ? () {
                            updateUserDetails();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16),
                    ),

                  ),
                ),
                const SizedBox(height: 10),
                _buildNonEditableField('Available Reward Points', availableRewardPoints),
                _buildNonEditableField('Redeemed Reward Points', redeemedRewardPoints),
                _buildNonEditableField('Total Reward Points Collected', totalRewardPoints),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
