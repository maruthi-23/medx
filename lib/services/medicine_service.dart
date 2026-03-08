import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineService {
  final _firestore = FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<String> addMedicine({
    required String name,
    required String type,
    required String dosage,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('medicines')
          .add({
        'name': name,
        'type': type,
        'dosage': dosage,
        'createdAt': Timestamp.now(),
        'isActive': true,
      });
      return doc.id;
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }

  Future<void> editMedicine({
    required String medicineId,
    required String name,
    required String type,
    required String dosage,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('medicines')
          .doc(medicineId)
          .update({
        'name': name,
        'type': type,
        'dosage': dosage,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to edit medicine: $e');
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    if (_userId == null) throw Exception('User not authenticated');
    try {
      final schedules = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('schedules')
          .where('medicineId', isEqualTo: medicineId)
          .get();

      final batch = _firestore.batch();
      for (var doc in schedules.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore
          .collection('users')
          .doc(_userId!)
          .collection('medicines')
          .doc(medicineId));
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }

  Stream<QuerySnapshot> getMedicines() {
    if (_userId == null) return Stream.empty();
    return _firestore
        .collection('users')
        .doc(_userId!)
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
    if (_userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
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
    } catch (e) {
      throw Exception('Failed to add schedule: $e');
    }
  }

  Future<void> editSchedule({
    required String scheduleId,
    required String frequencyType,
    required List<String> times,
    List<int>? daysOfWeek,
    int? intervalHours,
    required bool reminderEnabled,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
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
    } catch (e) {
      throw Exception('Failed to edit schedule: $e');
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    if (_userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('schedules')
          .doc(scheduleId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Stream<QuerySnapshot> getLogs() {
    if (_userId == null) return Stream.empty();
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
