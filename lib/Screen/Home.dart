import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class Camera_app_trial extends StatefulWidget {
  const Camera_app_trial({super.key});

  @override
  State<Camera_app_trial> createState() => _Camera_app_trialState();
}

class _Camera_app_trialState extends State<Camera_app_trial>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  String? _capturedImagePath;

  Future<void> _captureImage() async {
    try {
      XFile picture = await cameraController!.takePicture();
      await Gal.putImage(picture.path);

      // Read the image file
      final bytes = await File(picture.path).readAsBytes();

      // Decode the image with orientation correction
      final image = img.decodeImage(bytes);
      if (image != null) {
        // Create a new file with corrected orientation
        final correctedImage = img.copyRotate(
          image,
          angle: 0,
        ); // Adjust angle if needed
        final correctedBytes = img.encodeJpg(correctedImage);
        await File(picture.path).writeAsBytes(correctedBytes);
      }

      setState(() {
        _capturedImagePath = picture.path;
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI());
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.80,
              width: MediaQuery.sizeOf(context).height * 0.90,
              child: CameraPreview(cameraController!),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ' CAPTURE',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 5), // Keeps camera icon centered

                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: _captureImage,
                      iconSize: 70,
                      icon: const Icon(Icons.camera, color: Colors.red),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    // Just refresh or navigate to preview (if needed), no capturing
                    // Optional: show full screen image on tap
                  },
                  iconSize: 40,
                  icon:
                      (_capturedImagePath != null &&
                              File(_capturedImagePath!).existsSync())
                          ? ClipOval(
                            child: Image.file(
                              File(_capturedImagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Icon(Icons.person, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          _cameras.last,
          ResolutionPreset.low,
        );
      });
      cameraController
          ?.initialize()
          .then((_) {
            if (!mounted) {
              return;
            }
            setState(() {});
          })
          .catchError((Object e) {
            print(e);
          });
    }
  }
}
