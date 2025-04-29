import 'package:flutter/material.dart';
import 'package:race_tracking/theme/theme.dart';
import '../../model/participant_model.dart';

class ParticipantForm extends StatefulWidget {
  final Function(ParticipantModel) onAdd;
  final int nextBibNumber;

  const ParticipantForm({
    Key? key,
    required this.onAdd,
    required this.nextBibNumber, ParticipantModel? participantToEdit, int? editIndex, required Null Function(dynamic index, dynamic updated) onEdit,
  }) : super(key: key);

  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final participant = ParticipantModel(
        firstName: _fullNameController.text, // You can split this if needed
        lastName: '',
        bibNumber: widget.nextBibNumber,
        age: 0,
        gender: '',
        createdAt: DateTime.now(),
      );
      widget.onAdd(participant);

      _fullNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: RTAColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // BIB Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.nextBibNumber.toString().padLeft(3, '0'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Full Name Input
            Expanded(
              child: TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ),

            const SizedBox(width: 8),

            // Add Button
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RTAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
