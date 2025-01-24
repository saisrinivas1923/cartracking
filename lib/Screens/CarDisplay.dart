import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Constants/widget.dart';
import '../Services/localization_helper.dart';
import '../Constants/urls.dart';
import '../Services/authState.dart';
import 'Carstops.dart';

class PlaceListPage extends StatefulWidget {
  const PlaceListPage({super.key});

  @override
  State<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends State<PlaceListPage>
    with SingleTickerProviderStateMixin {
  List<String> Cars = [];
  bool fetch = false;
  TextEditingController CarController = TextEditingController();
  TextEditingController empidController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobController = TextEditingController();
  TextEditingController vechicleTypeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchNo();
    fetchCarNumbers();
  }

  Future<void> _addCar(String car) async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/add-car'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'carNumber': car,
          'carName': vechicleTypeController.text,
          'empId': empidController.text,
          'name': nameController.text,
          'phno': mobController.text,
          'token': token
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          Cars.add(car);
        });
        CarController.clear();
        nameController.clear();
        vechicleTypeController.clear();
        mobController.clear();
        empidController.clear();
        CustomWidget.showSnackBar('Car $car added successfully', context);
      } else {
        CustomWidget.showSnackBar('Failed to add Car', context);
      }
    } catch (e) {
      CustomWidget.showSnackBar('Error adding Car: $e', context);
    }
  }

  Future<void> _deleteCar(String car) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocalizationHelper.of(context).translate('cde'),
            textScaler: const TextScaler.linear(1),
          ),
          content: Text(
            '${LocalizationHelper.of(context).translate('sure')} $car?',
            textScaler: const TextScaler.linear(1),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                LocalizationHelper.of(context).translate('cancel'),
                textScaler: const TextScaler.linear(1),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                LocalizationHelper.of(context).translate('delete'),
                textScaler: const TextScaler.linear(1),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmDelete) {
      final token = await AdminTokenStorage.getToken();
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/remove-car'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'carNumber': car, 'token': token}),
        );
        if (response.statusCode == 200) {
          setState(() {
            Cars.remove(car);
          });
          CustomWidget.showSnackBar('Car $car removed successfully', context);
        } else {
          CustomWidget.showSnackBar('Failed to remove Car', context);
        }
      } catch (e) {
        CustomWidget.showSnackBar('Error removing Car: $e', context);
      }
    }
  }

  Future<void> fetchCarNumbers() async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-cars'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data == {}) {
          debugPrint("$data");
          return;
        }
        final numbers = data;

        setState(() {
          Cars = numbers.keys.toList();
        });
        fetch = true;
      } else {
        debugPrint("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Map<String, dynamic> carlist = {};
  Map<String, dynamic> all_list = {};
  List<dynamic> cars = [];
  bool is_loading = false;
  bool isSelect = false;

  Future<void> _fetchNo() async {
    setState(() {
      is_loading = true;
    });
    final url = Uri.parse('$apiBaseUrl/all-data');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the keys from the "routes" object
        carlist = data['cars'];
        all_list = data['details'];
        print(all_list);
        cars = all_list.keys.toList();
        print(carlist);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('connected success.')),
        );
        // Get the keys of the routes
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No buses found or an error occurred.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
    setState(() {
      is_loading = false;
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
                    ? [Colors.orange, const Color.fromARGB(255, 255, 119, 110)]
                    : [const Color.fromRGBO(83, 215, 238, 1), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
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
                          .translate('admindashboard'),
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
                  actions: [],
                ),
              ),
            ),
          ),
        ),
        body: fetch == false
            ? Center(
                child: CircularProgressIndicator(
                color: isDarkMode
                    ? const Color.fromRGBO(83, 215, 238, 1)
                    : Colors.orange,
              ))
            : Cars.isEmpty
                ? Center(
                    child: Text(
                      "No Cars Are There",
                      textScaler: const TextScaler.linear(1),
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode
                            ? const Color.fromRGBO(83, 215, 238, 1)
                            : Colors.orangeAccent,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ListView.builder(
                      itemCount: Cars.length,
                      itemBuilder: (context, index) {
                        final CarNumber = Cars[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CarManageStopsScreen(car: CarNumber),
                              ),
                            );
                          },
                          child: Card(
                            color: isDarkMode ? Colors.black87 : null,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(83, 215, 238, 1)
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
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: 35,
                              ),
                              title: Text(
                                'Car Number : $CarNumber',
                                textScaler: const TextScaler.linear(1),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.menu_book,
                                      color: isDarkMode
                                          ? Colors.redAccent
                                          : Colors.blueGrey,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder:(context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Container(
                                                //margin: EdgeInsets.only(left: 10, right: 10),
                                                height: MediaQuery.of(context).size.height * 0.3,
                                                width: MediaQuery.of(context).size.width * 0.6,
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Colors.transparent
                                                      : const Color.fromARGB(255, 249, 245, 245),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isDarkMode
                                                        ? const Color.fromRGBO(83, 215, 238, 1)
                                                        : Colors.black,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      all_list[cars[index]][0].length == 0
                                                          ? "Not Added"
                                                          : (all_list[cars[index]][0]).toString().toUpperCase(),
                                                      style: TextStyle(
                                                          color: isDarkMode
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontSize: 18),
                                                      textScaler: const TextScaler.linear(1),
                                                      overflow: TextOverflow.clip,
                                                    ),
                                                    Divider(
                                                      color: isDarkMode
                                                          ? const Color.fromRGBO(83, 215, 238, 1)
                                                          : Colors.black,
                                                      thickness: 1.5,
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      width: 160,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: isDarkMode
                                                            ? Colors.transparent
                                                            : Colors.black,
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(
                                                            color: isDarkMode
                                                                ? const Color.fromRGBO(83, 215, 238, 1)
                                                                : Colors.black,
                                                            width: 1.5),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "${(cars[index]).toString().toUpperCase()}",
                                                          style: TextStyle(
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors.white,
                                                              fontWeight: FontWeight.w200),
                                                          textScaler: const TextScaler.linear(1),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Emp ID :',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                          textScaler: const TextScaler.linear(1),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          all_list[cars[index]][1].length == 0
                                                              ? "Not Added"
                                                              : "${(all_list[cars[index]][1]).toString().toUpperCase()}",
                                                          style: TextStyle(
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                          textScaler: const TextScaler.linear(1),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Name :',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                          textScaler: const TextScaler.linear(1),
                                                          overflow: TextOverflow.clip,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.sizeOf(context).width *
                                                              0.4,
                                                          child: Text(
                                                            all_list[cars[index]][2].length == 0
                                                                ? "Not Added"
                                                                : "${(all_list[cars[index]][2]).toString().toUpperCase()}",
                                                            style: TextStyle(
                                                                color: isDarkMode
                                                                    ? Colors.white
                                                                    : Colors.black),
                                                            textScaler: const TextScaler.linear(1),
                                                            overflow: TextOverflow.clip,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Mobile No :',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                          textScaler: const TextScaler.linear(1),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          all_list[cars[index]][3].length == 0
                                                              ? "Not Added"
                                                              : "${(all_list[cars[index]][3]).toString().toUpperCase()}",
                                                          style: TextStyle(
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                          textScaler: const TextScaler.linear(1),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10,)
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                      );

                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: isDarkMode
                                          ? Colors.redAccent
                                          : Colors.blueGrey,
                                    ),
                                    onPressed: () {
                                      _deleteCar(CarNumber);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(LocalizationHelper.of(context).translate('car'),
                      textScaler: const TextScaler.linear(1)),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                      controller: empidController,
                      decoration: InputDecoration(
                        hintText: LocalizationHelper.of(context)
                            .translate('Employee ID'),
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: LocalizationHelper.of(context)
                            .translate('Employee Name'),
                      ),
                    ),
                    TextField(
                      controller: mobController,
                      decoration: InputDecoration(
                        hintText: LocalizationHelper.of(context)
                            .translate('Emp Mobile No.'),
                      ),
                    ),
                    TextField(
                      controller: CarController,
                      decoration: InputDecoration(
                        hintText: LocalizationHelper.of(context)
                            .translate('Car Number'),
                      ),
                    ),
                    TextField(
                      controller: vechicleTypeController,
                      decoration: InputDecoration(
                        hintText: LocalizationHelper.of(context)
                            .translate('Car Name'),
                      ),
                    ),
                  ]),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                          LocalizationHelper.of(context).translate('cancel'),
                          textScaler: const TextScaler.linear(1)),
                      onPressed: () {
                        CarController.clear();
                        nameController.clear();
                        vechicleTypeController.clear();
                        mobController.clear();
                        empidController.clear();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                          LocalizationHelper.of(context).translate('ok'),
                          textScaler: const TextScaler.linear(1)),
                      onPressed: () {
                        String CarNumber = CarController.text.trim();
                        if (CarNumber.isNotEmpty) {
                          debugPrint(CarNumber);
                          _addCar(CarNumber);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            height: 50,
            width: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black87 : Colors.black54,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color:
                    isDarkMode ? const Color.fromRGBO(83, 215, 238, 1) : Colors.white,
              ),
            ),
            child: Center(
                child: Icon(Icons.add,
                    color: isDarkMode
                        ? const Color.fromRGBO(83, 215, 238, 1)
                        : Colors.white)),
          ),
        ));
  }
}
