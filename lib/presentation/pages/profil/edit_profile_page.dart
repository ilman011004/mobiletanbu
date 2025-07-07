import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:terra_brain/presentation/controllers/edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final namaController = TextEditingController();
    final usernameController = TextEditingController();
    final alamatController = TextEditingController();

    // Inisialisasi controller dengan nilai dari RxString
    namaController.text = controller.nama.value;
    usernameController.text = controller.username.value;
    alamatController.text = controller.alamat.value;

    // Monitor perubahan di RxString dan update TextField
    controller.nama.listen((value) {
      namaController.text = value;
    });

    controller.username.listen((value) {
      usernameController.text = value;
    });

    controller.alamat.listen((value) {
      alamatController.text = value;
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Theme(
        data: ThemeData.dark(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: Obx(
                  () => CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: controller.imagesURL.isNotEmpty
                        ? NetworkImage(controller.imagesURL.value)
                        : controller.imagesURL.isEmpty &&
                                controller.imagesURL.value.isNotEmpty
                            ? FileImage(File(controller.imagesURL.value))
                                as ImageProvider
                            : const AssetImage(
                                'assets/images/default_avatar.png'),
                    child: controller.imagesURL.isEmpty
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (value) => controller.nama.value = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (value) => controller.username.value = value,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    controller.birthDate.value != null
                        ? 'Tanggal Lahir: ${DateFormat('dd/MM/yyyy').format(controller.birthDate.value!)}'
                        : 'Tanggal Lahir: Belum dipilih',
                    style: const TextStyle(color: Colors.white),
                  )),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.dark(),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.birthDate.value = picked;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
                child: const Text(
                  'Pilih Tanggal Lahir',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (value) => controller.alamat.value = value,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    'Lokasi: ${controller.latitude.value}, ${controller.longitude.value}',
                    style: const TextStyle(color: Colors.white),
                  )),
              ElevatedButton(
                onPressed: controller.pilihLokasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
                child: const Text(
                  'Pilih Lokasi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text(
                        'Ubah Password',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                        onSubmitted: (value) {
                          controller.ubahPassword(value);
                          Get.back();
                        },
                      ),
                      backgroundColor: Colors.grey[900],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
                child: const Text(
                  'Ubah Password',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.simpanProfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
                child: const Text(
                  'Simpan Profil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text(
                        'Hapus Akun',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Apakah Anda yakin ingin menghapus akun?',
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.hapusAkun();
                          },
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      backgroundColor: Colors.grey[900],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Hapus Akun',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Pilih Sumber Gambar',
            style:
                TextStyle(color: Colors.white), // Set warna teks menjadi putih
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(
                        Icons.photo_library, // Ikon untuk Galeri
                        color: Colors.white, // Warna ikon putih
                      ),
                      SizedBox(width: 8), // Spasi antara ikon dan teks
                      Text(
                        'Galeri',
                        style:
                            TextStyle(color: Colors.white), // Warna teks putih
                      ),
                    ],
                  ),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(
                        Icons.camera_alt, // Ikon untuk Kamera
                        color: Colors.white, // Warna ikon putih
                      ),
                      SizedBox(width: 8), // Spasi antara ikon dan teks
                      Text(
                        'Kamera',
                        style:
                            TextStyle(color: Colors.white), // Warna teks putih
                      ),
                    ],
                  ),
                  onTap: () {
                    _getImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey[900],
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      controller.imagesURL.value = pickedFile.path;
    }
  }
}
