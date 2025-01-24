import 'dart:async';
import 'dart:convert';
import 'dart:ui';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../Providers/CarLocationProvider.dart';
import '../constants/urls.dart';
import '../Services/authState.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      var token = await TokenStorage.getToken();
      final carno = (await BusnoTokenStorage.getToken())!;
      if (token == null) return;

      if (response.actionId == 'stop_service') {
        // Make sure Provider usage is redesigned to avoid `context` dependency here
        try {
          final provider = CarLocationProvider(
              carNumber:
                  carno); // Use an alternative way to access the provider
          debugPrint(token);
          provider.stopLocationUpdates(token);
          await BusnoTokenStorage.removeToken(provider.carNumber);

          if (await service.isRunning()) {
            service.invoke("stopService");
          }
        } catch (e) {
          debugPrint("Error handling stop service action: $e");
        }
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Service Running',
      initialNotificationContent: 'Initializing service...',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

StreamSubscription<Position>? positionStream;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  DateTime? lastUpdate;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  try {
    // Start listening to position updates
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Minimum change in meters to notify location change
      ),
    ).listen((Position position) async {
      if (position == null) return;
      debugPrint('$position jndskjnbhhjbvkdksjbjbvs v jmdds');
      if (service is AndroidServiceInstance &&
          await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'Location Tracking',
          'Running at Lat: ${position.latitude}, Lng: ${position.longitude}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              actions: [
                AndroidNotificationAction(
                  'stop_service',
                  'Stop Service',
                  showsUserInterface: true,
                ),
              ],
            ),
          ),
        );

        try {
          var now = DateTime.now();
          lastUpdate ??= now;
          // if (now.difference(lastUpdate!).inSeconds >= 50) {
          //   service.invoke('stopService');
          //
          //   if (!await FlutterBackgroundService().isRunning()) {
          //     positionStream?.cancel();
          //   }
          // }
          debugPrint('$now and $lastUpdate');
          final token = (await TokenStorage.getToken())!;
          final carno = (await BusnoTokenStorage.getToken())!;
          if (token == null || carno == null) return;

          debugPrint('$carno ---- ${position.latitude} --- ${position.longitude}');
          final response = await http.post(
            Uri.parse('$apiBaseUrl/update-car-location'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'carNumber': carno,
              'latitude': position.latitude,
              'longitude': position.longitude,
              'token': token,
            }),
          );

          if (response.statusCode != 200) {
            debugPrint('Failed to store bus location: ${response.body}');
          }
        } catch (e) {
          debugPrint('Error occurred while storing bus location: $e');
        }

        // service.setForegroundNotificationInfo(
        //   title: ,
        //   content: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        // );
      }

      service.invoke('update', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  } catch (e) {
    debugPrint("Error starting location stream: $e");
  }
}
