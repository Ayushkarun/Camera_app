
import 'package:flutter/material.dart';
import 'package:my_camera_app/Screen/Home.dart';

void main() {
  runApp(app());
}

class app extends StatelessWidget {
  const app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Camera_app_trial(),
    );
  }
}
