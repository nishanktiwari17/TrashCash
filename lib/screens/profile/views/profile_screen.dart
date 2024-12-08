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
      _uploadImage(); 
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
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

  Future<void> _fetchUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
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
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _updateUserDetails() async {
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
          margin: EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          padding: EdgeInsets.symmetric(
              vertical: 10, horizontal: 20),
        );
      }
    } catch (e) {
      print("Error updating user details: $e");
    }
  }

  Widget _buildGenderField() {
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
      ),
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
    _fetchUserDetails();

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
                        padding: const EdgeInsets.only(right: 16.0),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical:
                                    16.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              width: double
                                  .infinity, 
                              child: DropdownButton<String>(
                                value: selectedGender,
                                isExpanded:
                                    true, 
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _hasChanges()
                        ? () {
                            _updateUserDetails();
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
