import 'package:flutter/material.dart';
import '../../model/participant_model.dart';

class ParticipantListWidget extends StatelessWidget {
  final List<ParticipantModel> participants;
  final Function(int, ParticipantModel) onEdit;
  final Function(int) onDelete;
  final bool showAge;
  final bool showGender;

  const ParticipantListWidget({
    Key? key,
    required this.participants,
    required this.onEdit,
    required this.onDelete,
    required this.showAge,
    required this.showGender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text(
              'Bib',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (showAge)
            DataColumn(
              label: Text(
                'Age',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          if (showGender)
            DataColumn(
              label: Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
        rows:
            participants.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(p.bibNumber.toString().padLeft(3, '0'))),
                  DataCell(Text('${p.firstName} ${p.lastName}'.trim())),
                  if (showAge)
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: p.age.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            final newAge = int.tryParse(value) ?? p.age;
                            final updated = ParticipantModel(
                              id: p.id,
                              bibNumber: p.bibNumber,
                              firstName: p.firstName,
                              lastName: p.lastName,
                              age: newAge,
                              gender: p.gender,
                              createdAt: p.createdAt,
                            );
                            onEdit(index, updated);
                          },
                        ),
                      ),
                    ),
                  if (showGender)
                    DataCell(
                      DropdownButton<String>(
                        value: p.gender.isNotEmpty ? p.gender : 'Male',
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (newGender) {
                          if (newGender != null) {
                            final updated = ParticipantModel(
                              id: p.id,
                              bibNumber: p.bibNumber,
                              firstName: p.firstName,
                              lastName: p.lastName,
                              age: p.age,
                              gender: newGender,
                              createdAt: p.createdAt,
                            );
                            onEdit(index, updated);
                          }
                        },
                        underline: SizedBox(),
                      ),
                    ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => EditNameDialog(
                                    initialName:
                                        '${p.firstName} ${p.lastName}'.trim(),
                                  ),
                            );
                            if (result != null && result.trim().isNotEmpty) {
                              String firstName = result.trim();
                              String lastName = '';
                              if (firstName.contains(' ')) {
                                final parts = firstName.split(' ');
                                firstName = parts.first;
                                lastName = parts.sublist(1).join(' ');
                              }
                              final updated = ParticipantModel(
                                id: p.id,
                                bibNumber: p.bibNumber,
                                firstName: firstName,
                                lastName: lastName,
                                age: p.age,
                                gender: p.gender,
                                createdAt: p.createdAt,
                              );
                              onEdit(index, updated);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete(index),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class EditAgeGenderDialog extends StatefulWidget {
  final ParticipantModel participant;
  final void Function(int age, String gender) onSave;
  final String field; // 'age', 'gender', or 'both'

  const EditAgeGenderDialog({
    Key? key,
    required this.participant,
    required this.onSave,
    this.field = 'both',
  }) : super(key: key);

  @override
  State<EditAgeGenderDialog> createState() => _EditAgeGenderDialogState();
}

class _EditAgeGenderDialogState extends State<EditAgeGenderDialog> {
  late TextEditingController _ageController;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(
      text: widget.participant.age.toString(),
    );
    // Ensure _gender is always a valid value
    const validGenders = ['Male', 'Female', 'Other'];
    _gender =
        validGenders.contains(widget.participant.gender)
            ? widget.participant.gender
            : 'Male';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.field == 'age'
            ? 'Edit Age'
            : widget.field == 'gender'
            ? 'Edit Gender'
            : 'Edit Age & Gender',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.field == 'age' || widget.field == 'both')
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
          if (widget.field == 'both') const SizedBox(height: 12),
          if (widget.field == 'gender' || widget.field == 'both')
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _gender = val ?? 'Male'),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newAge =
                int.tryParse(_ageController.text) ?? widget.participant.age;
            final newGender = _gender;
            Navigator.pop(context, {'age': newAge, 'gender': newGender});
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditNameDialog extends StatefulWidget {
  final String initialName;
  const EditNameDialog({Key? key, required this.initialName}) : super(key: key);

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextFormField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Full Name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _controller.text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ParentStatefulWidget extends StatefulWidget {
  @override
  _ParentStatefulWidgetState createState() => _ParentStatefulWidgetState();
}

class _ParentStatefulWidgetState extends State<ParentStatefulWidget> {
  List<ParticipantModel> participants = [];

  void _editParticipant(int index, ParticipantModel updated) {
    setState(() {
      participants[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParticipantListWidget(
      participants: participants,
      onEdit: _editParticipant,
      onDelete: (index) {
        setState(() {
          participants.removeAt(index);
        });
      },
      showAge: true,
      showGender: true,
    );
  }
}
