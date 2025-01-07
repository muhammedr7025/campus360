import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../utils/constants.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image; // Changed to nullable type

  // Dummy list of departments (you can replace this with your actual department data from Firestore if needed)
  final List<String> departments = ['CSE', 'ECE', 'EEE', 'IT', 'Mech'];

  // Dummy list of batches (you can replace this with your actual batch data from Firestore if needed)
  final List<String> batches = ['2021', '2022', '2023', '2024'];

  // Function to fetch users from Firestore
  Stream<List<Map<String, dynamic>>> _getUsers() {
    return _firestore
        .collection('Users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id, // Add the document ID here
                  'name': doc['name'],
                  'role': doc['role'],
                  'email': doc['email'],
                  'department': doc['department'],
                  'batch': doc['batch'],
                  'class_id': doc['class_id'],
                  'profile_pic':
                      doc['profile_pic'], // Add the profile picture URL
                })
            .toList());
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to upload image to Firebase Storage and get the URL
  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() => null);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  // Function for adding or editing a user
  void _showUserForm(BuildContext context,
      {String? id,
      String? name,
      String? role,
      String? email,
      String? department,
      String? batch,
      String? class_id,
      String? profilePic,
      bool isEdit = false}) {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);
    final classIdController = TextEditingController(text: class_id);

    // Default values for role, department, and batch
    String? selectedBatch =
        batch ?? batches[0]; // Default to first batch if null
    String? selectedDepartment =
        department ?? departments[0]; // Default to first department if null
    String? selectedRole = role ?? 'Student'; // Default to 'Student' if null

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit User' : 'Add New User'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: InputDecoration(labelText: 'Department'),
                items: departments.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDepartment = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedBatch,
                decoration: InputDecoration(labelText: 'Batch'),
                items: batches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch,
                    child: Text(batch),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedBatch = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: 'Role'),
                items: [
                  'Admin',
                  'Faculty',
                  'Staff',
                  'Student',
                  'Security',
                  'Student Rep'
                ]
                    .map((roleOption) => DropdownMenuItem<String>(
                          value: roleOption,
                          child: Text(roleOption),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedRole = value;
                },
              ),
              // Display the selected profile image (check if _image is not null)
              if (_image != null)
                Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick Profile Picture"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String? profilePicUrl;
                if (_image != null) {
                  // Upload the image and get the URL
                  profilePicUrl = await _uploadImage(_image!);
                } else {
                  profilePicUrl =
                      profilePic; // Retain old image URL if no new image is selected
                }

                // Save to Firestore
                if (isEdit) {
                  // Update the user in Firestore using the document ID
                  _firestore
                      .collection('Users')
                      .doc(id) // Use actual user ID
                      .update({
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'department': selectedDepartment,
                    'batch': selectedBatch,
                    'class_id': classIdController.text,
                    'profile_pic':
                        profilePicUrl, // Update the profile picture URL
                  });
                } else {
                  // Add new user to Firestore
                  _firestore.collection('Users').add({
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'department': selectedDepartment,
                    'batch': selectedBatch,
                    'class_id': classIdController.text,
                    'profile_pic':
                        profilePicUrl, // Save the profile picture URL
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(isEdit ? 'Save Changes' : 'Add User'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function for deleting a user
  void _deleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _firestore.collection('Users').doc(userId).delete();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data;
          return ListView.builder(
            itemCount: users?.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getAvatarColor(users![index]['role']!),
                  backgroundImage: users[index]['profile_pic'] != null
                      ? NetworkImage(users[index]['profile_pic'])
                      : null, // Show profile picture if available
                  child: users[index]['profile_pic'] == null
                      ? Text(users[index]['name']![0])
                      : null,
                ),
                title: Text(users[index]['name']!),
                subtitle: Text(users[index]['role']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () {
                        _showUserForm(
                          context,
                          id: users[index]
                              ['id'], // Pass the document ID for editing
                          name: users[index]['name'],
                          role: users[index]['role'],
                          email: users[index]['email'],
                          department: users[index]['department'],
                          batch: users[index]['batch'],
                          class_id: users[index]['class_id'],
                          profilePic: users[index]
                              ['profile_pic'], // Pass the profile picture URL
                          isEdit: true,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteUser(
                            context,
                            users[index]
                                ['id']!); // Pass the document ID for deletion
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUserForm(context); // Open add user dialog
        },
        child: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );
  }

  Color _getAvatarColor(String role) {
    switch (role) {
      case 'Student':
        return Colors.blue;
      case 'Faculty':
        return Colors.green;
      case 'Staff':
        return Colors.orange;
      case 'Admin':
        return Colors.purple;
      case 'Security':
        return Colors.red; // Assign a unique color to the Security role
      case 'Student Rep':
        return Colors.yellow; // Assign a unique color to the Student Rep role
      default:
        return Colors.grey;
    }
  }
}
