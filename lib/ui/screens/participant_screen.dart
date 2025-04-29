import 'package:flutter/material.dart';
import 'package:race_tracking/model/participant_model.dart';
import 'package:race_tracking/services/participant_service.dart';
import 'package:race_tracking/theme/theme.dart';
import 'package:race_tracking/ui/widgets/participant_form.dart';
import 'package:race_tracking/ui/widgets/participant_list.dart';
import 'package:race_tracking/ui/widgets/top_button.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({Key? key}) : super(key: key);

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  final List<ParticipantModel> participants = [];
  final ParticipantService _participantService = ParticipantService();
  bool showDetails = false;
  bool showAge = false;
  bool showGender = false;
  ParticipantModel? _participantToEdit;
  int? _editIndex;
  int nextBib = 1;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final loadedParticipants = await _participantService.fetchParticipants();
    setState(() {
      participants.clear();
      participants.addAll(loadedParticipants);
      _updateNextBibNumber();
    });
  }

  void _updateNextBibNumber() {
    nextBib = 1;
    if (participants.isNotEmpty) {
      final used = participants.map((p) => p.bibNumber).toSet();
      while (used.contains(nextBib)) {
        nextBib++;
      }
    }
  }

  void _addParticipant(ParticipantModel participant) {
    // Assign bib number as 3-digit int (001, 002, ...)
    final autoParticipant = ParticipantModel(
      id: participant.id,
      firstName: participant.firstName,
      lastName: participant.lastName,
      bibNumber: nextBib,
      age: participant.age,
      gender: participant.gender,
      createdAt: participant.createdAt,
    );

    setState(() {
      participants.add(autoParticipant);
      _updateNextBibNumber();
    });
    _participantService.saveParticipants(participants);
  }

  void _deleteParticipant(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete Participant'),
            content: Text('Are you sure you want to delete this participant?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() {
      participants.removeAt(index);
      _updateNextBibNumber();
    });
    _participantService.saveParticipants(participants);
  }

  void _editParticipant(int index, ParticipantModel updatedParticipant) {
    // Prevent duplicate bib numbers except for the current participant
    if (participants.any(
      (p) =>
          p.bibNumber == updatedParticipant.bibNumber &&
          participants.indexOf(p) != index,
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bib number already exists!')));
      return;
    }
    setState(() {
      participants[index] = updatedParticipant;
      _updateNextBibNumber();
    });
    _participantService.saveParticipants(participants);
  }


  void _clearEdit() {
    setState(() {
      _participantToEdit = null;
      _editIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Participants", style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TopButton(
                  icon: Icons.check_circle,
                  label: "Done",
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  tooltip: "View",
                  offset: Offset(0, 40),
                  itemBuilder:
                      (context) => [
                        CheckedPopupMenuItem(
                          value: 'age',
                          checked: showAge,
                          child: Text('Age'),
                        ),
                        CheckedPopupMenuItem(
                          value: 'gender',
                          checked: showGender,
                          child: Text('Gender'),
                        ),
                      ],
                  onSelected: (value) {
                    setState(() {
                      if (value == 'age') showAge = !showAge;
                      if (value == 'gender') showGender = !showGender;
                    });
                  },
                  child: Material(
                    color: RTAColors.primary,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: null, // PopupMenuButton handles tap
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ), // Changed from Icons.list to Icons.arrow_drop_down
                            const SizedBox(width: 8),
                            Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TopButton(
                  icon: Icons.import_export,
                  label: "Import",
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ParticipantListWidget(
                  participants: participants,
                  showAge: showAge,
                  showGender: showGender,
                  onEdit:
                      _editParticipant, // <-- direct update for inline edits
                  onDelete: _deleteParticipant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ParticipantForm(
              onAdd: _addParticipant,
              nextBibNumber: nextBib,
              onEdit: (index, updated) {
                _editParticipant(index, updated);
                _clearEdit();
              },
              participantToEdit: _participantToEdit,
              editIndex: _editIndex,
            ),
          ],
        ),
      ),
    );
  }
}
