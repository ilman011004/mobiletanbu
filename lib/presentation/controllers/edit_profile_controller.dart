import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:terra_brain/presentation/routes/app_pages.dart';

class EditProfileController extends GetxController {
  // data yang diupdate
  final nama = ''.obs;
  final username = ''.obs;
  final birthDate = Rx<DateTime?>(null);
  final imagesURL = ''.obs;
  final alamat = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final pronouns = ''.obs;
  late String userID;

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // print("Tidak ada status autentikasi");
      return;
    }

    userID = currentUser.uid;
    // print("user Id: $userID");

    Map<String, dynamic>? userData = await getDataFirestore(userID);
    // print(userData);

    if (userData != null) {
      nama.value = userData['name'] ?? '';
      username.value = userData['username'] ?? '';
      imagesURL.value = userData['imagesURL'] ?? '';
      alamat.value = userData['address'] ?? "";
      latitude.value = (userData['latitude'] != null)
          ? (userData['latitude'] is double
              ? userData['latitude']
              : double.tryParse(userData['latitude'].toString()) ?? 0.0)
          : 0.0;

      longitude.value = (userData['longitude'] != null)
          ? (userData['longitude'] is double
              ? userData['longitude']
              : double.tryParse(userData['longitude'].toString()) ?? 0.0)
          : 0.0;

      birthDate.value = _parseDate(userData['birthDate']);
    } else {
      // print("Data user tidak ditemukan di Firestore");
    }
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        // print("Error parsing date: $e");
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDataFirestore(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> document =
          await _firestore.collection('users').doc(userId).get();
      if (document.exists) {
        // print(document.data());
        return document.data()!;
      } else {
        // print("Data tidak ditemukan dari id: $userId");
        return null;
      }
    } catch (e) {
      // print("Error fetching data: $e");
      return null;
    }
  }

  Future<void> pilihLokasi() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi: $e');
      // print("error: $e");
    }
  }

  Future<void> pilihGambar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Temporarily update the image path to preview it in the app
        imagesURL.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: $e');
    }
  }

  Future<void> simpanProfil() async {
    try {
      String? newImageUrl;

      // If a new image was selected (local path)
      if (imagesURL.value.isNotEmpty && !imagesURL.value.startsWith('http')) {
        // Ensure the file exists before uploading
        final file = File(imagesURL.value);
        if (!file.existsSync()) {
          Get.snackbar('Error', 'File gambar tidak ditemukan di perangkat');
          return;
        }

        // Reference to the Firebase Storage location
        final ref =
        _storage.ref('profile_images/${_auth.currentUser!.uid}.jpg');

        // Upload the new image
        await ref.putFile(file);
        newImageUrl = await ref.getDownloadURL();

        // Delete the old image from Firebase Storage (if different from the new one)
        if (imagesURL.value != newImageUrl) {
          try {
            final oldImageRef = _storage.refFromURL(imagesURL.value);
            await oldImageRef.delete();
          } catch (e) {
            // Ignore errors if the old image doesn't exist
          }
        }

        // Update the imagesURL value with the Firebase URL
        imagesURL.value = newImageUrl;
      } else {
        // If no new image was selected, keep the existing URL
        newImageUrl = imagesURL.value;
      }

      // Prepare data to update in Firestore
      final data = {
        'name': nama.value,
        'username': username.value,
        'birthDate': birthDate.value?.toIso8601String(),
        'address': alamat.value,
        'latitude': latitude.value,
        'longitude': longitude.value,
        'imagesURL': newImageUrl, // Always update with the latest URL
      };

      // Save the updated data to Firestore
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update(data);

      // Show success notification
      Get.snackbar('Sukses', 'Profil berhasil diperbarui');
      Get.offNamed(Routes.PROFILE);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profil: $e',
          backgroundColor: Colors.red);
    }
  }


  Future<void> ubahPassword(String passwordBaru) async {
    try {
      await _auth.currentUser!.updatePassword(passwordBaru);
      Get.snackbar('Sukses', 'Password berhasil diubah');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah password: $e');
    }
  }

  Future<void> hapusAkun() async {
    try {
      final uid = _auth.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      final ref = _storage.ref('profile_images/$uid.jpg');
      try {
        await ref.delete();
      } catch (e) {
        // next
      }

      await _auth.currentUser!.delete();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus akun: $e');
    }
  }
}
