import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medx/auth/data/auth_repository.dart';
import 'package:medx/auth/data/auth_service.dart';
import 'package:medx/auth/logic/auth_controller.dart';
import 'package:medx/screens/add_medicine.dart';
import 'package:medx/screens/about_screen.dart';
import 'package:medx/services/medicine_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthController _authController;
  final MedicineService _medicineService = MedicineService();
  final User? user = FirebaseAuth.instance.currentUser;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _authController = AuthController(AuthRepository(AuthService()));
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', image.path);
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),
              accountName: Text(user!.displayName ?? "MedX User"),
              accountEmail: Text(user!.email ?? ""),
              currentAccountPicture: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF4A90E2),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await _authController.logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("MedX"),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _medicineService.getMedicines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No medicines added yet",
                style: TextStyle(
                    fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final medicines = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final doc = medicines[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('schedules')
                    .where('medicineId',
                        isEqualTo: doc.id)
                    .limit(1)
                    .get(),
                builder: (context, scheduleSnapshot) {
                  List<String> times = [];

                  if (scheduleSnapshot.hasData &&
                      scheduleSnapshot
                          .data!.docs.isNotEmpty) {
                    final scheduleData =
                        scheduleSnapshot
                                .data!.docs.first.data()
                            as Map<String, dynamic>;

                    times = List<String>.from(
                        scheduleData['times'] ?? []);
                  }

                  return Container(
                    margin: const EdgeInsets.only(
                        bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),
                          blurRadius: 8,
                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['name'] ?? '',
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.edit,
                                        color: Colors
                                            .blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (ctx) =>
                                                  AddMedicine(
                                            medicineId:
                                                doc.id,
                                            existingData:
                                                data,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete,
                                        color:
                                            Colors.red),
                                    onPressed:
                                        () async {
                                      await _medicineService
                                          .deleteMedicine(
                                              doc.id);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                              height: 6),
                          Text(
                            "${data['type']} • ${data['dosage']}",
                            style:
                                const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 12),
                          if (times.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: times
                                  .map(
                                    (time) =>
                                        Chip(
                                      label:
                                          Text(time),
                                      backgroundColor:
                                          const Color(
                                                  0xFF4A90E2)
                                              .withOpacity(
                                                  0.1),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFF4A90E2),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) =>
                  const AddMedicine(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label:
            const Text("Add Medicine"),
      ),
    );
  }
}
