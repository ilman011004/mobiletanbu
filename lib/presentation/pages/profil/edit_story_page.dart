import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/edit_story_controller.dart';

class EditStoryPage extends StatelessWidget {
  final EditStoryController controller = Get.find<EditStoryController>();

  EditStoryPage({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final storyId = arguments['id'] as String;

    controller.setStoryId(storyId);

    print('Editing story with ID: $storyId');

    final TextEditingController titleController =
    TextEditingController(text: arguments['title'] as String);
    final TextEditingController contentController =
    TextEditingController(text: arguments['content'] as String);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await controller.editStory(
                  newTitle: titleController.text,
                  newContent: contentController.text,
                  newImageUrl: controller.imagePath.value.isNotEmpty
                      ? controller.imagePath.value
                      : null,
                );
                Get.back();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Display the current image
                Obx(() {
                  return controller.imagePath.value.isNotEmpty
                      ? Image.network(
                    controller.imagePath.value,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : const Text('No image selected.');
                }),
                const SizedBox(height: 16),
                // Button to pick a new image
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Edit Image'),
                  onPressed: () async {
                    await controller.pickImage();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content cannot be empty';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
