import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:terra_brain/presentation/controllers/favorites_controller.dart';
import 'package:video_player/video_player.dart';


class HomeController extends GetxController {
  final favoritesController = Get.find<FavoritesController>();
  final box = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var selectedImagePath = ''.obs;
  var isImageLoading = false.obs;

  var selectedVideoPath = ''.obs;
  var isVideoPlaying = false.obs;
  VideoPlayerController? videoPlayerController;

  var stories = <Map<String, dynamic>>[].obs;
  var filteredStories = <Map<String, dynamic>>[].obs;
  var selectedCategory = ''.obs;
  var searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'All'; // Default to "All"
    _getStories();
    searchQuery.listen((_) => _applyFilter());
  }


  @override
  void onClose() {
    videoPlayerController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _getStories() {
    try {
      _firestore.collection('stories').snapshots().listen((snapshot) {
        final List<Map<String, dynamic>> updatedStories = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'title': doc['title'],
            'image': doc['imageUrl'],
            'author': doc['author'],
            'category': doc['category'],
          };
        }).toList();

        if (!const ListEquality().equals(stories, updatedStories)) {
          stories.value = updatedStories;
          _applyFilter();
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  void _applyFilter() {
    filteredStories.value = stories.where((story) {
      final matchesCategory = selectedCategory.value == 'All' ||
          selectedCategory.value.isEmpty ||
          story['category'] == selectedCategory.value;
      final matchesSearch = story['title']
          .toString()
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

}


