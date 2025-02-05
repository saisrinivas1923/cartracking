import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import '../Services/localization_helper.dart';
import '../Constants/urls.dart';

class DriverDashboard extends StatefulWidget {
  final String driverId;
  final List<String> carDetails;

  const DriverDashboard({
    Key? key,
    required this.driverId,
    required this.carDetails,
  }) : super(key: key);

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  Map<String, dynamic> driverData = {};
  bool isLoading = true;
  String errorMessage = '';
  double totalDistance = 0.0; // To store total distance traveled by the car
  double dailyDistance = 0.0; // To store distance traveled on the current day

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final response = await http
          .get(Uri.parse('$localapi/driver-locations/${widget.driverId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("Response body: $data"); // Log response for debugging

        setState(() {
          driverData = data; // Store the entire response data
          totalDistance = data['totalDistance'].toDouble();
          totalDistance/=1000;
          // Calculate the distance for the current day (today)
          final todayDate = DateTime.now().toString().split(' ')[0];
          if (data['Date'][todayDate] != null) {
            dailyDistance = data['Date'][todayDate]['totalDistance'].toDouble();
          }
          dailyDistance/=1000;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch locations: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching locations: $e";
        isLoading = false;
      });
    }
  }

  void generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              "Driver Report",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),

          // Driver Details Section
          pw.Text(
            'Driver Details',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),

          _buildPdfRow('Car:', widget.carDetails[0]),
          _buildPdfRow('Emp ID:', widget.carDetails[1]),
          _buildPdfRow('Name:', widget.carDetails[2]),
          _buildPdfRow('Phone:', widget.carDetails[3]),
          _buildPdfRow('License Plate:', widget.driverId),

          pw.SizedBox(height: 10),

          // Distance Information
          pw.Text(
            'Distance Traveled',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          _buildPdfRow('Total Distance:', "${(totalDistance).toStringAsFixed(2)} km"),
          _buildPdfRow('Distance Today:', "${dailyDistance.toStringAsFixed(2)} km"),

          pw.SizedBox(height: 10),

          // Location History Header
          pw.Text(
            'Location History',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          // Location History Data (Paginated)
          ..._buildLocationHistory(driverData),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

// Helper function to create a row
  pw.Widget _buildPdfRow(String title, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Text(value.isNotEmpty ? value.toUpperCase() : 'Not Added'),
        ],
      ),
    );
  }

// Function to create location history entries with pagination
  List<pw.Widget> _buildLocationHistory(Map<String, dynamic> driverData) {
    List<pw.Widget> widgets = [];

    driverData['Date']?.entries.forEach((entry) {
      final date = entry.key;
      final places = entry.value['places'] as List;

      widgets.add(
        pw.Text(date, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      );
      widgets.add(pw.SizedBox(height: 5));

      for (var place in places) {
        widgets.add(
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              "Location: ${place['placeName']} - Time: ${place['timestamp']}",
              style: pw.TextStyle(fontSize: 14),
            ),
          ),
        );
      }
      widgets.add(pw.SizedBox(height: 10));
    });

    return widgets;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationHelper.of(context).translate('driverdashboard'),
          textScaler: TextScaler.linear(1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sim_card_download_outlined), // PDF Icon
            onPressed: generatePdf,  // Trigger your generatePdf function here
          ),
          SizedBox(width: 10),  // Optional space between the icon and the edge
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade200,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Car Number
                  Text(
                    "Car Name: ${widget.carDetails[0].isNotEmpty ? widget.carDetails[0].toUpperCase() : 'Not Added'}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildProfileRow(
                      Icons.directions_car, "License Plate", widget.driverId),
                  // Profile Details
                  _buildProfileRow(Icons.badge, "Emp ID", widget.carDetails[1]),
                  _buildProfileRow(Icons.person, "Name", widget.carDetails[2]),
                  _buildProfileRow(Icons.phone, "Mobile", widget.carDetails[3]),
                ],
              ),
            ),
            // Distance info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Distance Card
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade100,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.directions_car, color: Colors.blue, size: 30),
                            SizedBox(width: 10),
                            Expanded( // Ensures text doesn't overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Distance",
                                    style: TextStyle(
                                      fontSize: 14, // Slightly smaller for better fit
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Prevents overflow
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "${totalDistance.toStringAsFixed(2)} km",
                                    style: TextStyle(
                                      fontSize: 16, // Keep readable but not too large
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8), // Small spacing between cards

                  // Distance Today Card
                  Expanded(
                    child: Card(
                      color: Colors.green.shade100,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.today, color: Colors.green, size: 30),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Distance Today",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "${dailyDistance.toStringAsFixed(2)} km",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Location History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Text(errorMessage,
                              style: const TextStyle(color: Colors.red)))
                      : driverData.isEmpty
                          ? const Center(child: Text("No locations available"))
                          : ListView.builder(
                              itemCount: driverData['Date']?.length ?? 0,
                              itemBuilder: (context, index) {
                                final dateKey =
                                    driverData['Date']?.keys.toList()[index];
                                final places = driverData['Date']?[dateKey]
                                    ['places'] as List;

                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  color: Theme.of(context).brightness ==
                                          Brightness.light ? Colors.orange : 
                                      const Color.fromARGB(255, 110, 109, 109),
                                  child: ListTile(
                                    title: Text(dateKey ?? "Unknown Date"),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: places.map((place) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.location_pin),
                                                SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.75,
                                                    child: Text(
                                                      "  ${place['placeName']}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time),
                                                Text(
                                                  "  ${place['timestamp']}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Center(child: Text("||")),
                                            Center(child: Text("V")),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            "$title: ${value.isNotEmpty ? value.toUpperCase() : 'Not Added'}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
