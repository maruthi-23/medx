import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medx/services/analytics_service.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AnalyticsService _analytics = AnalyticsService();

  bool loading = true;

  double adherence = 0;
  int taken = 0;
  int missed = 0;
  int streak = 0;
  String risk = "";
  Map<DateTime, int> heatmap = {};

  @override
  void initState() {
    super.initState();
    _listenAnalytics();
  }

  void _listenAnalytics() {
    _analytics.dashboardStream().listen((data) {
      if (!mounted) return;
      setState(() {
        taken = data['taken'] ?? 0;
        missed = data['missed'] ?? 0;
        adherence = data['adherence'] ?? 0;
        streak = data['streak'] ?? 0;
        risk = data['risk'] ?? '';
        heatmap = data['heatmap'] ?? {};
        loading = false;
      });
    });
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _heatmap() {
    final today = DateTime.now();
    List<DateTime> days = List.generate(
      30,
      (i) => DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 29 - i)),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final d = DateTime(days[i].year, days[i].month, days[i].day);
        final v = heatmap[d] ?? 0;

        Color color = v == 0
            ? Colors.grey.shade300
            : v == 1
                ? Colors.green.shade300
                : Colors.green.shade600;

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Dashboard"),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xffF5F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _statCard("Streak", "$streak", Icons.local_fire_department, Colors.orange),
                const SizedBox(width: 10),
                _statCard("Taken", "$taken", Icons.check_circle, Colors.green),
                const SizedBox(width: 10),
                _statCard("Missed", "$missed", Icons.warning, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text("Risk Level: $risk"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Monthly Adherence",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: taken.toDouble() > 0 ? taken.toDouble() : 1,
                      color: Colors.green,
                      title: 'Taken',
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: missed.toDouble() > 0 ? missed.toDouble() : 1,
                      color: Colors.red,
                      title: 'Missed',
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Medicine Activity (Last 30 days)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _heatmap(),
          ],
        ),
      ),
    );
  }
}