import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Map<String, dynamic>> favoriteItems =
      <Map<String, dynamic>>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var id = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToFavorites();
  }

  CollectionReference get _userFavorites {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }
    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  void _listenToFavorites() {
    _userFavorites.snapshots().listen((snapshot) {
      favoriteItems.value = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    });
  }

  Future<void> addFavorite(String id, String title, String author) async {
    try {
      await _userFavorites.doc(id).set({
        'title': title,
        'author': author,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('stories').doc(id).update({
        'favorite': FieldValue.increment(1),
      });
      // Get.snackbar("Success", "$title added to Favorites",
      //     backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      // Get.snackbar("Error", "Failed to add favorite: $e",
      //     backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteFavorite(String id) async {
    try {
      await _userFavorites.doc(id).delete();
      await _firestore.collection('stories').doc(id).update({
        'favorite': FieldValue.increment(-1),
      });
      // Get.snackbar("Success", "Favorite removed",
      //     backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      // Get.snackbar("Error", "Failed to remove favorite: $e",
      //     backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> removeStory(String id) async {
    await deleteFavorite(id);
  }
}
