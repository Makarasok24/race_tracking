import 'package:flutter/material.dart';
import 'package:race_tracking/data/data_sources/firebase_participant_data_source.dart';
import 'package:race_tracking/data/repositories/participant_repository_impl.dart';
import 'package:race_tracking/domain/entities/participant.dart';

class AddParticipantTest extends StatefulWidget {
  const AddParticipantTest({Key? key}) : super(key: key);

  @override
  State<AddParticipantTest> createState() => _AddParticipantTestState();
}

class _AddParticipantTestState extends State<AddParticipantTest> {
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

  // Add this method to add a new participant
  Future<void> _addParticipant() async {
    try {
      setState(() {
        message = "Adding participant...";
      });

      // Generate a unique bib number
      final bib = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

      // Create a new participant
      final participant = Participant(
        bib: bib,
        name: "Runner $bib",
        isCompleted: false,
        duration: 0,
        distance: 5.0,
        globalStartTime: DateTime.now().toIso8601String(),
      );

      // Save to Firebase
      await _repository.addParticipant(participant);

      // Refresh the list
      await _loadParticipants();

      setState(() {
        message = "Added participant with bib: $bib";
      });
    } catch (e) {
      setState(() {
        message = "Error adding participant: ${e.toString()}";
      });
      print("Error adding participant: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Participant Test")),
      body: Column(
        children: [
          // Add participant button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addParticipant,
              child: const Text("Add New Participant"),
            ),
          ),

          // Display status message
          if (message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                message,
                style: TextStyle(
                  color: message.contains("Error") ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Display participants list
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : participants.isEmpty
                    ? const Center(child: Text("No participants found"))
                    : ListView.builder(
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(participant.bib)),
                          title: Text(participant.name),
                          subtitle: Text(
                            "Status: ${participant.isCompleted ? "Completed" : "In Progress"}",
                          ),
                          trailing: Text("${participant.distance} km"),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
