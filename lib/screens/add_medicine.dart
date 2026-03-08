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

  final MedicineService _service = MedicineService();

  String medicineType = "Tablet";
  String frequencyType = "daily";

  bool reminderEnabled = true;
  bool _isSaving = false;

  List<TimeOfDay> selectedTimes = [];
  List<int> selectedDays = [];

  final medicineTypes = [
    "Tablet",
    "Capsule",
    "Syrup",
    "Injection",
    "Drops"
  ];

  final days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];

  @override
  void initState() {
    super.initState();

    if(widget.existingData != null){
      _nameController.text = widget.existingData!['name'] ?? "";
      _dosageController.text = widget.existingData!['dosage'] ?? "";
      medicineType = widget.existingData!['type'] ?? "Tablet";
    }
  }

  @override
  void dispose(){
    _nameController.dispose();
    _dosageController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> pickTime() async {

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if(time != null && !selectedTimes.contains(time)){
      setState(() => selectedTimes.add(time));
    }
  }

  Future<void> _saveMedicine() async {

    if(!_formKey.currentState!.validate()) return;

    if(frequencyType != "interval" && selectedTimes.isEmpty){
      _showSnack("Add at least one reminder time");
      return;
    }

    if(frequencyType == "interval"){
      final interval = int.tryParse(_intervalController.text);

      if(interval == null || interval <= 0){
        _showSnack("Enter valid interval");
        return;
      }
    }

    setState(()=> _isSaving = true);

    try{

      String medicineId;

      if(widget.medicineId == null){

        medicineId = await _service.addMedicine(
          name: _nameController.text.trim(),
          type: medicineType,
          dosage: _dosageController.text.trim(),
        );

      }else{

        medicineId = widget.medicineId!;

        await _service.editMedicine(
          medicineId: medicineId,
          name: _nameController.text.trim(),
          type: medicineType,
          dosage: _dosageController.text.trim(),
        );

      }

      final times = selectedTimes
          .map((t)=>"${t.hour}:${t.minute.toString().padLeft(2,'0')}")
          .toList();

      await _service.addSchedule(
        medicineId: medicineId,
        frequencyType: frequencyType,
        times: times,
        daysOfWeek: frequencyType == "specific_days" ? selectedDays : null,
        intervalHours: frequencyType == "interval"
            ? int.tryParse(_intervalController.text)
            : null,
        reminderEnabled: reminderEnabled,
      );

      if(reminderEnabled && selectedTimes.isNotEmpty){

        int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        for(final t in selectedTimes){

          await NotificationService.scheduleDaily(
            id: id++,
            title: "Medicine Reminder",
            body: "Time to take ${_nameController.text.trim()}",
            hour: t.hour,
            minute: t.minute,
          );

        }

      }

      if(mounted){
        Navigator.pop(context);
        _showSnack("Medicine saved");
      }

    }catch(e){
      _showSnack("Failed to save medicine");
    }

    if(mounted){
      setState(()=> _isSaving = false);
    }
  }

  void _showSnack(String text){
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Widget sectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.only(bottom:8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize:16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildTimes(){

    if(selectedTimes.isEmpty){
      return const Text(
        "No time added",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing:8,
      runSpacing:6,
      children: selectedTimes.map((t){

        return Chip(
          label: Text(t.format(context)),
          deleteIcon: const Icon(Icons.close),
          onDeleted: (){
            setState(()=> selectedTimes.remove(t));
          },
        );

      }).toList(),
    );
  }

  Widget buildDays(){

    return Wrap(
      spacing:8,
      children: List.generate(days.length,(index){

        final selected = selectedDays.contains(index);

        return ChoiceChip(
          label: Text(days[index]),
          selected: selected,
          onSelected:(v){

            setState((){

              if(v){
                selectedDays.add(index);
              }else{
                selectedDays.remove(index);
              }

            });

          },
        );

      }),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.medicineId == null
              ? "Add Medicine"
              : "Edit Medicine",
        ),
      ),

      body: Stack(
        children: [

          SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Form(

              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  sectionTitle("Medicine"),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Medicine name",
                      prefixIcon: Icon(Icons.medication),
                    ),
                    validator:(v)=> v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height:16),

                  Row(
                    children: [

                      Expanded(
                        child: DropdownButtonFormField(
                          value: medicineType,
                          items: medicineTypes
                              .map((e)=>DropdownMenuItem(
                                    value:e,
                                    child:Text(e),
                                  ))
                              .toList(),
                          onChanged:(v)=>setState(()=> medicineType = v!),
                        ),
                      ),

                      const SizedBox(width:12),

                      Expanded(
                        child: TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            hintText: "Dosage",
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height:28),

                  sectionTitle("Schedule"),

                  DropdownButtonFormField(
                    value: frequencyType,
                    items: const [
                      DropdownMenuItem(value:"daily",child:Text("Daily")),
                      DropdownMenuItem(value:"specific_days",child:Text("Specific Days")),
                      DropdownMenuItem(value:"interval",child:Text("Every X Hours")),
                    ],
                    onChanged:(v)=>setState(()=> frequencyType = v!),
                  ),

                  const SizedBox(height:16),

                  if(frequencyType == "interval")
                    TextFormField(
                      controller:_intervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Interval (hours)",
                      ),
                    ),

                  if(frequencyType == "specific_days")
                    Padding(
                      padding: const EdgeInsets.only(top:10),
                      child: buildDays(),
                    ),

                  const SizedBox(height:18),

                  Row(
                    children: [

                      ElevatedButton.icon(
                        onPressed: pickTime,
                        icon: const Icon(Icons.access_time),
                        label: const Text("Add Time"),
                      ),

                    ],
                  ),

                  const SizedBox(height:10),

                  buildTimes(),

                  const SizedBox(height:24),

                  SwitchListTile(
                    value: reminderEnabled,
                    title: const Text("Enable Reminder"),
                    onChanged:(v)=>setState(()=> reminderEnabled = v),
                  ),

                  const SizedBox(height:10),

                  SizedBox(
                    width: double.infinity,
                    height:50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveMedicine,
                      child: const Text("Save Medicine"),
                    ),
                  ),

                  const SizedBox(height:20),

                ],
              ),
            ),
          ),

          if(_isSaving)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            )

        ],
      ),
    );
  }
}