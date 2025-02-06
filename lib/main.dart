import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../services/export_services.dart';
import '../providers/export_providers.dart';
import '../screens/export_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocalizationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrentIndexProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MapState(),
        ),
        ChangeNotifierProvider(
          create: (_) => Runningcarsprovider(
            apiService: Runningcarsapiservice(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CarProvider(
              apiService: AllCarsApiService()
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminDashboardProvider(
            apiService: AdminDashboardApiService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CarStopsProvider(),
        ),
      ],
      child: CarTrackingApp(),
    ),
  );

  if (Platform.isAndroid || Platform.isIOS) {
    await Permission.notification.request();
    await Permission.location.request();
  }
  await initializeService();
}

class CarTrackingApp extends StatelessWidget {
  const CarTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalizationProvider>(context);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        locale: provider.locale,
        supportedLocales: const [
          Locale('en', ''), 
          Locale('hi', ''), 
          Locale('te', ''), 
          Locale('jpn','') , 
        ],
        localizationsDelegates: [
          LocalizationDelegate(provider.locale), 
          GlobalMaterialLocalizations.delegate, 
          GlobalWidgetsLocalizations.delegate, 
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Resolve locale based on user preference
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: const TextTheme(
            bodyMedium:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: const TextTheme(
            bodyLarge:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        title: 'Car Tracking',
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}