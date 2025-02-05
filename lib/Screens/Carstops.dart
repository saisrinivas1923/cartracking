import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../Providers/CarLocationProvider.dart';
import '../Providers/CarStopsProvider.dart';
import '../Providers/CarsDetailsProvider.dart';
import '../constants/widget.dart';
import '../Services/localization_helper.dart';

class CarManageStopsScreen extends StatelessWidget {
  final String car;

  const CarManageStopsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CarStopsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchStops(car); // Fetch stops only once
    });

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [const Color.fromRGBO(83, 215, 238, 1), Colors.black]
                  : [Colors.orange, const Color.fromARGB(255, 255, 119, 110)],
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
                  '${LocalizationHelper.of(context).translate('msfc')} $car',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
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
      body: Consumer<CarStopsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromRGBO(83, 215, 238, 1)
                    : Colors.orange,
              ),
            );
          } else if (provider.stops.isEmpty) {
            return Center(
              child: Text(
                LocalizationHelper.of(context).translate('No stops available'),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromRGBO(83, 215, 238, 1)
                      : Colors.orangeAccent,
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = provider.stops.removeAt(oldIndex);
                  provider.stops.insert(newIndex, item);
                  provider.reorderStops(car, provider.stops);
                },
                children: [
                  for (int index = 0; index < provider.stops.length; index++)
                    Card(
                      key: ValueKey(provider.stops[index]),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black87
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromRGBO(83, 215, 238, 1)
                              : Colors.orange,
                        ),
                      ),
                      elevation: 5,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromRGBO(83, 215, 238, 1)
                              : Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        minTileHeight: 70,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.red,
                          size: 25,
                        ),
                        title: Text(
                          provider.stops[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.red
                                : Colors.blueGrey,
                          ),
                          onPressed: () =>
                              provider.removeStop(car, provider.stops[index]),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: GestureDetector(
      onTap: (){
        _showAddStopDialog(context, car);
      },
      child: Container(
        height: 50,
        width: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black87
              : Colors.black54, // Updated to match admin FAB color
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromRGBO(83, 215, 238, 1)
                : Colors.white,
          ),
        ),
        child: Center(
          child: Icon(Icons.add,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromRGBO(83, 215, 238, 1)
                  : Colors.white),
        ), // Updated icon color
      ),
    ),
    );
  }

  void _showAddStopDialog(BuildContext context, String carNumber) {
    String stopName = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(LocalizationHelper.of(context).translate('as')),
          content: TextField(
            onChanged: (value) => stopName = value.trim(),
            decoration: InputDecoration(
              labelText: LocalizationHelper.of(context).translate('sn'),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocalizationHelper.of(context).translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (stopName.isNotEmpty) {
                  Provider.of<CarStopsProvider>(context, listen: false)
                      .addStop(carNumber, stopName);
                  Navigator.pop(context);
                  CustomWidget.showSnackBar(
                      'Stop added successfully', context);
                } else {
                  CustomWidget.showSnackBar(
                      'Stop name cannot be empty', context);
                }
              },
              child: Text(LocalizationHelper.of(context).translate('okay')),
            ),
          ],
        );
      },
    );
  }
}

class AdminCarMapPage extends StatelessWidget {
  final String carNumber;

  AdminCarMapPage({super.key, required this.carNumber});
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    return ChangeNotifierProvider(
      create: (_) => CarsLocationProvider(carNumber: carNumber),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${LocalizationHelper.of(context).translate('cl')}: $carNumber",
            textScaler: const TextScaler.linear(1),
            style: const TextStyle(
                 fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: [
            Consumer<CarsLocationProvider>(
              builder: (context, provider, _) {
                final carLocation = provider.carLocation;
                return carLocation == null
                    ? Center(
                        child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Color.fromARGB(255, 38, 176, 235)
                            : Colors.orange,
                      ))
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: carLocation,
                          initialZoom: 15.0,
                          maxZoom: 18.4,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: mapState.selectedProvider.urlTemplate,
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: carLocation,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.directions_car,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
              },
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Consumer<CarsLocationProvider>(
                  builder: (context, provider, _) {
                final busLocation = provider.carLocation;
                return FloatingActionButton(
                  onPressed: () {
                    if (busLocation != null) {
                      _mapController.move(busLocation, 15.0);
                    } else {
                      CustomWidget.showSnackBar(
                          "Car location not available", context);
                    }
                  },
                  child: const Icon(Icons.my_location),
                );
              }),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: CircleAvatar(
            child: IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizationHelper.of(context).translate('Select Map Style'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...mapProviders.map((provider) {
                            return ListTile(
                              leading: const Icon(Icons.map),
                              title: Text(LocalizationHelper.of(context).translate(provider.name)),
                              onTap: () {
                                mapState.updateProvider(provider);
                                Navigator.pop(
                                    context); // Close the bottom sheet
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
