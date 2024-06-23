import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partnersapp/presentation/login_screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _image;
  User? _user;
  String? _imageUrl;
  dynamic _rating = 0.0;
  int workDone = 0;

  bool _isLoading = true;
  dynamic _ratingdisplay = 0.0;

  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }

  void _checkAuthentication() async {
    try {
      _user = _auth.currentUser;
      if (_user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        await _fetchUserData();
      }
    } catch (e) {
      print('Error during authentication check: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      if (_user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('technicians')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _nameController.text = userDoc['technicianName'] ?? '';
            _phoneNumberController.text = userDoc['phone'] ?? '';
            _imageUrl = (userDoc.data()
                    as Map<String, dynamic>?)?['technicianProfilePicture'] ??
                '';
            _rating = (userDoc.data() as Map<String, dynamic>?)?['Rating'] ?? 0;
            _ratingdisplay =
                (userDoc.data() as Map<String, dynamic>?)?['Rating'] ?? 0;
            workDone =
                (userDoc.data() as Map<String, dynamic>?)?['workDone'] ?? 0;

            _isLoading = false;
          });
        } else {
          print('User document does not exist');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editName(BuildContext context) async {
    String? name = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                saveNametoBackend(_nameController.text);
                Navigator.of(context).pop(_nameController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (name != null) {
      setState(() {
        _nameController.text = name;
      });
    }
  }

  Future<void> saveNametoBackend(String name) async {
    if (_user != null) {
      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(_user!.uid)
          .update({
        'technicianName': name,
      });
    }
  }

  Future<void> saveProfiletoBackend(File? file) async {
    if (file == null) {
      print('No file selected');
      return;
    }

    try {
      print('Image selected. Uploading...');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('technicians')
          .child(_user!.uid)
          .child('profile_picture.jpg');

      UploadTask uploadTask = storageRef.putFile(file);

      TaskSnapshot snapshot = await uploadTask;

      String downloadURL = await snapshot.ref.getDownloadURL();

      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('technicians')
            .doc(_user!.uid)
            .update({
          'technicianProfilePicture': downloadURL,
        });

        setState(() {
          _imageUrl = downloadURL;
        });

        print('Upload complete and URL saved to Firestore');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await saveProfiletoBackend(_image);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: 360,
                    height: 600,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 9,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Repairs Duniya',
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff6A6A6A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: _getImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : (_imageUrl != null &&
                                            _imageUrl!.isNotEmpty)
                                        ? NetworkImage(_imageUrl!)
                                        : const NetworkImage(
                                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg')
                                            as ImageProvider<Object>?,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Text(
                        //   'Edit picture',
                        //   style: GoogleFonts.openSans(
                        //     fontSize: 10,
                        //     fontWeight: FontWeight.w600,
                        //     color: const Color(0xff6A6A6A),
                        //   ),
                        // ),
                        const SizedBox(height: 22),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Colors.green, // Set background color to green
                            borderRadius:
                                BorderRadius.circular(14), // Set border radius
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: const Offset(0,
                                    0), // Adjust the offset to align the star vertically
                                child: const Icon(
                                  Icons.star,
                                  size: 19, // Adjust the size of the icon
                                  color:
                                      Colors.white, // Set icon color to white
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$_ratingdisplay',
                                style: GoogleFonts.openSans(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Colors.white, // Set text color to white
                                ),
                              ),
                              // Add some spacing between text and icon
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$workDone Works done',
                          style: GoogleFonts.openSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff6A6A6A),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: const Color(0xffFCCA43),
                              size: 33.72,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors
                                        .green), // Set border color to green
                                borderRadius: BorderRadius.circular(
                                    10), // Set border radius
                              ),
                              child: Text(
                                'Punctuality',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Colors.green, // Set text color to green
                                ),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    10), // Add some spacing between containers
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors
                                        .green), // Set border color to green
                                borderRadius: BorderRadius.circular(
                                    10), // Set border radius
                              ),
                              child: Text(
                                'Friendly',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Colors.green, // Set text color to green
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),
                        Container(
                          width: 232.6,
                          height: 56.73,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(28.37),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : (_imageUrl != null &&
                                            _imageUrl!.isNotEmpty)
                                        ? NetworkImage(_imageUrl!)
                                        : const NetworkImage(
                                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg')
                                            as ImageProvider<Object>?,
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _editName(context),
                                  child: Text(
                                    _nameController.text,
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _editName(context),
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 19),
                        Container(
                          width: 232.6,
                          height: 56.73,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(28.37),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 20),
                              const Icon(Icons.call, color: Colors.white),
                              const SizedBox(width: 28),
                              Expanded(
                                child: Text(
                                  _phoneNumberController.text,
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Log Out'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                logOut(context);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        );
                      },
                    );
                    print('Log Out');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    minimumSize:
                        MaterialStateProperty.all(const Size(232.6, 56.73)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logOut(BuildContext context) async {
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
