import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteController extends GetxController {
  final RxBool isConnected = false.obs;
  final RxBool isUploading = false.obs;
  var userId = ''.obs;
  var username = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  final GetStorage _storage = GetStorage();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _initializeStorage();
    _monitorConnection();
    _getLocalData();
    _getWriterName();
  }

  Future<String?> _getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? localUserId = prefs.getString('userId');
    if (localUserId == null) {
    } else {
      userId.value = localUserId;
    }
    return localUserId;
  }

  Future<void> _initializeStorage() async {
    await GetStorage.init();
  }

  void _monitorConnection() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        bool isConnectedNow = true;
        isConnected.value = isConnectedNow;
        _showConnectionSnackbar(isConnected.value);
        print("anda kembali online");
        _checkLocalPendingUploads();
      } else {
        bool isConnectedNow = false;
        isConnected.value = isConnectedNow;
        _showConnectionSnackbar(isConnected.value);
        print("anda ofline");
      }
    });
  }

  void _showConnectionSnackbar(bool status) {
    if (status) {
      Get.snackbar(
        "Internet Connected",
        "You are now online.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Internet Disconnected",
        "You are offline.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _checkInitialConnection() async {
    // print("Memeriksa koneksi awal...");
    var result = await _connectivity.checkConnectivity();
    // print("Koneksi awal: $result");
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      // _storage.remove('pending_uploads');

      bool conection = true;
      isConnected.value = conection;
      print("isConnected awal: ${isConnected.value}");
      // _showConnectionSnackbar(isConnected.value);
    } else {
      bool conection = false;
      isConnected.value = conection;
      print("isConnected awal: ${isConnected.value}");
      // _showConnectionSnackbar(isConnected.value);
      // _storage.remove('pending_uploads')
    }
  }

  Future<void> _getWriterName() async {
    if (userId.value.isEmpty) {
      // print("Error: userId kosong");
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId.value).get();
      if (userDoc.exists && userDoc.data() != null) {
        username.value = userDoc['username'] ?? 'Unknown Author';
      } else {
        // print("Error: User tidak ditemukan di Firestore");
      }
    } catch (e) {
      // print('Error saat mengambil username dari Firestore: $e');
    }
  }

  Future<String?> _uploadFileToStorage(File file, String path) async {
    if (!file.existsSync()) {
      print("File tidak ditemukan: ${file.path}");
      return null;
    }

    try {
      if (isConnected.value) {
        final Reference storageRef = FirebaseStorage.instance.ref().child(path);
        final UploadTask uploadTask = storageRef.putFile(file);
        final TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } else {
        Directory dir = await getApplicationDocumentsDirectory();
        String localPath = "${dir.path}/${path.split('/').last}";
        await file.copy(localPath);
        _addToPendingUploads(localPath, path);
        // return null;
      }
    } catch (e) {
      print("Error saat mengunggah file: $e");
      rethrow;
    }
    return null;
  }

  void _addToPendingUploads(String localPath, String firebasePath) {
    try {
      // Ambil data existing, pastikan selalu dalam format List<String>
      List<String> pendingUploads =
          (_storage.read('pending_files') as List<dynamic>? ?? [])
              .cast<String>();

      // Tambahkan data baru, encoded sebagai String JSON
      pendingUploads.add(jsonEncode({
        "localPath": localPath,
        "firebasePath": firebasePath,
      }));

      // Simpan kembali ke GetStorage
      _storage.write('pending_files', pendingUploads);
      print("Disimpan ke pending uploads: $pendingUploads");
    } catch (e) {
      print("Gagal menambahkan ke pending uploads: $e");
    }
  }

  // Save Media Locally and Return File Path
  Future<String> saveFileLocally(File file, String filename) async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/$filename";
      await file.copy(filePath);
      return filePath;
    } catch (e) {
      // print("Error saving file locally: $e");
      rethrow;
    }
  }

  // Upload Data to Firebase Firestore
  Future<void> uploadData({
    required String title,
    required String content,
    required String category,
    File? imageFile,
    File? audioFile,
  }) async {
    try {
      isUploading.value = true;

      // Pastikan username sudah diambil
      if (username.value.isEmpty) {
        await _getWriterName();
      }

      // Paths for Firebase Storage
      String? imageUrl;
      String? audioUrl;

      if (imageFile != null) {
        String imagePath =
            'images/${DateTime.now().millisecondsSinceEpoch}.png';
        imageUrl = await _uploadFileToStorage(imageFile, imagePath);
      }
      if (audioFile != null) {
        String audioPath =
            'audios/${DateTime.now().millisecondsSinceEpoch}.aac';
        audioUrl = await _uploadFileToStorage(audioFile, audioPath);
      }

      String createdAt = DateTime.now().toIso8601String();

      Map<String, dynamic> data = {
        "title": title,
        "content": content,
        "writerId": userId.value,
        "author": username.value,
        "category": category,
        "imageUrl": imageUrl,
        "audioUrl": audioUrl,
        "createdAt": createdAt,
      };
      print("data (upload data): $data");

      if (isConnected.value) {
        await FirebaseFirestore.instance.collection('stories').add(data);
        Get.snackbar("Upload Successful", "Data uploaded to Firestore.",
            backgroundColor: Colors.green, colorText: Colors.white);
        print("Berhasil updload ke firestore (upload data)");
        // Navigator.pushReplacementNamed(context, '/home');
      } else {
        _saveDataLocally(data);
        Get.snackbar("No Internet", "Data saved locally for later upload.",
            backgroundColor: Colors.red, colorText: Colors.white);
        print("Data disimpan di local sementara (upload data)");
        // Get.offNamed('/home');
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to upload data: $e",
          backgroundColor: Get.theme.disabledColor,
          colorText: Get.theme.colorScheme.onError);
      print("gagal mengupluod data(upload data): $e ");
      print("data (upload data): ");
    } finally {
      isUploading.value = false;
    }
  }

  // Save Data Locally
  void _saveDataLocally(Map<String, dynamic> data) {
    if (data.isEmpty) {
      print("Tidak ada data untuk disimpan.");
      return;
    }
    // _storage.remove('pending_uploads');
    // _storage.remove('pending_uploads');

    List<String> pendingUploads =
        (_storage.read('pending_uploads') as List<dynamic>? ?? [])
            .map((item) => item.toString())
            .toList();

    pendingUploads.add(jsonEncode(data));
    print("data yang di pending: $pendingUploads");
    print("_savedatalocaly");
    _storage.write('pending_uploads', pendingUploads);
  }

  // Check and Upload Local Pending Data
  void _checkLocalPendingUploads() async {
    if (isConnected.value) {
      List<String> filesPending =
          (_storage.read('pending_files') as List<dynamic>? ?? [])
              .cast<String>();
      List<String> dataPending =
          (_storage.read('pending_uploads') as List<dynamic>? ?? [])
              .cast<String>();
      if (filesPending.isNotEmpty || dataPending.isNotEmpty) {
        print("Starting upload process for pending files and data...");

        // Handle pending files
        print("Pending files to process: $filesPending");

        List<String> updatedFilesPending = [];
        List<String> finalUPdateData = [];
        String imageURL = "";

        for (var item in filesPending) {
          try {
            Map<String, dynamic> fileData = jsonDecode(item);

            if (fileData.containsKey("localPath") &&
                fileData.containsKey("firebasePath")) {
              String localPath = fileData["localPath"];
              String firebasePath = fileData["firebasePath"];
              File localFile = File(localPath);

              if (localFile.existsSync()) {
                String? downloadUrl =
                    await _uploadFileToStorage(localFile, firebasePath);
                if (downloadUrl != null) {
                  print("File uploaded successfully: $downloadUrl");
                  fileData["downloadUrl"] = downloadUrl;
                  imageURL = downloadUrl;
                  finalUPdateData.add(downloadUrl);
                } else {
                  print("Failed to upload file: $localPath");
                  updatedFilesPending.add(item);
                  print("update file pending: $updatedFilesPending");
                  continue;
                }
              } else {
                print("Local file not found: $localPath");
                updatedFilesPending.add(item);
                continue;
              }
            }
          } catch (e) {
            print("Error processing pending file: $e");
            updatedFilesPending.add(item);
          }
        }

        // Update pending files in local storage
        print("final update data file: $finalUPdateData");
        print("data files pending before update: $updatedFilesPending");
        if (updatedFilesPending.isNotEmpty) {
          _storage.write('pending_files', updatedFilesPending);
          print("Pending files updated: $updatedFilesPending");
        } else {
          _storage.remove('pending_files');
          print("All pending files successfully processed and uploaded.");
        }

        // Handle pending data
        print("imageurl after get url: $imageURL");

        print("Pending data to process: $dataPending");

        List<String> updatedDataPending = [];

        for (var item in dataPending) {
          try {
            Map<String, dynamic> data = jsonDecode(item);
            print("data pending: $data");

            if (data.containsKey('imageUrl') && data['imageUrl'] == null) {
              String imageUrl = imageURL;

              data['imageUrl'] = imageUrl;
              data.remove('localImagePath');
              print("Image uploaded and URL updated: $imageUrl");
                        }

            if (data.containsKey('audioUrl') &&
                data['audioUrl'] == null &&
                data.containsKey('localAudioPath')) {
              String localAudioPath = data['localAudioPath'];
              File localAudioFile = File(localAudioPath);

              if (localAudioFile.existsSync()) {
                String audioPath =
                    'audios/${DateTime.now().millisecondsSinceEpoch}.aac';
                String? audioUrl =
                    await _uploadFileToStorage(localAudioFile, audioPath);

                if (audioUrl != null) {
                  data['audioUrl'] = audioUrl;
                  data.remove('localAudioPath');
                  print("Audio uploaded and URL updated: $audioUrl");
                } else {
                  print("Failed to upload audio file: $localAudioPath");
                  updatedDataPending.add(item);
                  continue;
                }
              }
            }

            // Save updated data to Firestore
            if (data.containsKey('title')) {
              await FirebaseFirestore.instance.collection('stories').add(data);
              print("Data successfully uploaded to Firestore: $data");
            } else {
              print("Incomplete data, skipping upload to Firestore: $data");
              updatedDataPending.add(jsonEncode(data));
            }
          } catch (e) {
            print("Error processing pending data: $e");
            updatedDataPending.add(item);
          }
        }

        // Update the pending data in local storage
        if (updatedDataPending.isNotEmpty) {
          _storage.write('pending_uploads', updatedDataPending);
          print("Pending data updated: $updatedDataPending");
        } else {
          _storage.remove('pending_uploads');
          print("All pending data successfully processed and uploaded.");
          Get.snackbar("Succes", "Semua pending data telah di upload");
        }
      }
    } else {
      print(
          "No internet connection. Pending uploads will be processed when back online.");
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
