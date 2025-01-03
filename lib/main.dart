import 'package:flutter/material.dart';
import 'screens/login/login_page.dart';

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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(), // Set LoginPage as the first screen
    );
  }
}
