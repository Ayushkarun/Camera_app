import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'gallery_screen.dart'; // Import for the gallery screen
import 'full_screen_image.dart';

class CameraAppTrial extends StatefulWidget {
  const CameraAppTrial({super.key});

  @override
  State<CameraAppTrial> createState() => _CameraAppTrialState();
}

class _CameraAppTrialState extends State<CameraAppTrial>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  String? _capturedImagePath;
  List<String> _capturedImages = []; // List to store all captured image paths

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle camera controller when app state changes
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      // Dispose camera when app is inactive
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize camera when app resumes
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCameraController();
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set black background
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    // Show loading indicator while camera initializes
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.red, // Match your app theme
        ),
      );
    }

    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera preview area
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.80,
              width: MediaQuery.sizeOf(context).height * 0.90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: CameraPreview(cameraController!),
              ),
            ),

            // Bottom controls row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery button (left side)
                  _buildGalleryButton(),

                  // Capture button (center)
                  _buildCaptureButton(),

                  // Thumbnail preview (right side)
                  _buildThumbnailPreview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return IconButton(
      onPressed: _capturedImages.isNotEmpty
          ? () {
              // Navigate to gallery with all captured images (newest first)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                    images: _capturedImages.reversed.toList(),
                  ),
                ),
              );
            }
          : null, // Disable if no images
      icon: const Icon(Icons.photo_library, color: Colors.red, size: 30),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red, width: 3),
      ),
      child: IconButton(
        onPressed: _captureImage,
        iconSize: 70,
        icon: const Icon(Icons.camera, color: Colors.red),
      ),
    );
  }

  Widget _buildThumbnailPreview() {
    return SizedBox(
      width: 50,
      height: 50,
      child: _capturedImagePath != null && File(_capturedImagePath!).existsSync()
          ? GestureDetector(
              onTap: () {
                // Show the last captured image full screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(
                      imagePath: _capturedImagePath!,
                    ),
                  ),
                );
              },
              child: ClipOval(
                child: Image.file(
                  File(_capturedImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : const Icon(Icons.person, color: Colors.red, size: 30),
    );
  }

  Future<void> _captureImage() async {
    try {
      // Take picture using camera controller
      final XFile picture = await cameraController!.takePicture();
      
      // Save to device gallery
      await Gal.putImage(picture.path);
      
      // Small delay to ensure file is saved
      await Future.delayed(const Duration(milliseconds: 300));

      // Update state with new image
      setState(() {
        _capturedImagePath = picture.path;
        _capturedImages.add(picture.path); // Add to images list
      });
    } catch (e) {
      // Handle errors (could show a snackbar in production)
      debugPrint('Error capturing image: $e');
    }
  }

  Future<void> _setupCameraController() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        debugPrint('No cameras found');
        return;
      }

      // Initialize with back camera (typically last in list)
      final cameraController = CameraController(
        cameras.last,
        ResolutionPreset.medium, // Better quality than low
      );

      // Initialize controller
      await cameraController.initialize();

      // Only update state if widget is still mounted
      if (!mounted) return;

      setState(() {
        this.cameraController = cameraController;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }
}