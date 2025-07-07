import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/LoginController.dart';
import 'package:terra_brain/presentation/controllers/best_seller_list_controller.dart';
import 'package:terra_brain/presentation/controllers/edit_profile_controller.dart';
import 'package:terra_brain/presentation/controllers/favorites_controller.dart';
import 'package:terra_brain/presentation/controllers/gps_controller.dart';
import 'package:terra_brain/presentation/controllers/profile_controller.dart';
import 'package:terra_brain/presentation/controllers/register_controller.dart';
import 'package:terra_brain/presentation/controllers/setting_controller.dart';
import 'package:terra_brain/presentation/controllers/story_controller.dart';

import '../controllers/edit_story_controller.dart';
import '../controllers/home_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {}
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}

class APIBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BestSellerListController>(
      () => BestSellerListController(),
    );
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(
      () => RegistrationController(),
    );
  }
}

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(
      () => SettingController(),
    );
  }
}

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(),
    );
  }
}

class SensorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}

class GpsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GpsController>(
      () => GpsController(),
    );
  }
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(),
    );
  }
}

class StoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryController>(
      () => StoryController(),
    );
  }
}

class EditStoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditStoryController>(
          () => EditStoryController(),
    );
  }
}

