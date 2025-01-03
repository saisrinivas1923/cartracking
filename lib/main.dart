import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Services/localization_helper.dart';
import '../Providers/CommonProvider.dart';
import '../Services/authState.dart';
import '../Providers/LocalizationProvider.dart';
import '../Services/backgroundService.dart';
import '../Services/notification_service.dart';
import 'Providers/CarLocationProvider.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notifications
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocalizationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(create: (_) => CurrentIndexProvider()),
        ChangeNotifierProvider(
          create: (_) => MapState(),
        ),
      ],
      child: const BusTrackingApp(),
    ),
  );

  await NotificationService.instance.initialize();
  await requestPermissions();
  await initializeService();
}

class BusTrackingApp extends StatelessWidget {
  const BusTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalizationProvider>(context);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        locale: provider.locale,
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('hi', ''), // Hindi
          Locale('te', ''), //Telugu
        ],
        localizationsDelegates: [
          LocalizationDelegate(provider.locale), // Your custom delegate
          GlobalMaterialLocalizations.delegate, // Required for Material widgets
          GlobalWidgetsLocalizations.delegate, // Required for generic widgets
          GlobalCupertinoLocalizations.delegate,
        ],
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
        title: 'Bus Tracking App',
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void askNotificationPermission() async {
    // Subscribe to topic "all"
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic("all");
    debugPrint("Subscribed to topic all");
  }

  @override
  void initState() {
    super.initState();
    askNotificationPermission();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrangeAccent,
                  Colors.orange.shade100,
                  Colors.deepOrange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Bus animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return const Center(
                child: Image(
                  image: AssetImage('assets/bus1.gif'),
                  width: double.infinity / 1.8,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              );
            },
          ),
          //App Name
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 500),
              child: Text(
                "College Car Locator",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DateTime now = DateTime.now();
  final String appLink =
      'https://play.google.com/store/apps/details?id=com.anistream';
  final List<String> images = [
    'assets/aditya.jpg', // Replace with your actual asset paths
    'assets/aditya2.jpg',
    'assets/track.jpg',
  ];

  @override
  void dispose() async {
    super.dispose();
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentIndexProvider = Provider.of<CurrentIndexProvider>(context);
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height),
        child: Stack(
          children: [
            // AppBar background (Gradient colors)
            Container(
              height: 270,
              width: double.infinity,
              //margin: EdgeInsets.only(left: 5, right: 5, top: 5),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Color.fromARGB(255, 255, 119, 110)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
            ),
            // AppBar content (Title and Help button)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
                child: AppBar(
                  title: Text(
                    LocalizationHelper.of(context).translate('maintitle'),
                    textScaler: const TextScaler.linear(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState
                          ?.openDrawer(); // Open the drawer on tap
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      margin: const EdgeInsets.all(8), // Add margin for spacing
                      decoration: const BoxDecoration(
                        color: Colors.white, // Background color for the icon
                        shape: BoxShape.circle, // Circular shape
                      ),
                      child: const Icon(
                        Icons.menu, // Menu icon
                        color: Colors.black, // Icon color
                        size: 20,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        // Add help action here
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Image carousel section
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: CarouselSlider.builder(
                        itemCount: images.length,
                        itemBuilder: (context, index, realIndex) {
                          return Image.asset(
                            images[index],
                            fit: BoxFit
                                .fill, // Ensures the image covers the container
                            width: double.infinity,
                          );
                        },
                        options: CarouselOptions(
                          height: 230,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 10),
                          onPageChanged: (index, reason) {
                            currentIndexProvider.setCurrentIndex(index);
                          },
                          viewportFraction: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSmoothIndicator(
                    activeIndex: currentIndexProvider.currentIndex,
                    count: images.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.orange,
                      dotColor: Color.fromARGB(255, 193, 186, 186),
                    ),
                  ),
                ],
              ),
            ),
            // Menu buttons positioned below the slideshow
            Positioned(
              top: 390, // Adjust this position to fit below the slideshow
              left: 20,
              right: 20,
              child: Column(
                children: [
                  buildMenuButton(
                    context,
                    LocalizationHelper.of(context).translate('admin'),
                    Icons.admin_panel_settings_outlined,
                    const AdminAuthState(),
                  ),
                  const SizedBox(height: 20),
                  buildMenuButton(
                    context,
                    LocalizationHelper.of(context).translate('driver'),
                    Icons.directions_bus_sharp,
                    const DriverAuthState(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        // Add your drawer content here
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 10, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/adityalogo1.jpg'),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocalizationHelper.of(context).translate('title'),
                            textScaler: const TextScaler.linear(1),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            "- ${LocalizationHelper.of(context).translate('subtitle')}",
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Text(
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.end,
                          "${LocalizationHelper.of(context).translate('last_sync')}: ${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(LocalizationHelper.of(context).translate('language')),
              onTap: () => showLanguageDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title:
              Text(LocalizationHelper.of(context).translate('share_app')),
              onTap: () {
                Share.share('Check out my app: $appLink',
                    subject: 'My Awesome App');
              },
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Image.asset(
                  'assets/playstorelogo.png',
                  height: 20,
                  color: isDarkMode ? Colors.white70 : null,
                ),
              ),
              title: Text(LocalizationHelper.of(context).translate('rate_us')),
              onTap: () {
                // Handle drawer item tap
                showRateUsDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(
                  LocalizationHelper.of(context).translate('report_issue')),
              onTap: () {
                // Handle drawer item tap
                showReportIssueDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bubble_chart),
              title: Text(
                  LocalizationHelper.of(context).translate('suggest_feature')),
              onTap: () {
                // Handle drawer item tap
                showSuggestFeatureDialog(context);
              },
            ),
            ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text(LocalizationHelper.of(context).translate(
                    'appearance')), //Text(LocalizationHelper.of(context).translate('')),
                trailing: Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: Colors.white,
                    trackOutlineColor: WidgetStateColor.transparent,
                    inactiveThumbColor:
                    Colors.white, // Thumb color when inactive
                    inactiveTrackColor: Colors.grey.shade200,
                    activeTrackColor: const Color.fromARGB(255, 255, 153, 0),
                  ),
                ),
                onTap: () {})
          ],
        ),
      ),
    );
  }

  void showLanguageDialog(BuildContext context) {
    final provider = Provider.of<LocalizationProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
          Text(LocalizationHelper.of(context).translate('choose_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  provider.setLocale(const Locale('en'));
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                title: const Text("हिंदी"),
                onTap: () {
                  provider.setLocale(const Locale('hi'));
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                title: const Text("తెలుగు"),
                onTap: () {
                  provider.setLocale(const Locale('te'));
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMenuButton(
      BuildContext context, String title, IconData icon, Widget page) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color.fromARGB(91, 0, 0, 0)),
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 235, 236, 237),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                isDarkMode ? Colors.white : Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Profile icon
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 23, 72, 112),
                      borderRadius: BorderRadius.circular(30),
                      border:
                      Border.all(color: const Color.fromARGB(110, 0, 0, 0)),
                    ),
                    child: Icon(icon, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  // Title text
                  Text(
                    title,
                    textScaler: const TextScaler.linear(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Forward icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRateUsDialog(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedRating = prefs.getInt('rating') ?? 0;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        int selectedRating = savedRating;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocalizationHelper.of(context).translate('rate_us'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < selectedRating
                              ? Colors.yellow
                              : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                          prefs.setInt('rating', selectedRating);

                          // Show Thank You dialog
                          Navigator.pop(context); // Close the bottom sheet
                          showThankYouDialog(context,
                              '${LocalizationHelper.of(context).translate('tru')}!');
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${LocalizationHelper.of(context).translate('yr')}: $selectedRating',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showReportIssueDialog(BuildContext context) {
    final TextEditingController issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocalizationHelper.of(context).translate('report_issue')),
          content: TextField(
            controller: issueController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
              '${LocalizationHelper.of(context).translate('report')}...',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(LocalizationHelper.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                final String issue = issueController.text.trim();
                if (issue.isNotEmpty) {
                  // Save issue locally or perform another action
                  Navigator.pop(context);
                  showThankYouDialog(context,
                      '${LocalizationHelper.of(context).translate('tri')}!');
                }
              },
              child: Text(LocalizationHelper.of(context).translate('submit')),
            ),
          ],
        );
      },
    );
  }

  void showSuggestFeatureDialog(BuildContext context) {
    final TextEditingController suggestionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocalizationHelper.of(context).translate('sfeatures')),
          content: TextField(
            controller: suggestionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
              '${LocalizationHelper.of(context).translate('suggest_feature')}...',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(LocalizationHelper.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                final String suggestion = suggestionController.text.trim();
                if (suggestion.isNotEmpty) {
                  // Save suggestion locally or perform another action
                  Navigator.pop(context);
                  showThankYouDialog(context,
                      '${LocalizationHelper.of(context).translate('tsf')}!');
                }
              },
              child: Text(LocalizationHelper.of(context).translate('submit')),
            ),
          ],
        );
      },
    );
  }

  void showThankYouDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${LocalizationHelper.of(context).translate('ty')}!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(LocalizationHelper.of(context).translate('ok')),
            ),
          ],
        );
      },
    );
  }
}
