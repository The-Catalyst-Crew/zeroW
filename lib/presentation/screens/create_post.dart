import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  File? _imageFile;
  Position? _currentLocation;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permissions are permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = position;
      });

      _showSuccessSnackBar('Location captured successfully');
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
    }
  }

  Future<void> _createPost() async {
    // Validate inputs
    if (_imageFile == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showErrorSnackBar('Please enter a post title');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('${DateTime.now().toIso8601String()}_${user.uid}');

      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // Prepare post data
      final postData = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'title': _titleController.text,
        'context': _contextController.text,
        'imageUrl': imageUrl,
        'location': _currentLocation != null
            ? {
                'latitude': _currentLocation!.latitude,
                'longitude': _currentLocation!.longitude
              }
            : null,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Not Cleared', // Default status
      };

      // Save to Firestore
      await FirebaseFirestore.instance.collection('posts').add(postData);

      // Reset and navigate
      _showSuccessSnackBar('Post created successfully!');
      context.go('/home');
    } catch (e) {
      _showErrorSnackBar('Post creation failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade300,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Create Post",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onBackground,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.surfaceVariant.withOpacity(0.7),
                          colorScheme.surfaceVariant.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.onSurface.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Selection
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_imageFile!,
                                        fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          size: 50, color: colorScheme.primary),
                                      Text('Tap to select image',
                                          style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location Button
                        ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: Icon(Icons.location_on,
                              color: _currentLocation != null
                                  ? Colors.red
                                  : colorScheme.onPrimary),
                          label: Text(_currentLocation != null
                              ? 'Location Captured'
                              : 'Add Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceVariant,
                            foregroundColor: colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title Input
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Post Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Context Input
                        TextField(
                          controller: _contextController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Post Context',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Create Post Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: colorScheme.onPrimary)
                              : const Text('Create Post'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    super.dispose();
  }
}
