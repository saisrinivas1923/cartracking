import 'package:flutter/material.dart';

import '../services/export_services.dart';

class PopupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 420, // Adjust the height as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 15,
                ),
                Text(
                  LocalizationHelper.of(context).translate('devby'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                //Spacer(),
              ],
            ),
            const SizedBox(height: 0.0),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(child: Text("SS")),
                    title: Text("SaiSrinivas"),
                    subtitle: Text(LocalizationHelper.of(context).translate('TeamMember')),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text("SR")),
                    title: Text("SriRam Reddy S"),
                    subtitle: Text(LocalizationHelper.of(context).translate('TeamMember')),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text("VR")),
                    title: Text("Vikas Reddy Mallidi"),
                    subtitle: Text(LocalizationHelper.of(context).translate('TeamMember')),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text("DR")),
                    title: Text("Deekshith Reddi"),
                    subtitle: Text(LocalizationHelper.of(context).translate('TeamMember')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}