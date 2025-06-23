import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nagar_vikas/screen/done_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GarbagePage extends StatefulWidget {
  const GarbagePage({super.key});

  @override
  GarbagePageState createState() => GarbagePageState();
}

class GarbagePageState extends State<GarbagePage> {
  String? _selectedState;
  String? _selectedCity;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  final Map<String, List<String>> _states = {
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Prayagraj'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Delhi': ['New Delhi', 'North Delhi', 'South Delhi'],
    // Add other states as needed
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestPermissions();
  }

  void _requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      Fluttertoast.showToast(
          msg: "Microphone permission is required for voice input.");
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (!mounted) return;
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _descriptionController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable location services.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    if (!mounted) return;

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      String address =
          "${place.subLocality}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

      setState(() {
        _locationController.text = address;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get address.");
      if (!mounted) return;
      setState(() {
        _locationController.text =
            "${position.latitude}, ${position.longitude}";
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    String cloudName = "dved2q851";
    String uploadPreset = "flutter_uploads";
    String cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imageFile.path),
      "upload_preset": uploadPreset,
    });

    try {
      Response response = await Dio().post(cloudinaryUrl, data: formData);
      return response.data["secure_url"];
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_selectedImage == null) {
      Fluttertoast.showToast(msg: "Please upload an image.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      if (imageUrl == null) throw Exception("Image upload failed.");

      DatabaseReference complaintsRef =
          FirebaseDatabase.instance.ref("complaints");
      await complaintsRef.push().set({
        'user_id': FirebaseAuth.instance.currentUser?.uid,
        'issue_type': "Garbage",
        'state': _selectedState,
        'city': _selectedCity,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'image_url': imageUrl,
        'timestamp': DateTime.now().toIso8601String(),
        'status': "Pending",
      });

      Fluttertoast.showToast(msg: "Complaint submitted successfully!");
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const DoneScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Error submitting complaint.");
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: const Duration(milliseconds: 1000),
          child: const Text(
            "Garbage lifting issue selected",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Please give accurate and correct information for a faster solution.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ZoomIn(
              duration: const Duration(milliseconds: 1200),
              child:
                  Image.asset("assets/selected.png", height: 210, width: 210),
            ),
            const SizedBox(height: 10),

            // State Dropdown
            DropdownButtonFormField<String>(
              value: _selectedState,
              hint: const Text("Select State"),
              items: _states.keys.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                  _selectedCity = null;
                });
              },
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 10),

            // City Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCity,
              hint: const Text("Select City"),
              items: _selectedState != null
                  ? _states[_selectedState]!.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 10),

            // Location TextField
            TextField(
              controller: _locationController,
              decoration: _inputDecoration().copyWith(
                hintText: "Enter location manually or click icon",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.black),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Description TextField
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration().copyWith(
                hintText: "Enter description with contact number or speak",
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.black),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Upload Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedImage == null
                      ? Border.all(color: Colors.red, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, color: Colors.black54),
                    const SizedBox(width: 10),
                    Text(
                      _selectedImage == null ? "Upload Image" : "Change Image",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.file(_selectedImage!, height: 100),
              ),

            const SizedBox(height: 10),

            // Submit Button
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isUploading || _selectedImage == null
                      ? Colors.grey
                      : Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed:
                    _selectedImage == null || _isUploading ? null : _submitForm,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
