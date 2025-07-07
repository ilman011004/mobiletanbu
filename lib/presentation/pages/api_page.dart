import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/best_seller_list_controller.dart';


class BestSellerListScreen extends GetView<BestSellerListController> {
  const BestSellerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novelku Best Categories',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        leading: const BackButton(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.bestSellerLists.length,
          itemBuilder: (context, index) {
            final category = controller.bestSellerLists[index];
            return ListTile(
              tileColor: Colors.black,
              title: Text(category.displayName, style: const TextStyle(color: Colors.white),),
              subtitle: Text('Updated: ${category.updated}', style: const TextStyle(color: Colors.white)),
              onTap: () {

              },
            );
          },
        );
      }),
    );
  }
}
