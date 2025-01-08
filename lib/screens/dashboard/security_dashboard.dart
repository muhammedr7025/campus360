import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/constants.dart';

class SecurityDashboard extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Logout function
  Future<void> _logoutUser(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Dashboard'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logoutUser(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Security Dashboard Content Here'),
      ),
    );
  }
}
