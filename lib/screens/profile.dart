import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../components/phone_component.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isEditing = false;
  bool _isUpdating = false; // Track if an update operation is in progress
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _profilePicUrl = ''; // Placeholder for profile picture URL
  File? _profilePicFile; // File object for profile picture

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
  }

  void _loadUserProfile() async {
    if (_user != null) {
      DocumentSnapshot userProfile =
      await _firestore.collection('users').doc(_user!.uid).get();
      setState(() {
        _firstNameController.text = userProfile['firstName'] ?? '';
        _lastNameController.text = userProfile['lastName'] ?? '';
        _phoneNumberController.text = userProfile['phoneNumber'] ?? '';
        _profilePicUrl = userProfile['profilePic'] ?? ''; // Load profile picture URL
      });
    }
  }

  void _updateUserProfile() async {
    setState(() {
      _isUpdating = true; // Start updating process, show loader
    });

    if (_user != null) {
      // Prepare update data
      Map<String, dynamic> updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneNumberController.text,
      };

      // If profile picture file is selected, upload it and update URL
      if (_profilePicFile != null) {
        String profilePicUrl = await _uploadProfilePicture(_profilePicFile!);
        updateData['profilePic'] = profilePicUrl;
      }

      // Update user document
      await _firestore.collection('users').doc(_user!.uid).update(updateData);

      setState(() {
        _isEditing = false;
        _isUpdating = false; // Update complete, hide loader
      });
    }
  }

  Future<String> _uploadProfilePicture(File profilePicFile) async {
    try {
      String fileName = _user!.uid;

      Reference storageReference =
      FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      UploadTask uploadTask = storageReference.putFile(profilePicFile);

      await uploadTask.whenComplete(() => null);
      String downloadURL = await storageReference.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return '';
    }
  }

  void _logout() async {
    await _auth.signOut();
    setState(() {
      _user = null;
    });
  }

  void _showLoginModal() {
    showPhoneNumberLoginModal(context, () {
      setState(() {
        _user = _auth.currentUser;
        if (_user != null) {
          _loadUserProfile();
        }
      });
    });
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePicFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _user == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please log in to view your profile details.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showLoginModal,
              child: Text('Log In'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: _isEditing ? _pickProfilePicture : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profilePicUrl.isNotEmpty
                          ? NetworkImage(_profilePicUrl)
                          : NetworkImage('https://picsum.photos/200/300')
                      as ImageProvider,
                    ),
                    if (_isUpdating)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                readOnly: !_isEditing,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                readOnly: !_isEditing,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                readOnly: true,
              ),
              SizedBox(height: 20),
              _isEditing
                  ? ElevatedButton(
                onPressed: _updateUserProfile,
                child: Text('Save'),
              )
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Container(child: Center(child: Text('Edit'))),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _logout,
                child: Container(
                    width: double.infinity,
                    child: Center(child: Text('Logout'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
