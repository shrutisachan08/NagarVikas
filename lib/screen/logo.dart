// 📦 Required packages and internal imports
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:NagarVikas/screen/issue_selection.dart';
import 'package:NagarVikas/screen/register_screen.dart';
import 'package:NagarVikas/screen/admin_dashboard.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🧩 Stateful widget for login page
class LoginPage extends StatefulWidget {
 const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// 🧠 Login page logic and UI state
class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 📝 Controllers for email and password input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ⏳ Loading state to show progress indicator
  bool isLoading = false;

  /// Handles user authentication and redirects based on role (admin or regular user)
  Future<void> _loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter both email and password");
        setState(() => isLoading = false);
        return;
      }

      // 🔓 Firebase email/password login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // ✅ Check if email is verified
      if (user != null && !user.emailVerified) {
        Fluttertoast.showToast(
            msg: "Please verify your email before logging in.");
        await _auth.signOut();
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      if (mounted) {
        Fluttertoast.showToast(msg: "Login Successful!");
      }

      // 🛂 If user is an admin (email contains "gov"), show PIN dialog
      if (email.contains("gov")) {
        await Future.delayed(const Duration(milliseconds: 3000));
        if (mounted) {
          _showAdminPinDialog(email);
        }
      } else {
        // 👉 Navigate to issue selection page for regular users
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IssueSelectionPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
            msg: e.message ?? "Login failed. Please try again.");
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "An unexpected error occurred.");
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔐 Displays PIN prompt for admin verification before accessing dashboard
  void _showAdminPinDialog(String email) {
    if (!mounted) return;
    TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Admin Authentication"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Admin PIN to access the dashboard."),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter 4-digit PIN",
                ),
              ),
            ],
          ),
          actions: [
            // ❌ Cancel button to close dialog
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            // ✅ Submit button to verify PIN
            TextButton(
              onPressed: () async {
                if (pinController.text == "2004") {
                  // Store references to contexts before async operations
                  final navigator = Navigator.of(dialogContext);
                  final mainNavigator = Navigator.of(context);
                  
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool("isAdmin", true);
                  
                  // Use stored navigator references instead of contexts
                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                  
                  // Use stored navigator reference and check mounted state
                  if (mounted) {
                    mainNavigator.pushReplacement(
                      MaterialPageRoute(builder: (context) => const AdminDashboard()),
                    );
                  }
                } else {
                  // 🔒 Handle incorrect PIN entry
                  Fluttertoast.showToast(msg: "Incorrect PIN! Access Denied.");
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // 🔑 Forgot password logic using Firebase reset email
  Future<void> _forgotPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email to reset password.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Password reset link sent to $email");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending reset email.");
    }
  }

  // 🧱 UI layout and animations 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),

            // 👋 Welcome text with fade-in effect
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),

            // 🖼️ Login illustration with entry animation for better UX
            ZoomIn(
              duration: const Duration(milliseconds: 1200),
              child: Image.asset("assets/login.png", height: 250, width: 250),
            ),
            const SizedBox(height: 30),

            // 📧 Email input field
            FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.black87),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 🔒 Password input field with fade-in effect
            FadeInUp(
              duration: const Duration(milliseconds: 1300),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            // ❓ Forgot password button with fade-in effect
            FadeInUp(
              duration: const Duration(milliseconds: 1300),
              child: Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🚪 Login button with fade-in effect
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : _loginUser,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            // 🆕 Signup navigation with fade-in effect
            FadeInUp(
              duration: const Duration(milliseconds: 1500),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                },
                child: const Text(
                  "Don't have an account? Signup",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
     ),
);
}
}