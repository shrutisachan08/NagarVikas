// 📦 Importing necessary packages and screens
 fix/no-complaints-message
//import 'package:nagar_vikas/service/connectivity_overlay.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nagar_vikas/screen/register_screen.dart';
import 'package:nagar_vikas/screen/admin_dashboard.dart';
import 'package:nagar_vikas/screen/login_page.dart' as login;
=======
import 'package:NagarVikas/service/ConnectivityService.dart';
import 'package:NagarVikas/widgets/bottom_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:NagarVikas/screen/register_screen.dart';
import 'package:NagarVikas/screen/admin_dashboard.dart';
import 'package:NagarVikas/screen/login_page.dart';
main
import 'package:flutter/foundation.dart';
//import 'package:nagar_vikas/screen/logo.dart' as logo;
import 'dart:async';
import 'dart:developer' as developer;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
 fix/no-complaints-message
import 'package:nagar_vikas/theme/theme_provider.dart';
import 'package:NagarVikas/theme/theme_provider.dart';
 main

// 🔧 Background message handler for Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log("Handling a background message: ${message.messageId}");
}

void main() async {
  // ✅ Ensures Flutter is initialized before any Firebase code
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ OneSignal push notification setup
  OneSignal.initialize("70614e6d-8bbf-4ac1-8f6d-b261a128059c");
  OneSignal.Notifications.requestPermission(true);

  // ✅ Set up notification opened handler
  OneSignal.Notifications.addClickListener((event) {
    developer.log("Notification Clicked: ${event.notification.body}");
  });

  // ✅ Firebase initialization for Web and Mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCjaGsLVhHmVGva75FLj6PiCv_Z74wGap4",
        authDomain: "nagarvikas-a1d4f.firebaseapp.com",
        projectId: "nagarvikas-a1d4f",
        storageBucket: "nagarvikas-a1d4f.firebasestorage.app",
        messagingSenderId: "847955234719",
        appId: "1:847955234719:web:ac2b6da7a3a0715adfb7aa",
        measurementId: "G-ZZMV642TW3",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  // ✅ Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Initialize connectivity service (if available)
  try {
    // Uncomment this line when ConnectivityService is properly implemented
    // await ConnectivityService().initialize();
  } catch (e) {
    developer.log("ConnectivityService not available: $e");
  }

  // ✅ Run the app
fix/no-complaints-message
  await ConnectivityService().initialize();
 main
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// ✅ Main Application Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NagarVikas',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
 fix/no-complaints-message
      // Use ConnectivityOverlay if available, otherwise use AuthCheckScreen directly
      home: const AuthCheckScreen(),
      // Uncomment below line when ConnectivityOverlay is properly implemented
      // home: ConnectivityOverlay(child: const AuthCheckScreen()),

      home: ConnectivityOverlay(child: const AuthCheckScreen()),
main
    );
  }
}

// ✅ Auth Check Screen (Decides User/Admin Navigation)
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  AuthCheckScreenState createState() => AuthCheckScreenState();
}

// ✅ State for Auth Check Screen
class AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _showSplash = true;
  firebase_auth.User? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkLastLogin();

    // ✅ Listen for authentication state changes
    firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebase_auth.User? newUser) {
      if (mounted) {
        setState(() {
          user = newUser;
        });
      }
    });

    // ✅ Splash screen timer
    Timer(const Duration(seconds: 9), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  // ✅ Check Last Login
  Future<void> _checkLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool? storedIsAdmin = prefs.getBool('isAdmin');

    if (storedIsAdmin != null && mounted) {
      setState(() {
        isAdmin = storedIsAdmin;
      });
    }
  }

  // ✅ Build Method (Decides Which Screen to Show)
  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    // ✅ Redirect Based on Last Login
    if (user == null) {
      return const WelcomeScreen();
    } else {
      if (isAdmin && user!.email?.contains("gov") == true) {
 fix/no-complaints-message
        return const AdminDashboard();
      } else {
        // Return a placeholder home screen since BottomNavBar doesn't exist
        return const HomeScreen();

        return AdminDashboard();
      } else {
        return const BottomNavBar();
 main
      }
    }
  }
}

// ✅ Placeholder Home Screen (Replace with your actual home screen)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleLogout(context),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Welcome to NagarVikas!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your civic complaint management app',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Admin Login Function
Future<void> handleAdminLogin(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAdmin', true);
  
  if (context.mounted) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
  }
}

// ✅ Logout Function
Future<void> handleLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
 fix/no-complaints-message
  await prefs.remove('isAdmin');
  await firebase_auth.FirebaseAuth.instance.signOut();
  
  if (context.mounted) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const login.LoginPage()));
  }

  await prefs.remove('isAdmin'); // ✅ Clear admin status
  await firebase_auth.FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
      // ✅ Redirect to Login Page
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginPage())); // ✅ Fix: Use const for LoginPage to avoid unnecessary rebuilds
main
}

/// SplashScreen - displays an animated logo on app launch
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo Animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // App Name
            const Text(
              'NagarVikas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Welcome Screen shown before registration
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
 fix/no-complaints-message
  WelcomeScreenState createState() => WelcomeScreenState();
  _WelcomeScreenState createState() => _WelcomeScreenState();
main
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  void _onGetStartedPressed() {
    setState(() {
      _isLoading = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        ).then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => SwitchListTile(
                title: const Text("Dark Mode"),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: const Icon(Icons.dark_mode),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => handleLogout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Top Circle Animation
            Align(
              alignment: Alignment.topLeft,
              child: ZoomIn(
                duration: const Duration(milliseconds: 1200),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 133, 207, 239).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Main Image Animation - Using placeholder since asset might not exist
            ZoomIn(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.report_problem,
                  size: 150,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Headline & Subtext
            FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: const Column(
                children: [
                  Text(
                    "Facing Civic Issues?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
fix/no-complaints-message
                  SizedBox(height: 10),
                  Text(
                  const SizedBox(
                      height: 10), // Space between heading and subtext
                  const Text(
 main
                    "Register your complaint now and\nget it done in few time..",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // ✅ Get Started Button
            FadeInUp(
fix/no-complaints-message
              // Animation for button
              main
              duration: const Duration(milliseconds: 1600),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onGetStartedPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 8, 8, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
 fix/no-complaints-message
                ),

                ), // ✅ Button style
 main
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Get Started",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}