import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Real-time stream of dashboard analytics
  Stream<Map<String, dynamic>> dashboardStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield {};
      return;
    }

    yield* _db
        .collection("users")
        .doc(user.uid)
        .collection("logs")
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      int taken = 0;
      int missed = 0;
      Map<DateTime, int> heatmap = {};

      final today = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final status = (data['status'] ?? '').toString().toLowerCase();
        final tsString = data['timestamp'] ?? '';

        if (tsString.isEmpty) continue;

        DateTime ts;
        try {
          ts = DateTime.parse(tsString);
        } catch (_) {
          continue;
        }

        final day = DateTime(ts.year, ts.month, ts.day);

        if (status == 'taken') {
          taken++;
          heatmap[day] = (heatmap[day] ?? 0) + 1;
        } else if (status == 'missed') {
          missed++;
        }
      }

      final total = taken + missed;
      final adherence = total > 0 ? (taken / total) * 100 : 0;

      // Consecutive streak calculation
      int streak = 0;
      for (int i = 0; i < 30; i++) {
        final day = DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: i));
        if (heatmap[day] != null && heatmap[day]! > 0) {
          streak++;
        } else {
          break;
        }
      }

      // Weekly aggregation for bar chart
      List<Map<String, int>> weekly =
          List.generate(7, (_) => {'taken': 0, 'missed': 0});
      for (int i = 0; i < 30; i++) {
        final day = DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: i));
        final weekdayIndex = day.weekday - 1;
        if (heatmap[day] != null && heatmap[day]! > 0) {
          weekly[weekdayIndex]['taken'] =
              (weekly[weekdayIndex]['taken'] ?? 0) + 1;
        } else {
          weekly[weekdayIndex]['missed'] =
              (weekly[weekdayIndex]['missed'] ?? 0) + 1;
        }
      }

      // Insight and risk assessment
      String insight;
      String risk;
      if (adherence > 90) {
        insight = "Excellent adherence! Keep it up.";
        risk = "Low";
      } else if (adherence > 70) {
        insight = "Good adherence. Try to avoid missing doses.";
        risk = "Medium";
      } else {
        insight = "Low adherence detected. Set reminders to improve.";
        risk = "High";
      }

      return {
        "taken": taken,
        "missed": missed,
        "adherence": adherence,
        "streak": streak,
        "heatmap": heatmap,
        "weekly": weekly,
        "insight": insight,
        "risk": risk,
      };
    });
  }
}