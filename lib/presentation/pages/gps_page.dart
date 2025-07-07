import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/gps_controller.dart';

class GpsPage extends GetView<GpsController> {
  const GpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade100, Colors.teal.shade50],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Obx(() {
                      if (controller.latitude.value == 0.0 &&
                          controller.longitude.value == 0.0) {
                        return const Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.teal),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Fetching location...',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          const Icon(Icons.location_on,
                              size: 50, color: Colors.teal),
                          const Text("Your location"),
                          const SizedBox(height: 20),
                          LocationInfoRow(
                            icon: Icons.track_changes,
                            label: 'Latitude',
                            value: controller.latitude.value.toStringAsFixed(6),
                          ),
                          const SizedBox(height: 10),
                          LocationInfoRow(
                            icon: Icons.track_changes,
                            label: 'Longitude',
                            value:
                                controller.longitude.value.toStringAsFixed(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => controller.getCurrentLocation(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => controller.openGoogleMaps(
                      controller.latitude.value, controller.longitude.value),
                  icon: const Icon(Icons.map),
                  label: const Text('Open Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const LocationInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
