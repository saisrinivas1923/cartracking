import 'package:flutter/material.dart';

import '../services/export_services.dart';
import '../constants/export_constants.dart';
import '../screens/export_screens.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    isLoading.value = true;
    try {
      if (usernameController.text.isEmpty) {
        CustomWidget.showSnackBar("Please enter your username.", context);
        return;
      }
      if (passwordController.text.isEmpty) {
        CustomWidget.showSnackBar("Please enter your password.", context);
        return;
      }
      final response = await _apiService.loginDriver(
        usernameController.text,
        passwordController.text,
      );
      if (response['token'] == null) {
        throw Exception('Invalid username or password.');
      }
      // Save the token to the SharedPreferences for future use
      await TokenStorage.saveToken(response['token']);
      // Navigate to the DriverPage with the token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverPage(),
        ),
      );
      CustomWidget.showSnackBar("Login successful!", context);
    } catch (e) {
      CustomWidget.showSnackBar("Login failed: $e", context);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures taps outside of children are detected
      onTap: () {
        // Unfocus any focused widget
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient:isDarkMode ? null : LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 350,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color:  isDarkMode? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode? Colors.white : Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo/Icon
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.directions_bus,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      LocalizationHelper.of(context).translate('dl'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Text Fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: usernameController,
                            label:
                                LocalizationHelper.of(context).translate('did'),
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: passwordController,
                            label: LocalizationHelper.of(context)
                                .translate('password'),
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: GestureDetector(
                        onTap: _login,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, loading, child) {
                            return loading
                                ? const Center(
                                    child: CircularProgressIndicator(color: Colors.orange,),
                                  )
                                : Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      LocalizationHelper.of(context)
                                          .translate('login'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Footer Text
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: icon==Icons.lock? TextInputAction.done :TextInputAction.next,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        labelText: label,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: isDarkMode? Colors.orange : Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFA726)),
        ),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    super.dispose();
  }
}
