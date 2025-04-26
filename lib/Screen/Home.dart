import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera_app_trial extends StatefulWidget {
  const Camera_app_trial({super.key});

  @override
  State<Camera_app_trial> createState() => _Camera_app_trialState();
}

class _Camera_app_trialState extends State<Camera_app_trial> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: _buildUI(),
    );
  }

  Widget _buildUI()
  {
    if(cameraController==null|| cameraController?.value.isInitialized==false)
    {
      return const Center(
child: CircularProgressIndicator(),
      );
    }
    return SafeArea(child: SizedBox.expand(),);
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
        );
      });
      cameraController?.initialize().then((_) {
        setState(() {});
      });
    }
  }
}
