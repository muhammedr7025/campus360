import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Text(
          'Welcome to the Admin Dashboard!',
          style: titleTextStyle,
        ),
      ),
    );
  }
}
