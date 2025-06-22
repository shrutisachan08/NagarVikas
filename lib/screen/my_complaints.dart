import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key}); // ✅ Fixed: Added named key parameter

  @override
  MyComplaintsScreenState createState() => MyComplaintsScreenState(); // ✅ Fixed: Made state class public
}

class MyComplaintsScreenState extends State<MyComplaintsScreen> { // ✅ Fixed: Made class public
  List<Map<String, dynamic>> complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DatabaseReference ref = FirebaseDatabase.instance.ref('complaints/');

    ref.orderByChild("user_id").equalTo(userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        if (mounted) { // ✅ Added mounted check
          setState(() {
            complaints = [];
            _isLoading = false;
          });
        }
        return;
      }

      List<Map<String, dynamic>> loadedComplaints = [];

      data.forEach((key, value) {
        final complaint = value as Map<dynamic, dynamic>;

        String rawTimestamp = complaint["timestamp"] ?? "";
        String formattedDate = "Unknown Date";
        String formattedTime = "Unknown Time";

        try {
          if (rawTimestamp.isNotEmpty) {
            DateTime dateTime = DateTime.parse(rawTimestamp);
            formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
            formattedTime = DateFormat('hh:mm a').format(dateTime);
          }
        } catch (e) {
          developer.log("Error parsing timestamp: $e"); // ✅ Fixed: Replaced print with developer.log
        }

        loadedComplaints.add({
          "issue": complaint["issue_type"]?.toString() ?? "Unknown Issue",
          "status": complaint["status"]?.toString() ?? "Pending",
          "date": formattedDate,
          "time": formattedTime,
          "location": complaint["location"]?.toString() ?? "Not Available",
          "city": complaint["city"]?.toString() ?? "Not Available",
          "state": complaint["state"]?.toString() ?? "Not Available",
        });
      });

      if (mounted) { // ✅ Added mounted check
        setState(() {
          complaints = loadedComplaints;
          _isLoading = false;
        });
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.red;
      case "in progress":
        return Colors.orange;
      case "resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getComplaintIcon(String issue) {
    if (issue.toLowerCase().contains("road")) {
      return Icons.directions_car;
    } else if (issue.toLowerCase().contains("water")) {
      return Icons.water_drop;
    } else if (issue.toLowerCase().contains("drainage")) {
      return Icons.plumbing;
    } else if (issue.toLowerCase().contains("garbage")) {
      return Icons.delete;
    } else if (issue.toLowerCase().contains("stray")) {
      return Icons.pets;
    } else if (issue.toLowerCase().contains("streetlights")) {
      return Icons.wb_incandescent;
    } else if (issue.toLowerCase().contains("new")) {
      return Icons.fiber_new;
    }
    return Icons.report_problem; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 254, 254),
      appBar: AppBar(
        title: const Text("My Complaints"),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/no_complaints.png', height: 150),
                      const SizedBox(height: 20),
                      const Text(
                        "No Complaints Raised Yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: complaints.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (ctx, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2), // ✅ Fixed: Replaced withOpacity with withValues
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Tag
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                      complaints[index]['status']),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  complaints[index]['status'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Title Row with Icon
                            Row(
                              children: [
                                Icon(
                                  _getComplaintIcon(complaints[index]['issue']),
                                  color: Colors.blueAccent,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    complaints[index]['issue'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Divider(color: Colors.grey[300]),

                            // Date & Time Row
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  complaints[index]['date'],
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(width: 15),
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  complaints[index]['time'],
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Location Row
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 18, color: Colors.redAccent),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${complaints[index]['location']}, ${complaints[index]['city']}, ${complaints[index]['state']}",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}