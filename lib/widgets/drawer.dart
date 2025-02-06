import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/export_services.dart';
import '../providers/export_providers.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});
  final DateTime now = DateTime.now();
  final String appLink =
      'https://drive.google.com/file/d/1I63mlCJFVk5A9ufeDQHWbilc08_J8e7o/view?usp=sharing';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero, // Remove default padding
        children: <Widget>[
          Container(
            // This ensures it spans the top part
            height: 150 + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color.fromRGBO(83, 215, 238, 1), Colors.black]
                    : [Colors.orange, const Color.fromARGB(255, 255, 119, 110)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  10, // Adjust for status bar
              bottom: 10,
              left: 10,
              right: 20,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/adityalogo.png'),
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
          // Remaining drawer items
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(LocalizationHelper.of(context).translate('language')),
            onTap: () => showLanguageDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(LocalizationHelper.of(context).translate('share_app')),
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
              showRateUsDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title:
                Text(LocalizationHelper.of(context).translate('report_issue')),
            onTap: () {
              showReportIssueDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bubble_chart),
            title: Text(
                LocalizationHelper.of(context).translate('suggest_feature')),
            onTap: () {
              showSuggestFeatureDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(LocalizationHelper.of(context).translate('appearance')),
            trailing: Transform.scale(
              scale: 0.7,
              child: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: Colors.white,
                trackOutlineColor: WidgetStateColor.transparent,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade200,
                activeTrackColor: const Color.fromARGB(255, 255, 153, 0),
              ),
            ),
            onTap: () {},
          ),
        ],
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
