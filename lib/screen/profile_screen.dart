import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Loading...";
  String email = "Loading...";
  String userId = "Loading...";
  
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid);

      final snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
        setState(() {
          name = data?['name'] ?? "N/A";
          email = user.email ?? "N/A";
          userId = user.uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 3, 3, 3),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildProfileRow("Full Name", name),
            _buildProfileRow("Email", email),
            _buildProfileRow("User ID", userId),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          border: const OutlineInputBorder(),
        ),
     ),
);
}
}
