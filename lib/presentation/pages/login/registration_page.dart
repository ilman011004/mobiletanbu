import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/controllers/register_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:terra_brain/presentation/routes/app_pages.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.deepPurple.shade900],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                  const Text(
                    'Ceritakan tentang dirimu',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 40),
                  ..._buildAnimatedFields(context),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 12),
                  _buildSignInButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedFields(BuildContext context) {
    return [
      _buildAnimatedTextField(
        label: 'Nama',
        onChanged: (value) => controller.name.value = value,
        icon: Icons.person,
      ),
      _buildAnimatedTextField(
        label: 'Email',
        onChanged: (value) => controller.email.value = value,
        icon: Icons.email,
      ),
      _buildAnimatedTextField(
        label: 'Kata Sandi',
        onChanged: (value) => controller.password.value = value,
        isPassword: true,
        icon: Icons.lock,
      ),
      _buildAnimatedTextField(
        label: 'Nama Pengguna',
        onChanged: (value) => controller.username.value = value,
        hint: 'Pilih nama untuk melindungi privasi Anda.',
        icon: Icons.account_circle,
      ),
      _buildAnimatedDatePicker(context),
      _buildAnimatedDropdown(
        label: 'Jenis Kelamin',
        items: ['Anonim', 'Laki-laki', 'Perempuan'],
        onChanged: (value) => controller.pronouns.value = value!,
      ),
      // _buildSignInButton(),
    ];
  }

  Widget _buildAnimatedTextField({
    required String label,
    required Function(String) onChanged,
    String? hint,
    bool isPassword = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildAnimatedDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kapan ulang tahunmu?',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Text(
                        controller.birthDate.value.isEmpty
                            ? 'Pilih Tanggal'
                            : controller.birthDate.value,
                        style: TextStyle(
                            color: controller.birthDate.value.isEmpty
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildAnimatedDropdown({
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.first,
              dropdownColor: Colors.black.withOpacity(0.9),
              style: const TextStyle(color: Colors.white),
              onChanged: onChanged,
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              isExpanded: true,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          try {
            await controller.register();
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString(),
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Lanjutkan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ).animate().scale(delay: 1000.ms, duration: 400.ms);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple.shade200,
              onPrimary: Colors.black,
              surface: Colors.deepPurple.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.birthDate.value = "${picked.toLocal()}".split(' ')[0];
    }
  }

  Widget _buildSignInButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Get.offNamed(Routes.LOGIN);
        },
        child: const Text(
          "Sudah punya akun? Masuk",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
