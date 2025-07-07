import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:terra_brain/firebase_options.dart';
import 'package:terra_brain/presentation/app.dart';
import 'package:terra_brain/presentation/service/notif_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationHandler().initialize();
  runApp(const MyApp());
}
