
import 'package:flutter/material.dart';
import 'package:my_camera_app/Screen/camera_app_trial.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(app());
}

class app extends StatelessWidget {
  const app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraAppTrial(),
    );
  }
}
