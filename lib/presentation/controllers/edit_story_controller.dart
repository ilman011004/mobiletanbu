import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EditStoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    ever(storyId, (String id) {
      if (kDebugMode) {
        print("Story ID has changed to: $id");
      }
      if (id.isNotEmpty) {
        fetchStory();
      }
    });
  }

  void setStoryId(String id) {
    storyId.value = id;
  }

  Future<void> fetchStory() async {
    try {
      if (storyId.value.isEmpty) return;

      DocumentSnapshot<Map<String, dynamic>> document =
      await _firestore.collection('stories').doc(storyId.value).get();

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

        writerId.value = storyData['writerId'];
        fetchWriter();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching story: $e');
      }
    }
  }

  Future<void> fetchWriter() async {
    try {
      if (writerId.value.isEmpty) return;

      DocumentSnapshot<Map<String, dynamic>> writerDocument =
      await _firestore.collection('users').doc(writerId.value).get();

      if (writerDocument.exists) {
        var writerData = writerDocument.data()!;
        writerName.value = writerData['name'];
        writerUsername.value = writerData['username'] ?? '';
        writerImage.value = writerData['imagesURL'] ?? '';
        writerFollower.value = writerData['follower'] ?? 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching writer: $e');
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String imageUrl = await uploadImageToStorage(pickedFile);
        imagePath.value = imageUrl;
        if (kDebugMode) {
          print("Image uploaded successfully: $imageUrl");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }

  Future<String> uploadImageToStorage(XFile image) async {
    try {
      String fileName = 'stories/${storyId.value}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      TaskSnapshot uploadTask = await ref.putFile(File(image.path));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return '';
    }
  }

  Future<void> editStory({
    required String newTitle,
    required String newContent,
    String? newImageUrl,
  }) async {
    try {
      if (storyId.value.isEmpty) return;

      Map<String, dynamic> updatedData = {
        'title': newTitle,
        'content': newContent,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        updatedData['imageUrl'] = newImageUrl;
      }

      await _firestore.collection('stories').doc(storyId.value).update(updatedData);

      title.value = newTitle;
      content.value = newContent;
      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        imagePath.value = newImageUrl;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating story: $e');
      }
    }
  }
}
