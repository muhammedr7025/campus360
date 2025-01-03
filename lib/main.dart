import 'package:flutter/material.dart';
import 'screens/login/login_page.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/dashboard/hod_dashboard.dart';
import 'screens/dashboard/staff_dashboard.dart';
import 'screens/dashboard/security_dashboard.dart';
import 'screens/dashboard/student_rep_dashboard.dart';
import 'screens/dashboard/student_dashboard.dart';
import 'utils/constants.dart'; // Import constants for theme

void main() {
  runApp(Campus360App());
}

class Campus360App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus360',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: primaryColor, // Use backgroundColor from constants
        textTheme: TextTheme(
          titleLarge: titleTextStyle,
          labelLarge: subtitleTextStyle,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
            .copyWith(secondary: secondaryColor)
            .copyWith(background: backgroundColor),
      ),
      // Define named routes
      routes: {
        '/': (context) => LoginPage(),
        '/admin': (context) => AdminDashboard(),
        '/hod': (context) => HODDashboard(),
        '/staff': (context) => StaffDashboard(),
        '/security': (context) => SecurityDashboard(),
        '/student_rep': (context) => StudentRepDashboard(),
        '/student': (context) => StudentDashboard(),
      },
      initialRoute: '/', // Initial route is the LoginPage
    );
  }
}
