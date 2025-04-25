import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera_app_trial extends StatefulWidget {
  const Camera_app_trial({super.key});

  @override
  State<Camera_app_trial> createState() => _Camera_app_trialState();
}

class _Camera_app_trialState extends State<Camera_app_trial> {
  List<CameraDescription> cameras =[];
  CameraController? cameraController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Camera App Trial'),
      // ),

    );
  }

  Future<void> _setupCameraController() async{
   List<CameraDescription> _cameras = await availableCameras();
   if(_cameras.isNotEmpty){
    setState(() {
      cameras=_cameras;
      cameraController=CameraController(_cameras.first, ResolutionPreset.high);
    });
   
   }
  }
}