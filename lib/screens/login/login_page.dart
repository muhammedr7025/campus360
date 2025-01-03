import 'package:campus360/utils/constants.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final String userRole =
      'admin'; // Hardcoded for demo, will come from Firebase later

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
              onPressed: () {
                // Replace with Firebase login logic later
                // Navigate to the appropriate dashboard based on userRole
                if (userRole == 'admin') {
                  Navigator.pushNamed(context, '/admin');
                } else if (userRole == 'hod') {
                  Navigator.pushNamed(context, '/hod');
                } else if (userRole == 'staff') {
                  Navigator.pushNamed(context, '/staff');
                } else if (userRole == 'security') {
                  Navigator.pushNamed(context, '/security');
                } else if (userRole == 'student_rep') {
                  Navigator.pushNamed(context, '/student_rep');
                } else if (userRole == 'student') {
                  Navigator.pushNamed(context, '/student');
                }
              },
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
