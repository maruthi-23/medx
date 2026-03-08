import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text("About MedX"),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            /// App Logo / Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_rounded,
                size: 50,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            /// App Title
            const Text(
              "MedX",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Smart Medicine Reminder",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// Description Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  "MedX helps users manage their daily medication schedule easily. "
                  "The app provides smart reminders so that no medicine dose is missed. "
                  "Your data is securely stored using Firebase to ensure reliability "
                  "and accessibility across devices.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Features
            _featureTile(
              Icons.notifications_active_outlined,
              "Smart Reminders",
              "Get timely notifications for medicines",
            ),

            const SizedBox(height: 12),

            _featureTile(
              Icons.medication_outlined,
              "Medicine Management",
              "Add, edit, and manage medicines easily",
            ),

            const SizedBox(height: 12),

            _featureTile(
              Icons.security_outlined,
              "Secure Data",
              "User data stored safely using Firebase",
            ),

            const SizedBox(height: 30),

            /// Version
            const Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  static Widget _featureTile(IconData icon, String title, String subtitle) {

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}