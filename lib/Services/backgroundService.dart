import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await Permission.location.request();
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL: Define custom notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'stop_service') {
          debugPrint("Stop Service button clicked.");
          service.invoke('stopService');
        }
      },
    );
  }

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

// Handles iOS background fetch
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// Handles the start of the background service
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      debugPrint("Fore Ground");
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      debugPrint("Back Ground");
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'Service Update',
          'Running at ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              actions: [
                AndroidNotificationAction(
                  'stop_service', // Unique action ID
                  'Stop Service', // Button text
                ),
              ],
            ),
          ),
        );

        service.setForegroundNotificationInfo(
          title: "Background Service",
          content: "Last updated: ${DateTime.now()}",
        );
      }
    }

    debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
      },
    );
  });
}

// Main app widget
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const ServiceHomePage(),
//     );
//   }
// }
//
// class ServiceHomePage extends StatefulWidget {
//   const ServiceHomePage({super.key});
//
//   @override
//   State<ServiceHomePage> createState() => _ServiceHomePageState();
// }
//
// class _ServiceHomePageState extends State<ServiceHomePage> {
//   String buttonText = "Stop Service";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Background Service App')),
//       body: Column(
//         children: [
//           StreamBuilder<Map<String, dynamic>?>(
//             stream: FlutterBackgroundService().on('update'),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               final data = snapshot.data!;
//               String? device = data["device"];
//               DateTime? date = DateTime.tryParse(data["current_date"]);
//               return Column(
//                 children: [
//                   Text(device ?? 'Unknown Device'),
//                   Text(date.toString()),
//                 ],
//               );
//             },
//           ),
//           ElevatedButton(
//             child: const Text("Foreground Mode"),
//             onPressed: () =>
//                FlutterBackgroundService().invoke("setAsForeground"),
//           ),
//           ElevatedButton(
//             child: const Text("Background Mode"),
//             onPressed: () =>
//                 FlutterBackgroundService().invoke("setAsBackground"),
//           ),
//           ElevatedButton(
//             child: Text(buttonText),
//             onPressed: () async {
//               final service = FlutterBackgroundService();
//               bool isRunning = await service.isRunning();
//               isRunning ? service.invoke("stopService") : service.startService();
//
//               setState(() {
//                 buttonText = isRunning ? 'Start Service' : 'Stop Service';
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//}