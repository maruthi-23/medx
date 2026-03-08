import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medx/screens/dashboard_screen.dart';
import 'package:medx/screens/add_medicine.dart';
import 'package:medx/screens/about_screen.dart';
import 'package:medx/services/medicine_service.dart';
import 'package:medx/services/notification_service.dart';
import 'package:medx/auth/data/auth_repository.dart';
import 'package:medx/auth/data/auth_service.dart';
import 'package:medx/auth/logic/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final MedicineService _medicineService = MedicineService();
  late AuthController _authController;
  final ImagePicker _picker = ImagePicker();

  User? get user => FirebaseAuth.instance.currentUser;
  File? _profileImage;
  String _userName = "User";
  StreamSubscription<QuerySnapshot>? _logSubscription;
  String? _lastLogId;

  late AnimationController _animationController;

  // Feature cards data
  final List<Map<String, dynamic>> _featureCards = [
    {
      "icon": Icons.alarm,
      "title": "Never Miss Medicine",
      "desc": "Smart reminders help you stay on track",
      "color": Colors.blue,
    },
    {
      "icon": Icons.medication,
      "title": "Track Your Pills",
      "desc": "Monitor your medication schedule easily",
      "color": Colors.orange,
    },
    {
      "icon": Icons.insights,
      "title": "Health Insights",
      "desc": "Visualize your health progress daily",
      "color": Colors.green,
    },
    {
      "icon": Icons.favorite,
      "title": "Stay Healthy",
      "desc": "Maintain a consistent health routine",
      "color": Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _authController = AuthController(AuthRepository(AuthService()));
    _loadProfile();
    _listenToLogs();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = user;
      if (currentUser == null) return;
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${currentUser.uid}');
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) _profileImage = file;
      }
      final name = prefs.getString('profile_name_${currentUser.uid}');
      if (name != null && name.isNotEmpty) _userName = name;
      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint("Error loading profile: $e\n$st");
    }
  }

  Future<void> _saveName(String name) async {
    final currentUser = user;
    if (currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name_${currentUser.uid}', name);
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _pickImage() async {
    final currentUser = user;
    if (currentUser == null) return;
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_${currentUser.uid}', image.path);
    if (mounted) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _listenToLogs() {
    final currentUser = user;
    if (currentUser == null) return;

    _logSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      if (_lastLogId == doc.id) return;
      _lastLogId = doc.id;

      final data = doc.data();
      final status = (data['status'] ?? '').toString().toLowerCase();

      if (status == "taken") {
        NotificationService.show(
          title: "Medicine Taken",
          body: "Great! You took your medicine.",
        );
      } else if (status == "missed") {
        NotificationService.show(
          title: "Medicine Missed",
          body: "You missed your medicine.",
        );
      }
    });
  }

  void _editNameDialog() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) _saveName(name);
                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) return const Scaffold(body: Center(child: Text("User not logged in")));

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      drawer: _buildDrawer(),
      appBar: AppBar(centerTitle: true, title: const Text("MedX")),
      body: Column(
        children: [
          _animatedFeatureCardsGrid(),
          Expanded(child: _medicineList(currentUser.uid)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicine())),
        icon: const Icon(Icons.add),
        label: const Text("Add Medicine"),
      ),
    );
  }

  Widget _animatedFeatureCardsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _featureCards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3 / 1.5,
        ),
        itemBuilder: (context, index) {
          final card = _featureCards[index];
          final animation = Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeOut),
            ),
          );
          final opacity = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeIn),
            ),
          );

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: opacity.value,
                child: Transform.translate(offset: animation.value, child: child),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: card['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: card['color'],
                    child: Icon(card['icon'], size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card['title'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(card['desc'],
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _medicineList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('medicines').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _emptyState();

        final medicines = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final doc = medicines[index];
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return _MedicineCard(
              medicineId: doc.id,
              data: data,
              onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedicine(medicineId: doc.id, existingData: data))),
              onDelete: () async => await _medicineService.deleteMedicine(doc.id),
            );
          },
        );
      },
    );
  }

  Widget _emptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text("No medicines added yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );

  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null ? const Icon(Icons.person, size: 36, color: Colors.blue) : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _editNameDialog,
                    child: Row(
                      children: [
                        Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(user?.email ?? "", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text("Analytics"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async => await _authController.logout(),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final String medicineId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicineId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.medication, color: Colors.blue),
        ),
        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${data['type'] ?? ''} • ${data['dosage'] ?? ''}"),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == "edit") onEdit();
            if (v == "delete") onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: "edit", child: Text("Edit")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
      ),
    );
  }
}