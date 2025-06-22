import 'package:flutter/material.dart';

class ReferAndEarnPage extends StatelessWidget {
  final String referralCode = "NAGAR123";

  const ReferAndEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text("Refer & Earn"),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Invite Friends Text
            const Text(
              "Invite Your Friends!",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 10),

            Text(
              "Earn rewards by referring your friends to NagarVikas. Share your referral code now!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            const SizedBox(height: 20),

            // Referral Code Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent, width: 2),
              ),
              child: Text(
                referralCode,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
              ),
            ),

            const SizedBox(height: 20),

            // Share Button
            ElevatedButton.icon(
              onPressed: () {
                // Show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Referral code copied! Share it with your friends."),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color.fromARGB(255, 7, 7, 7),
                  ),
                );
              },
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Share Referral Code",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                backgroundColor: const Color.fromARGB(255, 7, 230, 107),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
     ),
    );
  }
}