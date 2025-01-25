import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Services/localization_helper.dart';
import '../Constants/urls.dart';
import '../Services/authState.dart';

class NonRunningcarspage extends StatefulWidget {
  List<String> AllCars = [];
  NonRunningcarspage({super.key, required this.AllCars});

  @override
  State<NonRunningcarspage> createState() => _NonRunningcarspageState();
}

class _NonRunningcarspageState extends State<NonRunningcarspage>
    with SingleTickerProviderStateMixin {
  List<String> Cars = [];
  bool fetch = false;
  @override
  void initState() {
    super.initState();
    Fetchdata();
  }

  Future<void> Fetchdata() async {
    setState(() {
      fetch = true;
    });
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-all-cars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Cars = data.keys.toList();
        for (var i in Cars) {
          widget.AllCars.remove(i);
        }
        print(widget.AllCars);
      } else {
        debugPrint('Failed to retrieve Car location. ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
    setState(() {
      fetch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode == false
                  ? [Colors.orange, Color.fromARGB(255, 255, 119, 110)]
                  : [Color.fromRGBO(83, 215, 238, 1), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: AppBar(
                title: Text(
                    LocalizationHelper.of(context)
                        .translate('NotRunning'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textScaler: const TextScaler.linear(1)),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: fetch
          ? Center(
              child: CircularProgressIndicator(
              color:
                  isDarkMode ? Color.fromRGBO(83, 215, 238, 1) : Colors.orange,
            ))
          : widget.AllCars.isEmpty
              ? Center(
                  child: Text(
                    LocalizationHelper.of(context).translate('No Cars Are There'),
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode
                          ? Color.fromRGBO(83, 215, 238, 1)
                          : Colors.orangeAccent,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListView.builder(
                    itemCount: widget.AllCars.length,
                    itemBuilder: (context, index) {
                      final CarNumber = widget.AllCars[index];
                      return Card(
                        color: isDarkMode ? Colors.black87 : null,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: isDarkMode
                                  ? Color.fromRGBO(83, 215, 238, 1)
                                  : Colors.orange),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor:
                            isDarkMode ? Colors.orange : Colors.black,
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        child: ListTile(
                          minTileHeight: 70,
                          contentPadding: const EdgeInsets.only(
                              left: 20, right: 15, top: 5, bottom: 5),
                          leading: Icon(
                            Icons.directions_car,
                            color:
                                isDarkMode ? Colors.redAccent : Colors.black,
                            size: 35,
                          ),
                          title: Text(
                            '${LocalizationHelper.of(context).translate('CarNumber')} : $CarNumber',
                            textScaler: const TextScaler.linear(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
