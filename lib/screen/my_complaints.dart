import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class MyComplaintsScreen extends StatefulWidget {
  @override
  _MyComplaintsScreenState createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  List<Map<String, dynamic>> complaints = [];
  List<Map<String, dynamic>> filteredComplaints = [];
  TextEditingController searchController = TextEditingController();

  bool _isLoading = true;
  String selectedStatus = 'All';
  bool showOnlyFlagged = false; // Add filter for flagged complaints
  bool _isAdmin = false; // Track if current user is admin
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _fetchComplaints();
  }

  // Check if current user is admin
  Future<void> _checkUserRole() async {
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$currentUserId');
    DataSnapshot snapshot = await userRef.get();
    
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _isAdmin = userData['role']?.toString().toLowerCase() == 'admin';
      });
    }
  }

  Future<void> _fetchComplaints() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DatabaseReference ref = FirebaseDatabase.instance.ref('complaints/');

    ref.orderByChild("user_id").equalTo(userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        setState(() {
          complaints = [];
          filteredComplaints = [];
          _isLoading = false;
        });
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
          print("Error parsing timestamp: $e");
        }

        loadedComplaints.add({
          "id": key, // Add complaint ID for database operations
          "issue": complaint["issue_type"]?.toString() ?? "Unknown Issue",
          "status": complaint["status"]?.toString() ?? "Pending",
          "date": formattedDate,
          "time": formattedTime,
          "location": complaint["location"]?.toString() ?? "Not Available",
          "city": complaint["city"]?.toString() ?? "Not Available",
          "state": complaint["state"]?.toString() ?? "Not Available",
          "is_flagged": complaint["is_flagged"] ?? false, // Add flagged status
          "flaggedBy": complaint["flaggedBy"] ?? "", // Track who flagged it
          "flaggedAt": complaint["flaggedAt"] ?? "", // Track when it was flagged
        });
      });

      setState(() {
        complaints = loadedComplaints;
        _applyFilters();
        _isLoading = false;
      });
    });
  }

  void _applyFilters() {
    String query = searchController.text;
    setState(() {
      filteredComplaints = complaints.where((complaint) {
        final matchesStatus = selectedStatus == 'All' ||
            complaint['status'].toString().toLowerCase() == selectedStatus.toLowerCase();
        final matchesQuery = query.isEmpty ||
            complaint.values.any((value) =>
                value.toString().toLowerCase().contains(query.toLowerCase()));
        final matchesFlagFilter = !showOnlyFlagged || (complaint['is_flagged'] == true);
        return matchesStatus && matchesQuery && matchesFlagFilter;
      }).toList();
    });
  }

  // Toggle flag status (Admin only)
  Future<void> _toggleFlag(String complaintId, bool currentFlagStatus) async {
    if (!_isAdmin || currentUserId == null) {
      _showSnackBar("Only admins can flag/unflag complaints", Colors.red);
      return;
    }

    try {
      DatabaseReference complaintRef = FirebaseDatabase.instance.ref('complaints/$complaintId');
      
      bool newFlagStatus = !currentFlagStatus;
      
      Map<String, dynamic> updateData = {
        'is_flagged': newFlagStatus,
      };

      if (newFlagStatus) {
        // Add flag metadata when flagging
        updateData['flaggedBy'] = currentUserId;
        updateData['flaggedAt'] = DateTime.now().toIso8601String();
      } else {
        // Remove flag metadata when unflagging
        updateData['flaggedBy'] = null;
        updateData['flaggedAt'] = null;
      }

      await complaintRef.update(updateData);

      _showSnackBar(
        newFlagStatus ? "Complaint flagged for follow-up" : "Flag removed from complaint",
        Colors.green
      );

    } catch (e) {
      print("Error toggling flag: $e");
      _showSnackBar("Failed to update flag status", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
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
        title: Text("My Complaints"),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
        actions: [
          if (_isAdmin)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "ADMIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/no_complaints.png', height: 150),
                      SizedBox(height: 20),
                      Text(
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Search and Status Filter Row
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (val) => _applyFilters(),
                                  decoration: InputDecoration(
                                    hintText: 'Search complaints...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              DropdownButton<String>(
                                value: selectedStatus,
                                items: [
                                  'All',
                                  'Pending',
                                  'In Progress',
                                  'Resolved',
                                ].map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedStatus = value;
                                    });
                                    _applyFilters();
                                  }
                                },
                              ),
                            ],
                          ),
                          
                          // Flagged Filter Row (Admin only)
                          if (_isAdmin) ...[
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Show only flagged complaints",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  Switch(
                                    value: showOnlyFlagged,
                                    onChanged: (value) {
                                      setState(() {
                                        showOnlyFlagged = value;
                                      });
                                      _applyFilters();
                                    },
                                    activeColor: Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchComplaints,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredComplaints.length,
                          padding: EdgeInsets.all(10),
                          itemBuilder: (ctx, index) {
                            final complaint = filteredComplaints[index];
                            bool isFlagged = complaint['is_flagged'] ?? false;
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: isFlagged ? Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: isFlagged 
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Row: Flag Button and Status Tag
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Flag Button (Admin only)
                                        if (_isAdmin)
                                          GestureDetector(
                                            onTap: () => _toggleFlag(
                                              complaint['id'],
                                              isFlagged,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isFlagged 
                                                    ? Colors.orange.withOpacity(0.2)
                                                    : Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isFlagged ? Icons.flag : Icons.flag_outlined,
                                                    color: isFlagged ? Colors.orange : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  if (isFlagged) ...[
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "Flagged",
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          )
                                        else if (isFlagged)
                                          // Show flag icon for non-admin users if flagged
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.flag,
                                                  color: Colors.orange,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Follow-up",
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          SizedBox.shrink(),
                                        
                                        // Status Tag
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                complaint['status']),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            complaint['status'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    // Title Row with Icon
                                    Row(
                                      children: [
                                        Icon(
                                          _getComplaintIcon(
                                              complaint['issue']),
                                          color: Colors.blueAccent,
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            complaint['issue'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 10),
                                    Divider(color: Colors.grey[300]),

                                    // Date & Time Row
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 16,
                                            color: Colors.grey[600]),
                                        SizedBox(width: 5),
                                        Text(
                                          complaint['date'],
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                        SizedBox(width: 15),
                                        Icon(Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600]),
                                        SizedBox(width: 5),
                                        Text(
                                          complaint['time'],
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    // Location Row
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 18,
                                            color: Colors.redAccent),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            "${complaint['location']}, ${complaint['city']}, ${complaint['state']}",
                                            style: TextStyle(
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
                      ),
                    ),
                  ],
                ),
    );
  }
}