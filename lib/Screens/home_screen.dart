import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../services/export_services.dart';
import '../providers/export_providers.dart';
import '../widgets/export_widgets.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> images = [
    'assets/1.jpg',
    'assets/2.png',
    'assets/3.jpg',
    'assets/4.jpg',
    'assets/5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndexProvider = Provider.of<CurrentIndexProvider>(context,listen: false);
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode? Colors.black:Colors.white,
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body:  SingleChildScrollView(
        child: Container(
          width: double.infinity,
          //margin: EdgeInsets.only(left: 5, right: 5, top: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode == false
                  ? [
                Colors.orange,
                const Color.fromARGB(255, 255, 119, 110),
                Colors.white,
                Colors.white,
                Colors.white
              ]
                  : [const Color.fromRGBO(83, 215, 238, 1), Colors.black, Colors.black, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children:  [
                // AppBar content (Title and Help button)
                AppBar(
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
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // Add help action here
                        showDialog(
                          context: context,
                          builder: (context) {
                            return PopupPage();
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                // Image carousel section
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: CarouselSlider.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index, realIndex) {
                        return Image.asset(
                          images[index],
                          width: double.infinity,
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        onPageChanged: (index, reason) {
                          currentIndexProvider.setCurrentIndex(index);
                        },
                        viewportFraction: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                AnimatedSmoothIndicator(
                  activeIndex: Provider.of<CurrentIndexProvider>(context,listen: true).currentIndex,
                  count: images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: isDarkMode
                        ? const Color.fromRGBO(83, 215, 238, 1)
                        : Colors.orange,
                    dotColor: const Color.fromARGB(255, 193, 186, 186),
                  ),
                ),
                SizedBox(height: 20,),
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
                  Icons.car_repair_rounded,
                  const DriverAuthState(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
            side: BorderSide(
                color: isDarkMode
                    ? Colors.transparent
                    : const Color.fromARGB(91, 0, 0, 0)),
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 235, 236, 237),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? const Color.fromRGBO(83, 215, 238, 0.5)
                    : Colors.black.withOpacity(0.2),
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
}
