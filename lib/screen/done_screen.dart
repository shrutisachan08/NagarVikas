import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    OneSignal.InAppMessages.addTrigger("complaint_done", "true");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/done.png', width: 350, height: 350), // Image
              SizedBox(height: 20),
              Text(
                "Done!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "We will get in touch with you if more information is required.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Text(
                "Please note that the estimated time for your issue to be resolved will be 10 to 12 hours. And if you placed complaint between 12PM-8AM then resolving time will start from the next morning ie. After 8AM.\n"
                "You can check your issue status in the My Complaints tab.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}