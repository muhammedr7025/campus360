import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final List<String> departments = ['CSE', 'ECE', 'EEE', 'IT', 'Mech'];
  final List<String> batches = ['2021', '2022', '2023', '2024'];

  // Fetch users from Firestore
  Stream<List<Map<String, dynamic>>> _getUsers() {
    return _firestore
        .collection('Users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc['name'],
                'role': doc['role'],
                'email': doc['email'],
                'department': doc['department'],
                'batch': doc['batch'],
                'class_id': doc['class_id'],
                'profile_pic': doc['profile_pic'],
              };
            }).toList());
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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

  // Add or Edit User
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

    String selectedBatch = batch ?? 'None';
    String selectedDepartment = department ?? 'None';
    String selectedRole = role ?? 'Student';

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
                  decoration: InputDecoration(labelText: 'Full Name')),
              TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email')),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: InputDecoration(labelText: 'Department'),
                items: ['None', ...departments].map((dept) {
                  return DropdownMenuItem<String>(
                      value: dept, child: Text(dept));
                }).toList(),
                onChanged: (value) {
                  selectedDepartment = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedBatch,
                decoration: InputDecoration(labelText: 'Batch'),
                items: ['None', ...batches].map((batch) {
                  return DropdownMenuItem<String>(
                      value: batch, child: Text(batch));
                }).toList(),
                onChanged: (value) {
                  selectedBatch = value!;
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
                  'Student Rep',
                  'Hod'
                ]
                    .map((roleOption) => DropdownMenuItem<String>(
                        value: roleOption, child: Text(roleOption)))
                    .toList(),
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
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
                  profilePicUrl = await _uploadImage(_image!);
                } else {
                  profilePicUrl = profilePic;
                }

                if (!isEdit) {
                  try {
                    UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: '12345678',
                    );
                    String userId = userCredential.user!.uid;

                    await _firestore.collection('Users').doc(userId).set({
                      'name': nameController.text,
                      'email': emailController.text,
                      'role': selectedRole,
                      'department': selectedDepartment,
                      'batch': selectedBatch,
                      'class_id': classIdController.text,
                      'profile_pic': profilePicUrl,
                      'uid': userId,
                    });

                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error creating user: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error creating user: $e")));
                  }
                } else {
                  _firestore.collection('Users').doc(id).update({
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'department': selectedDepartment,
                    'batch': selectedBatch,
                    'class_id': classIdController.text,
                    'profile_pic': profilePicUrl,
                  });
                  Navigator.of(context).pop();
                }
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

  // Delete User
  void _deleteUser(BuildContext context, String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  await _auth.currentUser?.delete();
                  await _firestore.collection('Users').doc(userId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User deleted successfully!')));
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error deleting user: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting user: $e')));
                }
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
                      : null,
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
                          id: users[index]['id'],
                          name: users[index]['name'],
                          role: users[index]['role'],
                          email: users[index]['email'],
                          department: users[index]['department'],
                          batch: users[index]['batch'],
                          class_id: users[index]['class_id'],
                          profilePic: users[index]['profile_pic'],
                          isEdit: true,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteUser(context, users[index]['id']!);
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
          _showUserForm(context);
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
        return Colors.red;
      case 'Student Rep':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
