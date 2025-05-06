import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:race_tracking/data/data_sources/firebase_participant_data_source.dart';
import 'package:race_tracking/data/repositories/participant_repository_impl.dart';
import 'package:race_tracking/domain/entities/participant.dart';
import 'package:race_tracking/domain/repositories/participant_repository.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/participant_form.dart';
import 'package:race_tracking/presentation/widgets/search_form.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({super.key});

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  final FirebaseParticipantDataSource _dataSource =
      FirebaseParticipantDataSource();
  late ParticipantRepositoryImpl _repository;
  List<Participant> participants = [];
  bool isLoading = true;
  String message = "";

  @override
  void initState() {
    super.initState();
    _repository = ParticipantRepositoryImpl(dataSource: _dataSource);
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      setState(() {
        isLoading = true;
        message = "";
      });

      participants = await _repository.getAllParticipants();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        message = "Error loading participants: ${e.toString()}";
      });
      print("Error loading participants: $e");
    }
  }

  // Show add modal
  void _showAddParticipantModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ParticipantForm(
            title: "Add New Participant",
            submitButtonText: "Save Participant",
            onSubmit: (bib, name, age, gender) {
              _handleAddParticipant(bib, name, age, gender);
            },
          ),
    );
  }

  // Show edit modal
  void _showEditParticipantModal(Participant participant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ParticipantForm(
            title: "Edit Participant",
            submitButtonText: "Update Participant",
            participant: participant,
            onSubmit: (bib, name, age, gender) {
              _handleEditParticipant(participant, name, age, gender);
            },
          ),
    );
  }

  // adding new participant
  Future<void> _handleAddParticipant(
    String bib,
    String name,
    String age,
    String gender,
  ) async {
    try {
      setState(() {
        message = "Adding participant...";
      });

      final participant = Participant(
        bib: bib,
        name: name,
        age: age,
        gender: gender,
        isCompleted: false,
        duration: 0,
        distance: 0.0,
        globalStartTime: DateTime.now().toIso8601String(),
      );

      await _repository.addParticipant(participant);
      await _loadParticipants();

      setState(() {
        message = "Participant added successfully";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Participant added with BIB: $bib"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        message = "Error adding participant: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      print("Error adding participant: $e");
    }
  }

  // editing participant
  Future<void> _handleEditParticipant(
    Participant oldParticipant,
    String name,
    String age,
    String gender,
  ) async {
    try {
      setState(() {
        message = "Updating participant...";
      });

      final participant = Participant(
        bib: oldParticipant.bib,
        name: name,
        age: age,
        gender: gender,
        isCompleted: oldParticipant.isCompleted,
        duration: oldParticipant.duration,
        distance: oldParticipant.distance,
        globalStartTime: oldParticipant.globalStartTime,
      );

      await _repository.updateParticipant(participant);

      await _loadParticipants();

      setState(() {
        message = "Participant updated successfully";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Participant ${participant.name} updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        message = "Error updating participant: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      print("Error updating participant: $e");
    }
  }

  // delete participant
  Future<void> _handleDeleteParticipant(String bib) async {
    try {
      setState(() {
        message = "Deleting participant...";
      });

      await _repository.deleteParticipant(bib);

      await _loadParticipants();

      setState(() {
        message = "Participant deleted successfully";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Participant with BIB: $bib deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        message = "Error deleting participant: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      print("Error deleting participant: $e");
    }
  }

  // confirmation delete
  void _showDeleteConfirmation(Participant participant) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Participant"),
            content: Text(
              "Are you sure you want to delete participant ${participant.name} (BIB: ${participant.bib})?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteParticipant(participant.bib);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Participants", style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.title,
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: RTAColors.white),
            onPressed: _loadParticipants,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Search_widget(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Participants",
                      style: TextStyle(
                        fontSize: 18,
                        color: RTAColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(" (${participants.length})"),
                  ],
                ),

                // Show message if any
                if (message.isNotEmpty && message.contains("Error"))
                  Text(
                    "Error loading data",
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Show loading
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : participants.isEmpty
                      ? const Center(child: Text("No participants found"))
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('BIB')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Age')),
                              DataColumn(label: Text('Gender')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows:
                                participants.map((participant) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(participant.bib.toString()),
                                      ),
                                      DataCell(Text(participant.name)),
                                      DataCell(
                                        Text(participant.age.toString()),
                                      ),
                                      DataCell(Text(participant.gender)),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Iconsax.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () {
                                                _showEditParticipantModal(
                                                  participant,
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Iconsax.trash,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                _showDeleteConfirmation(
                                                  participant,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddParticipantModal,
        backgroundColor: RTAColors.primary,
        child: Icon(Iconsax.add, color: RTAColors.white),
      ),
    );
  }
}
