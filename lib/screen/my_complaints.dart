import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
//import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  MyComplaintsScreenState createState() => MyComplaintsScreenState();
}

class MyComplaintsScreenState extends State<MyComplaintsScreen> {
  List<Map<String, dynamic>> complaints = [];
  bool _isLoading = true;
  bool isAdmin = false;
  final Set<String> _updatingFlags = {}; // Track which flags are being updated

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _fetchComplaints();
  }

  void _checkAdmin() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          isAdmin = user != null &&
              user.email != null &&
              user.email!.toLowerCase().contains("gov");
        });
      }
    });
  }

  Future<void> _fetchComplaints() async {
    String? userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DatabaseReference ref = FirebaseDatabase.instance.ref('complaints/');

    // 🛠️ If admin, fetch all complaints
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        if (mounted) {
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

        // Parse timestamp logic...
        // 👇 Add only own complaints if not admin
        if (!isAdmin && complaint["user_id"] != userId) return;

        // then push to list
        loadedComplaints.add({
          "id": key,
          "issue": complaint["issue_type"]?.toString() ?? "Unknown Issue",
          "status": complaint["status"]?.toString() ?? "Pending",
          "isFlagged": complaint["isFlagged"] ?? false,
          "timestamp": complaint["timestamp"] ?? "",
          "location": complaint["location"]?.toString() ?? "Not Available",
          "city": complaint["city"]?.toString() ?? "Not Available",
          "state": complaint["state"]?.toString() ?? "Not Available",
        });
      });

      if (mounted) {
        setState(() {
          complaints = loadedComplaints;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _toggleFlag(String complaintId, bool currentValue) async {
    // Prevent multiple simultaneous updates
    if (_updatingFlags.contains(complaintId)) return;

    setState(() {
      _updatingFlags.add(complaintId);
    });

    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('complaints/$complaintId');
      await ref.update({'isFlagged': !currentValue});

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentValue
                  ? 'Complaint flagged for follow-up'
                  : 'Complaint unflagged',
            ),
            backgroundColor: !currentValue ? Colors.orange : Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      developer.log("Error toggling flag: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update flag. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingFlags.remove(complaintId);
        });
      }
    }
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
    return Icons.report_problem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 254, 254),
      appBar: AppBar(
        title: const Text("My Complaints"),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
        actions: [
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
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
                    final complaint = complaints[index];
                    final isUpdating = _updatingFlags.contains(complaint['id']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: complaint['isFlagged'] == true
                            ? Border.all(color: Colors.orange, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            complaint['status']),
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
                                        complaint['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (complaint['isFlagged'] == true)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "Follow-up",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (isAdmin)
                                  isUpdating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.orange),
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            complaint['isFlagged']
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: complaint['isFlagged']
                                                ? Colors.orange
                                                : Colors.grey,
                                          ),
                                          onPressed: () {
                                            _toggleFlag(
                                              complaint['id'],
                                              complaint['isFlagged'],
                                            );
                                          },
                                          tooltip: complaint['isFlagged']
                                              ? 'Remove from follow-up'
                                              : 'Mark for follow-up',
                                        ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  _getComplaintIcon(complaint['issue']),
                                  color: Colors.blueAccent,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    complaint['issue'],
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
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  complaint['date'],
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(width: 15),
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  complaint['time'],
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 18, color: Colors.redAccent),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${complaint['location']}, ${complaint['city']}, ${complaint['state']}",
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
