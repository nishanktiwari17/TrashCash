import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:uicons/uicons.dart';
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
  String? _profileImageUrl;
  String? _userName;
  String? _userPhoneNumber;

  // Variables to store original values for comparison
  String? _originalUserName;
  String? _originalUserPhoneNumber;
  String? _originalAge;
  String? _originalGender;
  String? _originalNickname; // Default value

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  String _selectedGender = "Men"; // Default value for gender dropdown

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Method to upload the image to Firebase Storage
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
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Method to fetch user details from Firestore
  Future<void> _fetchUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            _profileImageUrl = docSnapshot['profile_picture'];
            _userName = docSnapshot['name'] ?? '';
            _userPhoneNumber = docSnapshot['phoneNumber'] ?? '';
            _originalUserName = _userName;
            _originalUserPhoneNumber = _userPhoneNumber;

            _nameController.text = _userName!;
            _phoneController.text = _userPhoneNumber!;
            _ageController.text = docSnapshot['age'] ?? '';
            _nicknameController.text = docSnapshot['nickname'] ?? '';
            _selectedGender = docSnapshot['gender'] ?? 'Men';
          });
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  // Method to update the user details in Firestore
  Future<void> _updateUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
          'age': _ageController.text,
          'gender': _selectedGender,
          'nickname': _nicknameController.text,
        });

        // Show the confirmation pop-up (Snackbar)
        Get.snackbar(
          "", // Empty title
          "Details have been saved.", // Message only
          snackPosition: SnackPosition.TOP, // Positioned at the top
          backgroundColor: Colors.green, // Green background for success
          colorText: Colors.white, // White color for text
          duration: Duration(seconds: 2), // Snackbar duration
          borderRadius: 8.0, // Border radius for smooth edges
          margin: EdgeInsets.symmetric(
              horizontal: 20, vertical: 10), // Margin for spacing
          padding: EdgeInsets.symmetric(
              vertical: 10, horizontal: 20), // Padding inside the snackbar
        );
      }
    } catch (e) {
      print("Error updating user details: $e");
    }
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          // If newValue is not null, update _selectedGender
          if (newValue != null) {
            _selectedGender = newValue;
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

  // Method to check if any changes were made
  bool _hasChanges() {
    return _nameController.text != _originalUserName ||
        _phoneController.text != _originalUserPhoneNumber ||
        _ageController.text != _originalAge ||
        _nicknameController.text != _originalNickname ||
        _selectedGender != _originalGender;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();

    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _ageController.addListener(_checkForChanges);
    _nicknameController.addListener(_checkForChanges);
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
                      // Stack to position the camera icon on top of the profile picture
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: kPrimaryColor,
                              child: _profileImageUrl == null
                                  ? SvgPicture.asset(
                                      'assets/images/homeScreen/profile_pic.svg',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        _profileImageUrl!,
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
                _buildEditableField('Name', _nameController),
                const SizedBox(height: 10),
                _buildEditableField('Phone Number', _phoneController),
                const SizedBox(height: 10),
                _buildEditableField('Nickname', _nicknameController),
                const SizedBox(height: 10),
                // Row with Age and Gender fields side by side
                Row(
                  children: [
                    Expanded(
                      child: _buildEditableField('Age', _ageController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 10.0), // Align Gender to the left
                        child: _buildGenderField(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _hasChanges() ? _updateUserDetails : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
