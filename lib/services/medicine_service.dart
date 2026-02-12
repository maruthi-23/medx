import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineService {
  final _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser!.uid;

  Future<String> addMedicine({
    required String name,
    required String type,
    required String dosage,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .add({
      'name': name,
      'type': type,
      'dosage': dosage,
      'createdAt': Timestamp.now(),
      'isActive': true,
    });

    return doc.id;
  }

  Future<void> editMedicine({
    required String medicineId,
    required String name,
    required String type,
    required String dosage,
  }) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .doc(medicineId)
        .update({
      'name': name,
      'type': type,
      'dosage': dosage,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteMedicine(String medicineId) async {
    final schedules = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedules')
        .where('medicineId', isEqualTo: medicineId)
        .get();

    for (var doc in schedules.docs) {
      await doc.reference.delete();
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .doc(medicineId)
        .delete();
  }

  Stream<QuerySnapshot> getMedicines() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addSchedule({
    required String medicineId,
    required String frequencyType,
    required List<String> times,
    List<int>? daysOfWeek,
    int? intervalHours,
    required bool reminderEnabled,
  }) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedules')
        .add({
      'medicineId': medicineId,
      'frequencyType': frequencyType,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'intervalHours': intervalHours,
      'reminderEnabled': reminderEnabled,
      'createdAt': Timestamp.now(),
      'isActive': true,
    });
  }

  Future<void> editSchedule({
    required String scheduleId,
    required String frequencyType,
    required List<String> times,
    List<int>? daysOfWeek,
    int? intervalHours,
    required bool reminderEnabled,
  }) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedules')
        .doc(scheduleId)
        .update({
      'frequencyType': frequencyType,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'intervalHours': intervalHours,
      'reminderEnabled': reminderEnabled,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedules')
        .doc(scheduleId)
        .delete();
  }
}
