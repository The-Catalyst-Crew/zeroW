import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:zerow/common/widgets/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch posts ordered by timestamp, limited to 10
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      // Convert documents to list of maps
      final posts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the map
        return data;
      }).toList();

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load posts: ${e.toString()}';
      });
      print('Post fetching error: $e');
    }
  }

  // Local base64 image decoding method
  Widget _decodeBase64Image(String base64Image, {BoxFit fit = BoxFit.cover}) {
    try {
      // Decode base64 to bytes
      final decodedBytes = base64Decode(base64Image);

      // Create image from memory
      return Image.memory(
        decodedBytes,
        fit: fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('Image decoding error: $error');
          return Icon(
            Icons.broken_image,
            color: Colors.red,
            size: 60,
          );
        },
      );
    } catch (e) {
      print('Base64 decoding error: $e');
      return Icon(
        Icons.error,
        color: Colors.red,
        size: 60,
      );
    }
  }

  // Open location in maps
  void _openLocationInMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          "zeroW",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onBackground,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onBackground),
            onPressed: _fetchPosts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPosts,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _posts.isEmpty
                  ? Center(
                      child: Text(
                        'No posts yet',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : AnimationLimiter(
                      child: PageView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.surfaceVariant
                                            .withOpacity(0.7),
                                        colorScheme.surfaceVariant
                                            .withOpacity(0.5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Post Header
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: colorScheme
                                                      .primaryContainer,
                                                  backgroundImage:
                                                      post['userProfileImage'] !=
                                                              null
                                                          ? NetworkImage(post[
                                                              'userProfileImage'])
                                                          : null,
                                                  child:
                                                      post['userProfileImage'] ==
                                                              null
                                                          ? Icon(
                                                              Icons.person,
                                                              color: colorScheme
                                                                  .onPrimaryContainer,
                                                              size: 22,
                                                            )
                                                          : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      post['username'] ??
                                                          'Anonymous',
                                                      style: theme
                                                          .textTheme.titleMedium
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: post['status'] ==
                                                                "Cleared"
                                                            ? Colors
                                                                .green.shade200
                                                            : Colors
                                                                .red.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        post['status'] ??
                                                            'Not Cleared',
                                                        style: theme.textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Post Title and Context
                                        Text(
                                          post['title'] ?? 'No Title',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          post['context'] ?? 'No Context',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Post Image
                                        Expanded(
                                          child: post['imageData'] != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: _decodeBase64Image(
                                                    post['imageData'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Center(
                                                  child: Text(
                                                    "No Image Available",
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      color: colorScheme
                                                          .onSurface
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Location
                                        if (post['location'] != null)
                                          GestureDetector(
                                            onTap: () => _openLocationInMaps(
                                              post['location']['latitude'],
                                              post['location']['longitude'],
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: colorScheme.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'View Location',
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: colorScheme.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPosts,
        child: Icon(Icons.refresh),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
