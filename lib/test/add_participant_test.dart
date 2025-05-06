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

  // Define test data
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> testNames = [
    'John Doe',
    'Jane Smith',
    'Alex Johnson',
    'Maria Garcia',
    'Wei Chen',
  ];
  bool testModeOnly = false; // Set to true to test without Firebase

  @override
  void initState() {
    super.initState();
    _repository = ParticipantRepositoryImpl(dataSource: _dataSource);

    if (!testModeOnly) {
      _loadParticipants();
    }
  }

  Future<void> _loadParticipants() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (testModeOnly) {
        // In test mode, just wait a moment to simulate loading
        await Future.delayed(const Duration(milliseconds: 500));
        participants = [];
      } else {
        // Actually load from Firebase
        participants = await _repository.getAllParticipants();
        for (var p in participants) {
          print(
            'Participant: ${p.bib}, Name: ${p.name}, Age: ${p.age}, Gender: ${p.gender}',
          );
        }
      }

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

  Future<void> _addParticipant() async {
    try {
      setState(() {
        message = "Adding participant...";
      });

      // Generate a unique bib number
      final bib = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

      // Choose a random name
      final randomName =
          testNames[DateTime.now().millisecond % testNames.length];

      // Create a new participant
      final participant = Participant(
        bib: bib,
        name: "$randomName $bib",
        gender: genderList[DateTime.now().millisecond % genderList.length],
        age:
            (20 + (DateTime.now().millisecond % 40))
                .toString(), // Random age between 20-59
        isCompleted: false,
        duration: 0,
        distance: 5.0,
        globalStartTime: DateTime.now().toIso8601String(),
      );

      if (testModeOnly) {
        // In test mode, just add to local list
        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // Simulate network delay
        setState(() {
          participants.add(participant);
        });
      } else {
        // Actually save to Firebase
        await _repository.addParticipant(participant);
        await _loadParticipants(); // Refresh list from server
      }

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
      appBar: AppBar(
        title: Text(
          testModeOnly ? "Participant Test (Local)" : "Participant Test",
        ),
        actions: [
          // Toggle test mode
          IconButton(
            icon: Icon(testModeOnly ? Icons.cloud_off : Icons.cloud),
            onPressed: () {
              setState(() {
                testModeOnly = !testModeOnly;
                if (!testModeOnly) {
                  _loadParticipants();
                }
              });
            },
            tooltip:
                testModeOnly
                    ? "Switch to Firebase mode"
                    : "Switch to local test mode",
          ),
        ],
      ),
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
                            "Gender: ${participant.gender}, Age: ${participant.age}",
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
