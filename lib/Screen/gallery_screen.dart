import 'package:flutter/material.dart';
import 'dart:io';
import 'full_screen_image.dart'; // Import for the FullScreenImage widget

class GalleryScreen extends StatelessWidget {
  final List<String> images;

  const GalleryScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                    imagePath: images[index],
                  ),
                ),
              );
            },
            child: Image.file(
              File(images[index]),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}