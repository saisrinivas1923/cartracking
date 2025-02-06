import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/export_services.dart';
import '../providers/export_providers.dart';
import '../constants/export_constants.dart';
import '../screens/export_screens.dart';

class PlaceListPage extends StatefulWidget {
  const PlaceListPage({super.key});

  @override
  State<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends State<PlaceListPage>
    with SingleTickerProviderStateMixin {
  TextEditingController CarController = TextEditingController();
  TextEditingController empidController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobController = TextEditingController();
  TextEditingController vechicleTypeController = TextEditingController();
  Set<int> selectedCars = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await AdminTokenStorage.getToken();
      await Provider.of<CarProvider>(context, listen: false).fetchCars(
        token!,
      );
      await Provider.of<CarProvider>(context, listen: false).fetchCarData();
    });
  }

  Future<void> _addCar(String car) async {
    final token = await AdminTokenStorage.getToken();
    await Provider.of<CarProvider>(context, listen: false).addCar(car, token!, {
      'carName': vechicleTypeController.text.trim(),
      'empId': empidController.text.trim(),
      'name': nameController.text.trim(),
      'phno': mobController.text.trim(),
    }).then((_) async {
      final token = await AdminTokenStorage.getToken();
      await Provider.of<CarProvider>(context, listen: false).fetchCars(
        token!,
      );
      await Provider.of<CarProvider>(context, listen: false).fetchCarData();
      _clearControllers();
      CustomWidget.showSnackBar('Car $car added successfully', context);
    }).catchError((e) {
      CustomWidget.showSnackBar('Failed to add Car: $e', context);
    });
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
      await Provider.of<CarProvider>(context, listen: false)
          .deleteCar(car, token!)
          .then((_) {
        CustomWidget.showSnackBar('Car $car deleted successfully', context);
      }).catchError((e) {
        CustomWidget.showSnackBar('Failed to delete Car: $e', context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Consumer<CarProvider>(builder: (context, carProvider, child) {
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
                  actions: [
                    selectedCars.isNotEmpty?
                  IconButton(
                  icon: Icon(Icons.delete),
                    onPressed: () {
                      // Handle bulk delete
                      _deleteSelectedCars();
                    },
                  ):
                    IconButton(
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: Provider.of<Runningcarsprovider>(context,
                                  listen: false)
                              .Cars
                              .isEmpty
                          ? () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('No Cars Running'),
                                      content: Text(
                                          'There are no cars running to show on the map'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            LocalizationHelper.of(context)
                                                .translate('ok'),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AllCarMapPage()));
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: (carProvider.isLoading || carProvider.isLoading1)
            ? Center(
                child: CircularProgressIndicator(
                color: isDarkMode
                    ? const Color.fromRGBO(83, 215, 238, 1)
                    : Colors.orange,
              ))
            : carProvider.cars.isEmpty
                ? Center(
                    child: Text(
                      LocalizationHelper.of(context)
                          .translate('No Cars Are There'),
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
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: carProvider.cars.length,
                      itemBuilder: (context, index) {
                        final CarNumber = carProvider.cars[index];
                        // Access the required data from the provider
                        final carKey = carProvider.carsdetails[index];
                        final carDetails = carProvider.allList[carKey];
                        return GestureDetector(
                          onLongPress: () {
                            // Toggle selection on long press
                            setState(() {
                              if (selectedCars.contains(index)) {
                                selectedCars.remove(index);
                              } else {
                                selectedCars.add(index);
                              }
                            });
                          },
                          onTap: () {
                            if (selectedCars.isEmpty) {
                              // Navigate to CarManageStopsScreen for non-selected items
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CarManageStopsScreen(car: CarNumber),
                                ),
                              );
                            } else {
                              // Toggle selection on tap if it's in selection mode
                              setState(() {
                                if (selectedCars.contains(index)) {
                                  selectedCars.remove(index);
                                } else {
                                  selectedCars.add(index);
                                }
                              });
                            }
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
                                '${LocalizationHelper.of(context).translate('CarNumber')} : $CarNumber',
                                textScaler: const TextScaler.linear(1),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              trailing:  selectedCars.contains(index)
                                  ? Icon(
                                Icons.check_circle,
                                color: isDarkMode ? Colors.green : Colors.blue,
                              )
                                  :  GestureDetector(
                                onTap: (){
                                  List<String> list1 = List<String>.from(carDetails);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverDashboard(
                                        driverId: carKey.toString(),
                                        carDetails: list1,
                                      ),
                                    ),
                                  );
                                },
                                    child: Icon(
                                        Icons.menu_book,
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Colors.blueGrey,
                                      ),
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
            _showAddCarDialog(context);
          },
          child: Container(
            height: 50,
            width: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black87 : Colors.black54,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode
                    ? const Color.fromRGBO(83, 215, 238, 1)
                    : Colors.white,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: isDarkMode
                    ? const Color.fromRGBO(83, 215, 238, 1)
                    : Colors.white,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _deleteSelectedCars() {
    // Handle the bulk deletion of selected cars
    for (int index in selectedCars) {
      final carNumber = Provider.of<CarProvider>(context,listen: false).cars[index];
      _deleteCar(carNumber);
    }
    setState(() {
      selectedCars.clear();
    });
  }

  void _showAddCarDialog(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocalizationHelper.of(context).translate('EnterCar'),
            textScaler: const TextScaler.linear(1),
          ),
          content: Form(
            key: _formKey,
            child: _buildDialogContent(context),
          ),
          actions: _buildDialogActions(context, _formKey),
        );
      },
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(
          controller: empidController,
          hintText: LocalizationHelper.of(context).translate('EmployeeId'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
        ),
        _buildTextField(
          controller: nameController,
          hintText: LocalizationHelper.of(context).translate('EmployeeName'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
        ),
        _buildTextField(
          controller: mobController,
          hintText: LocalizationHelper.of(context).translate('EmployeeMobile'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
        ),
        _buildTextField(
          controller: CarController,
          hintText: LocalizationHelper.of(context).translate('CarNumber'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
        ),
        _buildTextField(
          controller: vechicleTypeController,
          hintText: LocalizationHelper.of(context).translate('CarName'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      validator: validator,
      textInputAction: TextInputAction.next,
    );
  }

  List<Widget> _buildDialogActions(
      BuildContext context, GlobalKey<FormState> formKey) {
    return [
      TextButton(
        child: Text(
          LocalizationHelper.of(context).translate('cancel'),
          textScaler: const TextScaler.linear(1),
        ),
        onPressed: () {
          _clearControllers();
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text(
          LocalizationHelper.of(context).translate('ok'),
          textScaler: const TextScaler.linear(1),
        ),
        onPressed: () {
          if (formKey.currentState?.validate() ?? false) {
            String carNumber = CarController.text.trim();
            _addCar(carNumber);

            Navigator.of(context).pop();
          }
        },
      ),
    ];
  }

  void _clearControllers() {
    empidController.clear();
    nameController.clear();
    mobController.clear();
    CarController.clear();
    vechicleTypeController.clear();
  }
}
