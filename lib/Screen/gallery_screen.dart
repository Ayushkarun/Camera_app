import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'full_screen_image.dart';

class GalleryScreen extends StatefulWidget {
  final List<String> images;

  const GalleryScreen({super.key, required this.images});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showFileInfoDialog(context, widget.images[0]); // Shows info for first image
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              _showOptionsBottomSheet(context, widget.images[index]);
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                    imagePath: widget.images[index],
                  ),
                ),
              );
            },
            child: Image.file(
              File(widget.images[index]),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, String imagePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteImage(context, imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text('File Info', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showFileInfoDialog(context, imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _shareImage(imagePath);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteImage(BuildContext context, String imagePath) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      try {
        final file = File(imagePath);
        await file.delete();
        
        setState(() {
          widget.images.remove(imagePath);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }

  void _showFileInfoDialog(BuildContext context, String imagePath) {
    final file = File(imagePath);
    final fileSize = file.lengthSync() / (1024 * 1024); // Size in MB
    final lastModified = file.lastModifiedSync();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('File Info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${file.path.split('/').last}', style: const TextStyle(color: Colors.white)),
            Text('Size: ${fileSize.toStringAsFixed(2)} MB', style: const TextStyle(color: Colors.white)),
            Text('Last modified: ${lastModified.toString()}', style: const TextStyle(color: Colors.white)),
            Text('Path: ${file.path}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareImage(String imagePath) async {
    try {
      await Share.shareXFiles([XFile(imagePath)], text: 'Check out this image!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image: $e')),
      );
    }
  }
}