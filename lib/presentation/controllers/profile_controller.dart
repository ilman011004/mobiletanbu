import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final logger = Logger();

  var userID = ''.obs;
  var name = ''.obs;
  var username = ''.obs;
  var imagesURL = ''.obs;
  var coins = 0.obs;
  var followers = 0.obs;
  var following = 0.obs;
  var stories = <Map<String, dynamic>>[].obs;

  var length = 0.obs;

  static const String defaultProfileImage = 'assets/images/default_profile.jpeg';

  @override
  void onInit() {
    super.onInit();
    _initializeProfileData();
  }

  Future<void> _initializeProfileData() async {
    try {
      await _getUserData();
      await fetchStories();
    } catch (e) {
      logger.e("Error initializing profile data: $e");
    }
  }

  Future<void> _getUserData() async {
    try {
      String? localUserId = await getLocalData('userId');
      if (localUserId == null) {
        logger.e("No user ID found in SharedPreferences");
        return;
      }

      userID.value = localUserId;
      logger.d("User ID retrieved: $userID");

      Map<String, dynamic>? userData = await getDataFirestore(localUserId);
      if (userData != null) {
        name.value = userData['name'] ?? '';
        username.value = userData['username'] ?? '';
        imagesURL.value = userData['imagesURL']?.isNotEmpty ?? false
            ? userData['imagesURL']
            : defaultProfileImage;
        coins.value = userData['coins'] ?? 0;
        followers.value = userData['followers'] ?? 0;
        following.value = userData['following'] ?? 0;

        logger.d("User data loaded: $userData");
      } else {
        logger.w("User data not found for ID: $localUserId");
      }
    } catch (e) {
      logger.e("Error fetching user data: $e");
    }
  }

  Future<String?> getLocalData(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      logger.e("Error accessing SharedPreferences: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDataFirestore(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> document =
      await _firestore.collection('users').doc(userId).get();
      if (document.exists) {
        logger.d("Fetched Firestore data: ${document.data()}");
        return document.data();
      } else {
        logger.w("No data found for user ID: $userId");
        return null;
      }
    } catch (e) {
      logger.e("Error fetching data from Firestore: $e");
      return null;
    }
  }

  Future<void> fetchStories() async {
    try {
      final querySnapshot = await _firestore
          .collection('stories')
          .where('writerId', isEqualTo: userID.value)
          .get();

      stories.value = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      length.value = stories.length; // Update length for UI
      logger.d("Fetched ${stories.length} stories for user ID: ${userID.value}");
    } catch (e) {
      logger.e('Error fetching stories: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> storyDoc =
      await _firestore.collection('stories').doc(storyId).get();

      if (storyDoc.exists) {
        final imageUrl = storyDoc['imageUrl'] ?? '';

        if (imageUrl.isNotEmpty) {
          final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
          logger.d("Deleted image at $imageUrl");
        }

        await _firestore.collection('stories').doc(storyId).delete();
        logger.d("Story with ID $storyId deleted successfully");

        await fetchStories(); // Refresh stories after deletion
      }
    } catch (e) {
      logger.e("Error deleting story: $e");
    }
  }
}
