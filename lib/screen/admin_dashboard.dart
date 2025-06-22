// AdminDashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'
 fix/no-complaints-message
import 'dart:async';
import './ComplaintDetailPage.dart';
 main
import 'login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

 fix/no-complaints-message
class AdminDashboardState extends State<AdminDashboard> {

class _AdminDashboardState extends State<AdminDashboard> {
  main
  int totalComplaints = 0;
  int pendingComplaints = 0;
  int inProgressComplaints = 0;
  int resolvedComplaints = 0;
 fix/no-complaints-message
  List<Map<String, dynamic>> complaints = [];
  List<Map<String, dynamic>> filteredComplaints = [];

  List<Map<String, dynamic>> complaints = [];
  List<Map<String, dynamic>> filteredComplaints = [];

 main
  TextEditingController searchController = TextEditingController();
  StreamSubscription? _complaintsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
fix/no-complaints-message
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    searchController.dispose();
    super.dispose();
    main
  }

  Future<void> _fetchComplaints() async {
    DatabaseReference complaintsRef = FirebaseDatabase.instance.ref('complaints');
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');

    _complaintsSubscription = complaintsRef.onValue.listen((complaintEvent) async {
      if (!mounted) return;

      final complaintData = complaintEvent.snapshot.value as Map<dynamic, dynamic>?;

      if (complaintData == null) {
 fix/no-complaints-message
        if (!mounted) return;
        setState(() {
          totalComplaints = pendingComplaints = inProgressComplaints = resolvedComplaints = 0;
          complaints = [];
          filteredComplaints = [];
        });
        if (mounted) {
          setState(() {
            totalComplaints = pendingComplaints = inProgressComplaints = resolvedComplaints = 0;
            complaints = [];
            filteredComplaints = [];
          });
        }
 main
        return;
      }

      List<Map<String, dynamic>> loadedComplaints = [];
      int pending = 0, inProgress = 0, resolved = 0, total = 0;

      for (var entry in complaintData.entries) {
        final complaint = entry.value as Map<dynamic, dynamic>;
        String userId = complaint["user_id"] ?? "Unknown";

        DataSnapshot userSnapshot = await usersRef.child(userId).get();
        Map<String, dynamic>? userData = userSnapshot.value != null
            ? Map<String, dynamic>.from(userSnapshot.value as Map)
            : null;

        String status = complaint["status"]?.toString() ?? "Pending";
        if (status == "Pending") pending++;
        if (status == "In Progress") inProgress++;
        if (status == "Resolved") resolved++;
        total++;

        String timestamp = complaint["timestamp"] ?? "Unknown";
        String date = "Unknown", time = "Unknown";

        if (timestamp != "Unknown") {
          DateTime dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
          date = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
          time = "${dateTime.hour}:${dateTime.minute}";
        }

fix/no-complaints-message
        String? mediaUrl = complaint["media_url"] ?? complaint["image_url"] ?? "";
        String mediaType = (complaint["media_type"] ??
            (complaint["image_url"] != null ? "image" : "video"))
            .toString()
            .toLowerCase();

main
        loadedComplaints.add({
          "id": entry.key,
          "issue_type": complaint["issue_type"] ?? "Unknown",
          "city": complaint["city"] ?? "Unknown",
          "state": complaint["state"] ?? "Unknown",
          "location": complaint["location"] ?? "Unknown",
          "description": complaint["description"] ?? "No description",
          "date": date,
          "time": time,
          "status": status,
          "media_url": (mediaUrl ?? '').isEmpty ? 'https://picsum.photos/250?image=9' : mediaUrl,
          "media_type": mediaType,
          "user_id": userId,
          "user_name": userData?["name"] ?? "Unknown",
          "user_email": userData?["email"] ?? "Unknown",
        });
      }

 fix/no-complaints-message
      if (!mounted) return;
      setState(() {
        totalComplaints = total;
        pendingComplaints = pending;
        inProgressComplaints = inProgress;
        resolvedComplaints = resolved;
        complaints = loadedComplaints;
        filteredComplaints = complaints;
      });
      if (mounted) {
        setState(() {
          totalComplaints = total;
          pendingComplaints = pending;
          inProgressComplaints = inProgress;
          resolvedComplaints = resolved;
          complaints = loadedComplaints;
          filteredComplaints = complaints;
        });
      }
      main
    });
  }

  void _searchComplaints(String query) {
    setState(() {
      filteredComplaints = complaints.where((complaint) {
        return complaint.values.any((value) =>
            value.toString().toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

 fix/no-complaints-message
  void _updateComplaintStatus(String complaintId, String newStatus) {
    FirebaseDatabase.instance.ref('complaints/$complaintId').update({"status": newStatus});
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              // Store the navigator context before async operation
              final navigator = Navigator.of(context);
              
              await FirebaseAuth.instance.signOut();
              
              // Check if widget is still mounted before using navigator
              if (mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()), 
                  (route) => false
                );
              }
            },
            child: const Text("Yes"),
          ),
        ],
      ),

  Route _createSlideRoute(Map<String, dynamic> complaint) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ComplaintDetailPage(complaintId: complaint["id"]),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
 main
    );
  }

  @override
  Widget build(BuildContext context) {
 fix/no-complaints-message
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: const Color.fromARGB(255, 4, 204, 240),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search complaints...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _searchComplaints,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredComplaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text("No Complaints Found",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text(
                              searchController.text.isNotEmpty
                                  ? "Try adjusting your search criteria"
                                  : "There are no complaints to display",
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredComplaints.length,
                        itemBuilder: (ctx, index) {
                          final complaint = filteredComplaints[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              leading: complaint["image_url"].isNotEmpty
                                  ? Image.network(complaint["image_url"], width: 80, height: 80, fit: BoxFit.cover)
                                  : Icon(Icons.image_not_supported, size: 50),
                              title: Text(complaint["issue_type"], style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("User: ${complaint["user_name"]} (${complaint["user_email"]})"),
                                  Text("Status: ${complaint["status"]}"),
                                  Text("Date: ${complaint["date"]}  Time: ${complaint["time"]}"),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () => _showComplaintDetails(context, complaint),
                            ),
                          );
                        },
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search complaints...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // updated
                ),
                onChanged: _searchComplaints,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredComplaints.length,
                itemBuilder: (ctx, index) {
                  final complaint = filteredComplaints[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: complaint["media_type"] == "image"
                          ? ClipOval(
                        child: Image.network(
                          complaint["media_url"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                          : const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.videocam, color: Colors.white),
                      ),
                      title: Text(
                        complaint["issue_type"] ?? "Unknown",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Status: ${complaint["status"]}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).push(
                        _createSlideRoute(complaint),
main
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
 fix/no-complaints-message

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> complaint) {
    String selectedStatus = complaint["status"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(complaint["issue_type"], style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  complaint["image_url"].isNotEmpty
                      ? Image.network(complaint["image_url"], height: 200, fit: BoxFit.cover)
                      : Icon(Icons.image_not_supported, size: 100),
                  const SizedBox(height: 10),
                  Text("📍 Location:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${complaint["location"]}, ${complaint["city"]}, ${complaint["state"]}"),
                  const SizedBox(height: 10),
                  Text("📅 Date & Time:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${complaint["date"]} at ${complaint["time"]}"),
                  const SizedBox(height: 10),
                  Text("👤 User:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${complaint["user_name"]} (${complaint["user_email"]})"),
                  const SizedBox(height: 10),
                  Text("📝 Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(complaint["description"], style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 10),
                  Text("🔄 Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: selectedStatus,
                    items: ["Pending", "In Progress", "Resolved"]
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _updateComplaintStatus(complaint["id"], newStatus);
                        setState(() {
                          selectedStatus = newStatus;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          );
        },
      ),
    );
  }
}
}
main
