import 'package:campus360/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Check if the user is already logged in
  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  // Check if a user is logged in and navigate accordingly
  Future<void> _checkLoggedIn() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch the user data (role) from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();

      if (userDoc.exists) {
        String userRole =
            userDoc['role']; // Assuming role is stored in Firestore

        // Navigate based on the user role
        if (userRole == 'Admin') {
          Navigator.pushNamed(context, '/admin');
        } else if (userRole == 'Hod') {
          Navigator.pushNamed(context, '/hod');
        } else if (userRole == 'Staff') {
          Navigator.pushNamed(context, '/staff');
        } else if (userRole == 'Security') {
          Navigator.pushNamed(context, '/security');
        } else if (userRole == 'Student rep') {
          Navigator.pushNamed(context, '/student_rep');
        } else if (userRole == 'Student') {
          Navigator.pushNamed(context, '/student');
        } else if (userRole == 'Faculty') {
          Navigator.pushNamed(
              context, '/faculty'); // Add this line for faculty role
        }
      }
    }
  }

  // Login function
  Future<void> _loginUser() async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the user ID from the signed-in user
      String userId = userCredential.user!.uid;

      // Fetch the user data (role) from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        String userRole =
            userDoc['role']; // Assuming role is stored in Firestore

        // Navigate based on the user role
        if (userRole == 'Admin') {
          Navigator.pushNamed(context, '/admin');
        } else if (userRole == 'Hod') {
          Navigator.pushNamed(context, '/hod');
        } else if (userRole == 'Staff') {
          Navigator.pushNamed(context, '/staff');
        } else if (userRole == 'Security') {
          Navigator.pushNamed(context, '/security');
        } else if (userRole == 'Student rep') {
          Navigator.pushNamed(context, '/student_rep');
        } else if (userRole == 'Student') {
          Navigator.pushNamed(context, '/student');
        } else if (userRole == 'Faculty') {
          Navigator.pushNamed(
              context, '/faculty'); // Add this line for faculty role
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Invalid user role')));
        }
      } else {
        // User document not found
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found in database')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo Section
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 100,
                    color: primaryColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome!',
                    style: titleTextStyle,
                  ),
                  Text(
                    'to Campus360',
                    style: subtitleTextStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Email/Phone Input Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Phone number or Email',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),

            // Password Input Field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),

            // Login Button
            ElevatedButton(
              onPressed: _loginUser, // Trigger login when pressed
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Login',
                style: buttonTextStyle,
              ),
            ),
            SizedBox(height: 20),

            // Forgot Password Link
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle forgot password logic
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
