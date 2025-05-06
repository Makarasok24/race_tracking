import 'package:flutter/material.dart';
import 'package:race_tracking/domain/entities/participant.dart';
import 'package:race_tracking/presentation/theme/theme.dart';

class ParticipantForm extends StatefulWidget {
  final Participant? participant; // Pass existing participant for edit mode
  final Function(String bib, String name, String age, String gender) onSubmit;
  final String submitButtonText;
  final String title;

  const ParticipantForm({
    Key? key,
    this.participant, // null for add mode, populated for edit mode
    required this.onSubmit,
    this.submitButtonText = "Save",
    this.title = "Participant Form",
  }) : super(key: key);

  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final TextEditingController _bibController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    // If participant is provided, we're in edit mode
    if (widget.participant != null) {
      _isEditMode = true;
      _bibController.text = widget.participant!.bib;
      _nameController.text = widget.participant!.name;
      _ageController.text = widget.participant!.age;
      _selectedGender = widget.participant!.gender;
    }
  }

  @override
  void dispose() {
    _bibController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_bibController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _ageController.text.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: RTAColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // BIB field (readonly in edit mode)
            TextField(
              controller: _bibController,
              readOnly: _isEditMode, // Can't change BIB when editing
              decoration: InputDecoration(
                labelText: "BIB Number",
                hintText: "Enter unique BIB number",
                border: const OutlineInputBorder(),
                enabled: !_isEditMode, // Disable in edit mode
                fillColor: _isEditMode ? Colors.grey.shade200 : Colors.white,
                filled: _isEditMode,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items:
                  _genders.map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString();
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RTAColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_validateForm()) {
                    // Call the callback with form data
                    widget.onSubmit(
                      _bibController.text.trim(),
                      _nameController.text.trim(),
                      _ageController.text.trim(),
                      _selectedGender,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all required fields"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(widget.submitButtonText),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
