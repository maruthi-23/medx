import 'package:flutter/material.dart';
import 'package:medx/services/medicine_service.dart';
import 'package:medx/services/notification_service.dart';

class AddMedicine extends StatefulWidget {
  final String? medicineId;
  final Map<String, dynamic>? existingData;

  const AddMedicine({
    super.key,
    this.medicineId,
    this.existingData,
  });

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _intervalController = TextEditingController();

  String medicineType = 'Tablet';
  String frequencyType = 'daily';
  bool reminderEnabled = true;

  List<TimeOfDay> selectedTimes = [];
  List<int> selectedDays = [];

  final medicineTypes = ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Drops'];
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _dosageController.text = widget.existingData!['dosage'] ?? '';
      medicineType = widget.existingData!['type'] ?? 'Tablet';
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && !selectedTimes.contains(time)) {
      setState(() => selectedTimes.add(time));
    }
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = MedicineService();

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        title: Text(widget.medicineId == null
            ? 'Add Medicine'
            : 'Edit Medicine'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Medicine'),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Medicine name',
                      prefixIcon: Icon(Icons.medication),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: medicineType,
                          items: medicineTypes
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => medicineType = v as String),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _dosageController,
                          decoration:
                              const InputDecoration(hintText: 'Dosage'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  sectionTitle('Schedule'),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'daily', label: Text('Daily')),
                      ButtonSegment(
                          value: 'specific_days', label: Text('Specific')),
                      ButtonSegment(value: 'interval', label: Text('Interval')),
                    ],
                    selected: {frequencyType},
                    onSelectionChanged: (v) =>
                        setState(() => frequencyType = v.first),
                  ),
                  const SizedBox(height: 16),
                  if (frequencyType == 'specific_days')
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        return FilterChip(
                          label: Text(days[i]),
                          selected: selectedDays.contains(i + 1),
                          onSelected: (v) {
                            setState(() {
                              v
                                  ? selectedDays.add(i + 1)
                                  : selectedDays.remove(i + 1);
                            });
                          },
                        );
                      }),
                    ),
                  if (frequencyType == 'interval')
                    TextFormField(
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Every X hours',
                        prefixIcon: Icon(Icons.timer),
                      ),
                    ),
                  if (frequencyType != 'interval') ...[
                    sectionTitle('Time'),
                    Wrap(
                      spacing: 8,
                      children: selectedTimes
                          .map(
                            (t) => Chip(
                              label: Text(t.format(context)),
                              onDeleted: () =>
                                  setState(() => selectedTimes.remove(t)),
                            ),
                          )
                          .toList(),
                    ),
                    TextButton.icon(
                      onPressed: pickTime,
                      icon: const Icon(Icons.add),
                      label: const Text('Add time'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable reminder'),
                    value: reminderEnabled,
                    onChanged: (v) => setState(() => reminderEnabled = v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        String medicineId;

                        if (widget.medicineId == null) {
                          medicineId = await service.addMedicine(
                            name: _nameController.text.trim(),
                            type: medicineType,
                            dosage: _dosageController.text.trim(),
                          );
                        } else {
                          medicineId = widget.medicineId!;
                          await service.editMedicine(
                            medicineId: medicineId,
                            name: _nameController.text.trim(),
                            type: medicineType,
                            dosage: _dosageController.text.trim(),
                          );
                        }

                        final times = selectedTimes
                            .map((t) =>
                                '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
                            .toList();

                        await service.addSchedule(
                          medicineId: medicineId,
                          frequencyType: frequencyType,
                          times: times,
                          daysOfWeek:
                              frequencyType == 'specific_days'
                                  ? selectedDays
                                  : null,
                          intervalHours:
                              frequencyType == 'interval'
                                  ? int.tryParse(
                                      _intervalController.text)
                                  : null,
                          reminderEnabled: reminderEnabled,
                        );

                        if (reminderEnabled) {
                          await NotificationService.cancelAll();

                          int notifId =
                              DateTime.now().millisecondsSinceEpoch ~/
                                  1000;

                          for (final t in selectedTimes) {
                            await NotificationService.scheduleDaily(
                              id: notifId++,
                              title: 'Medicine Reminder',
                              body:
                                  'Time to take ${_nameController.text.trim()}',
                              hour: t.hour,
                              minute: t.minute,
                            );
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Medicine saved'),
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: Text(widget.medicineId == null
                          ? 'Save'
                          : 'Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
