import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var username = ''.obs;
  var password = ''.obs;
  var birthDate = ''.obs;
  var pronouns = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController birthDateController = TextEditingController();

  Future<void> register() async {
    if (name.value.isEmpty ||
        email.value.isEmpty ||
        password.value.isEmpty ||
        username.value.isEmpty ||
        birthDate.value.isEmpty) {
      throw Exception('Please fill in all fields');
    }
    bool usernameExists = await _checkUsernameExists(username.value);
    if (usernameExists) {
      throw Exception('Username is already taken');
    }
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': name.value,
        'email': email.value,
        'username': username.value,
        'birthDate': birthDate.value,
        'pronouns': pronouns.value,
        "coins": 0,
        "followers": 0,
        "following": 0,
      });

      Get.snackbar('Success', 'User registered successfully');
      Get.toNamed("/login");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return snapshot.docs.isNotEmpty; 
    } catch (e) {
      if (kDebugMode) {
        print("Error checking username: $e");
      }
      return false;
    }
  }

  @override
  void onClose() {
    birthDateController.dispose();
    super.onClose();
  }
}
