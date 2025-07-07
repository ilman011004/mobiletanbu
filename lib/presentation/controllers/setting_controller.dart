import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout() async {
    try {
      await _auth.signOut();
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      Get.offAllNamed(Routes.LOGIN);

      Get.snackbar(
        'Success', 
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> openGoogleMaps(double latitude, double longitude) async {
    final url = "https://www.google.com/maps?q=$latitude,$longitude";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw "Tidak dapat membuka Google Maps.";
    }
  }
}
