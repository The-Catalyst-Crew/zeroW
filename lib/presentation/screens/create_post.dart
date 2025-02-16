import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

      if (!mounted) return;
      setState(() {
        _currentLocation = position;
      });

      _showSuccessSnackBar('Location captured successfully');
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
    }
  }

  Future<String?> _processImage(File imageFile) async {
    try {
      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.path}_compressed.jpg',
        quality: 50,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedFile == null) {
        _showErrorSnackBar('Image compression failed');
        return null;
      }

      // Read compressed image bytes and encode to base64
      final bytes = await compressedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Size validation
      const maxBase64Size = 1 * 1024 * 1024; // 1MB limit
      if (base64Image.length > maxBase64Size) {
        _showErrorSnackBar('Image is too large after compression');
        return null;
      }

      return base64Image;
    } catch (e) {
      _showErrorSnackBar('Image processing error: $e');
      return null;
    }
  }

  Future<void> _createPost() async {
    if (_titleController.text.isEmpty || _contextController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      // Fetch user details to get username
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final username = userData?['anonymousPosting']
          ? 'Anonymous'
          : userData?['name'] ?? 'Anonymous';

      String? base64Image;
      if (_imageFile != null) {
        base64Image = await _processImage(_imageFile!);
      }

      final postData = {
        'title': _titleController.text,
        'context': _contextController.text,
        'imageData': base64Image,
        'userId': user.uid,
        'username': username,
        'location': _currentLocation != null
            ? {
                'latitude': _currentLocation!.latitude,
                'longitude': _currentLocation!.longitude,
              }
            : null,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Not Cleared',
      };

      // Create post
      await FirebaseFirestore.instance.collection('posts').add(postData);

      // Update user points
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'points': FieldValue.increment(20),
      });

      if (!mounted) return;
      _showSuccessSnackBar('Post created successfully! +20 points');
      context.go('/home');
    } catch (e) {
      _showErrorSnackBar('Post creation failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  static Widget decodeBase64Image(String base64Image,
      {BoxFit fit = BoxFit.cover}) {
    try {
      // Decode base64 to Uint8List
      final decodedBytes = base64Decode(base64Image);

      // Create image from memory
      return Image.memory(
        decodedBytes,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('Image decoding error: $error');
          return Icon(Icons.broken_image, color: Colors.red);
        },
      );
    } catch (e) {
      print('Base64 decoding error: $e');
      return Icon(Icons.error, color: Colors.red);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade300,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade300,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/home');
            },
          ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt,
                                            size: 50,
                                            color: colorScheme.primary),
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
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    super.dispose();
  }
}
