import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import '../../controllers/profile_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  Future<void> _showCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak secara permanen.';
      }

      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}');

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.inAppWebView,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: AnimationLimiter(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: const BackButton(
                      color: Colors.white
                  ),
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Profil', style: TextStyle(color: Colors.white)),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.deepPurple.shade700, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => Get.toNamed(Routes.SETTING),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          _buildStatistics(),
                          const SizedBox(height: 24),
                          _buildLocationButton(),
                          const SizedBox(height: 24),
                          _buildPublishedStories(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Obx(() => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: controller.imagesURL.isNotEmpty
                ? NetworkImage(controller.imagesURL.value)
                : controller.imagesURL.isEmpty &&
                controller.imagesURL.value.isNotEmpty
                ? FileImage(File(controller.imagesURL.value))
            as ImageProvider
                : const AssetImage(
                'assets/images/default_avatar.png'),
          ),
        )),
        const SizedBox(height: 16),
        Obx(() => Text(
          controller.name.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )),
        Obx(() => Text(
          '@${controller.username.value}',
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        )),
      ],
    );
  }

  Widget _buildStatistics() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Koin', controller.coins.value.toString()),
        _buildStatItem('Pengikut', controller.followers.value.toString()),
        _buildStatItem('Publikasi', controller.length.value.toString()),
        _buildStatItem('Favorite', '0'),
        _buildStatItem('Mengikuti', controller.following.value.toString()),
      ],
    ));
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[300], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return ElevatedButton.icon(
      onPressed: _showCurrentLocation,
      icon: Icon(Icons.location_on, color: Colors.deepPurple[900]),
      label: Text('Tampilkan Lokasi Saat Ini', style: TextStyle(color: Colors.deepPurple[900])),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildPublishedStories() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cerita yang Dipublikasikan',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stories')
              .where('writerId', isEqualTo: controller.userID.value)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            if (snapshot.hasError) {
              return const Text(
                'Terjadi kesalahan saat memuat cerita.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text(
                'Tidak ada cerita yang dipublikasikan.',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              );
            }

            final stories = snapshot.data!.docs;

            // Update the stories count in the controller
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.length.value = stories.length;
            });

            return ListView.builder(
              shrinkWrap: true, // Allow ListView to adjust its height
              physics:
              const NeverScrollableScrollPhysics(), // Disable scrolling within the list
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                final storyId = story.id; // Get the story ID for deletion
                final title = story['title'] ?? 'Judul Tidak Tersedia';
                final createdAt = story['createdAt'] ?? '';
                final imagePath = story['imageUrl'] ?? '';

                String formattedDate = '';

                if (createdAt.isNotEmpty) {
                  try {
                    // Parse the ISO 8601 string to a DateTime object
                    DateTime dateTime = DateTime.parse(createdAt);

                    // Format the DateTime to "Day Month Year" (e.g., "23 December 2024")
                    formattedDate =
                        DateFormat('dd MMMM yyyy').format(dateTime);
                  } catch (e) {
                    formattedDate = 'Invalid Date'; // Fallback if parsing fails
                  }
                }

                return Card(
                  color: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: imagePath.isNotEmpty
                        ? Image.network(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.book, color: Colors.deepPurple[300]),
                    title: Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Dibuat: $formattedDate',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          onPressed: () =>
                              _confirmDelete(context, storyId), // Pass context
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey[400]),
                      ],
                    ),
                    onTap: () {
                      // Handle navigation to story detail
                      Get.toNamed(Routes.PROFILE_READ,
                          arguments: {'id': storyId});
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    ));
  }


  Future<void> _confirmDelete(BuildContext context, String storyId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cerita'),
        content: const Text('Apakah Anda yakin ingin menghapus cerita ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteStory(storyId);
    }
  }

  Future<void> _deleteStory(String storyId) async {
    try {
      // Reference to the Firestore document
      DocumentSnapshot storyDoc = await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyId)
          .get();

      if (storyDoc.exists) {
        // Extract the image URL from the document
        String? imageUrl = storyDoc['imageUrl'] ?? '';

        // If there's an image URL, delete the image from Firebase Storage
        if (imageUrl!.isNotEmpty) {
          try {
            final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
            await storageRef.delete();
            print('Image deleted successfully');
          } catch (e) {
            print('Error deleting image: $e');
          }
        }

        // Delete the Firestore document
        await FirebaseFirestore.instance.collection('stories').doc(storyId).delete();
        print('Story deleted successfully');

        // Refresh the stories list
        final updatedStories = await _fetchStories();
        controller.length.value = updatedStories.length; // Update the count
        Get.snackbar(
          'Success',
          'Cerita berhasil dihapus.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('Story does not exist');
      }
    } catch (e) {
      print('Error deleting story: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus cerita.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }






  Future<List<QueryDocumentSnapshot>> _fetchStories() async {
    try {
      // Fetch the stories from Firestore where 'writerId' matches the current user's ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('writerId', isEqualTo: controller.userID.value)
          .get();

      return querySnapshot.docs; // Return the list of documents
    } catch (e) {
      print('Error fetching stories: $e');
      return []; // Return an empty list on error
    }
  }
}