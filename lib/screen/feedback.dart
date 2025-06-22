import 'package:flutter/material.dart';

/// 📝 FeedbackPage
/// Allows users to rate the app, leave written feedback, and optionally provide suggestions.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  // ⭐ User rating value (0.0 to 5.0)
  double _rating = 0.0;

  // 🖊️ Controller for feedback input
  final TextEditingController _feedbackController = TextEditingController();

  // ✅ Checkbox state for suggestions
  bool _suggestions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: const Color.fromARGB(255, 4, 204, 240),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTitleText('How do you feel about the app?'),
            const SizedBox(height: 20),
            _buildRatingBar(),
            const SizedBox(height: 25),
            _buildTitleText('Describe your experience:'),
            const SizedBox(height: 15),
            _buildFeedbackTextField(),
            const SizedBox(height: 25),
            _buildSuggestionsCheckbox(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color: _rating > index ? Colors.amber : Colors.grey,
            size: 35,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
        );
      }),
    );
  }

  Widget _buildFeedbackTextField() {
    return TextField(
      controller: _feedbackController,
      maxLines: 5,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: 'Share your thoughts...',
        hintStyle: const TextStyle(color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildSuggestionsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _suggestions,
          onChanged: (bool? value) {
            setState(() {
              _suggestions = value ?? false;
            });
          },
          activeColor: Colors.amber,
        ),
        const Expanded(
          child: Text(
            'Would you like to give any suggestion?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitFeedback,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text('Submit Feedback'),
    );
  }

  void _submitFeedback() {
    final String feedback = _feedbackController.text;

    // 🧾 Logging using debugPrint (use logger package in production)
    debugPrint('Rating: $_rating');
    debugPrint('Feedback: $feedback');
    debugPrint('Suggestions: $_suggestions');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thank You!'),
          content: const Text('Your feedback has been submitted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
