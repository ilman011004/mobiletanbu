import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/favorites_controller.dart';
import 'package:terra_brain/presentation/controllers/home_controller.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';

class RecommendedStories extends StatelessWidget {
  final FavoritesController favoritesController;
  final HomeController homeController = Get.find<HomeController>();

  RecommendedStories({required this.favoritesController, super.key});

  final RxList<bool> likedStatus = RxList<bool>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    syncLikedStatus();
    if (likedStatus.isEmpty) {
      likedStatus
          .addAll(List.generate(homeController.filteredStories.length, (_) => false));
    }

    return Obx(
          () {
        if (homeController.filteredStories.isEmpty) {
          return const Center(
              child: Text(
                'No stories found.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ));
        }

        return Column(
          children: homeController.filteredStories.asMap().entries.map(
                (entry) {
              int index = entry.key;
              var story = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: story['image'] != null && story['image'].isNotEmpty
                          ? Image.network(
                        story['image'],
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/50.png', fit: BoxFit.cover),
                      )
                          : Image.asset('assets/50.png',
                          width: 60, height: 80, fit: BoxFit.cover),
                    ),
                    title: Text(story['title'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("@${story['author']}",
                        style: const TextStyle(color: Colors.grey)),
                    trailing: Obx(
                          () {
                        return IconButton(
                          icon: Icon(
                            likedStatus[index]
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: likedStatus[index] ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            likedStatus[index] = !likedStatus[index];
                            if (likedStatus[index]) {
                              favoritesController.addFavorite(
                                story['id'],
                                story['title'],
                                story['author'],
                              );
                            } else {
                              favoritesController.removeStory(story['id']);
                            }
                          },
                        );
                      },
                    ),
                    onTap: () {
                      Get.toNamed(Routes.READ, arguments: {'id': story['id']});
                    },
                  ),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  void syncLikedStatus() {
    everAll(
      [homeController.filteredStories, favoritesController.favoriteItems],
          (_) {
        likedStatus.clear();
        likedStatus.addAll(homeController.filteredStories.map(
              (story) {
            return favoritesController.favoriteItems.any(
                  (favorite) {
                return favorite['id'] == story['id'];
              },
            );
          },
        ).toList());
      },
    );
  }
}
