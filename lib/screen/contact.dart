import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String phoneNumber = "+917307858026";  // Replace with your phone number
  final String email = "support@nagarvikas.com";

  const ContactUsPage({super.key});  // Replace with your support email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you have any questions or need assistance, feel free to contact us:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 20),
            _buildContactTile(
              icon: Icons.phone,
              text: phoneNumber,
              onTap: () => _launchPhoneDialer(),
            ),
            SizedBox(height: 20),
            _buildContactTile(
              icon: Icons.email,
              text: email,
              onTap: () => _launchEmailClient(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({required IconData icon, required String text, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        color: Colors.amberAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(15.0),
          leading: Icon(icon, color: Colors.black, size: 30),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Function to launch the phone dialer
  _launchPhoneDialer() async {
    final phoneUrl = 'tel:$phoneNumber'; // tel: URL scheme for phone calls
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);  // Launch the phone dialer
    } else {
      throw 'Could not launch $phoneUrl';  // Handle error if dialing fails
    }
  }

  // Function to launch the email client
  _launchEmailClient() async {
    final emailUrl = 'mailto:$email'; // mailto: URL scheme for email
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);  // Launch the email client
    } else {
      throw 'Could not launch $emailUrl';  // Handle error if email client fails
}
}
}
