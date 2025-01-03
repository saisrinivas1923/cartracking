import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Constants/widget.dart';
import '../Services/localization_helper.dart';
import '../Services/authState.dart';
import 'CarDisplay.dart';

class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
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
      final response = await _apiService.loginAdmin(
        usernameController.text,
        passwordController.text,
      );
      if (response['token'] == null) {
        throw Exception('Invalid username or password.');
      }
      // Save the token to the SharedPreferences for future use
      await AdminTokenStorage.saveToken(response['token']);

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic("admin");
      // Navigate to the DriverPage with the token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceListPage(),
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
      behavior: HitTestBehavior
          .opaque, // Ensures taps outside of children are detected
      onTap: () {
        // Unfocus any focused widget
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Card(
                  color: isDarkMode ? Colors.black87 : Colors.white,
                  elevation: isDarkMode ? 20 : 12,
                  shadowColor:
                      isDarkMode ? Colors.white : Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocalizationHelper.of(context)
                              .translate('al'), //"Admin Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: usernameController,
                          style: const TextStyle(color: Colors.black),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText:
                                LocalizationHelper.of(context).translate('aid'),
                                labelStyle: TextStyle(color: isDarkMode? Colors.orange : Colors.black54),
                            prefixIcon: const Icon(Icons.email,color: Colors.black,),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFFFA726)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: LocalizationHelper.of(context)
                                .translate('password'),
                            labelStyle: TextStyle(color: isDarkMode? Colors.orange : Colors.black54),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFFFA726)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ValueListenableBuilder<bool>(
                            valueListenable: isLoading,
                            builder: (context, loading, child) {
                              return loading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.orange,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 60,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        LocalizationHelper.of(context)
                                            .translate('login'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                            }),
                        const SizedBox(height: 20),
                        const Divider(thickness: 1),
                        const SizedBox(height: 10),
                        const Text(
                          "\"If you are the Admin, you know what to do.\"",
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
