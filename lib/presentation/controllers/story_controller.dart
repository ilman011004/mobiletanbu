import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final dateFormat = DateFormat('dd-MM-yyyy');

  // Data Story
  var storyId = ''.obs;
  var title = ''.obs;
  var content = ''.obs;
  var author = ''.obs;
  var date = ''.obs;
  var imagePath = ''.obs;
  var category = ''.obs;
  var favorite = 0.obs;

  // Profil penulis
  var writerId = ''.obs;
  var writerName = ''.obs;
  var writerUsername = ''.obs;
  var writerImage = ''.obs;
  var writerFollower = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Menggunakan ever untuk memantau perubahan pada storyId

    // fetchStory();
    ever(storyId, (String id) {
      if (kDebugMode) {
        print("Story ID has changed to: $id");
      } // Log perubahan storyId
      if (id.isNotEmpty) {
        fetchStory();
      } else {
        if (kDebugMode) {
          print("Story ID is empty, fetch not triggered.");
        }
      }
    });
  }

  // Mengubah ID cerita yang akan diambil
  void setStoryId(String id) {
    if (kDebugMode) {
      print("Setting storyId to: $id");
    } // Log ketika ID cerita diubah
    storyId.value = id;
    if (kDebugMode) {
      print("storyId.value set to: ${storyId.value}");
    }
  }

  // Mengambil data cerita dari Firestore
  void fetchStory() async {
    try {
      if (storyId.value.isEmpty) {
        if (kDebugMode) {
          print("Data tidak ditemukan karena storyId kosong");
        }
        return; // Menghindari query Firestore jika ID kosong
      }

      if (kDebugMode) {
        print("Fetching story with ID: ${storyId.value}");
      }

      DocumentSnapshot<Map<String, dynamic>> document =
          await _firestore.collection('stories').doc(storyId.value).get();
      if (kDebugMode) {
        print("Fetched story document: ${document.data()}");
      }

      if (document.exists) {
        var storyData = document.data()!;
        title.value = storyData['title'] ?? '';
        content.value = storyData['content'] ?? '';
        author.value = storyData['author'] ?? '';
        date.value = storyData['createdAt'] != null
            ? dateFormat.format(DateTime.parse(storyData['createdAt']))
            : '';
        imagePath.value = storyData['imageUrl'] ?? '';
        category.value = storyData['category'] ?? '';
        favorite.value = storyData['favorite'] ?? 0;

        if (kDebugMode) {
          print("Story data loaded: $storyData");
        }

        // Mengambil writerId dari data cerita dan mengambil informasi penulis
        writerId.value = storyData['writerId'];
        fetchWriter(); // Fetch data penulis
      } else {
        print("Data tidak ditemukan untuk storyId: ${storyId.value}");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching story: $e');
      }
    }
  }

  // Mengambil data profil penulis dari Firestore
  void fetchWriter() async {
    try {
      if (writerId.value.isEmpty) {
        print("Writer ID is empty, fetch skipped.");
        return;
      }

      print("Fetching writer with ID: ${writerId.value}");

      DocumentSnapshot<Map<String, dynamic>> writerDocument =
          await _firestore.collection('users').doc(writerId.value).get();
      print("Fetched writer document: ${writerDocument.data()}");

      if (writerDocument.exists) {
        var writerData = writerDocument.data()!;
        writerName.value = writerData['name'];
        writerUsername.value = writerData['username'] ?? '';
        writerImage.value = writerData['imagesURL'] ?? '';
        writerFollower.value = writerData['follower'] ?? 0;

        print("Writer data loaded: $writerData");
      } else {
        print("Writer data not found for writerId: ${writerId.value}");
      }
    } catch (e) {
      print('Error fetching writer: $e');
    }
  }


}
