import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/search_form.dart';
import 'package:race_tracking/test/add_participant_test.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({super.key});

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  final List<Map<String, dynamic>> participants = [
    {'bib': 101, 'name': 'John Doe', 'age': 25, 'gender': 'Male'},
    {'bib': 102, 'name': 'Jane Smith', 'age': 28, 'gender': 'Female'},
    {'bib': 103, 'name': 'Alex Lee', 'age': 30, 'gender': 'Other'},
    {'bib': 101, 'name': 'John Doe', 'age': 25, 'gender': 'Male'},
    {'bib': 102, 'name': 'Jane Smith', 'age': 28, 'gender': 'Female'},
    {'bib': 103, 'name': 'Alex Lee', 'age': 30, 'gender': 'Other'},
    {'bib': 101, 'name': 'John Doe', 'age': 25, 'gender': 'Male'},
    {'bib': 102, 'name': 'Jane Smith', 'age': 28, 'gender': 'Female'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Participants", style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Search_widget(),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            // Scrollable in both directions
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
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
                              DataCell(Text(participant['bib'].toString())),
                              DataCell(Text(participant['name'])),
                              DataCell(Text(participant['age'].toString())),
                              DataCell(Text(participant['gender'])),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Iconsax.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        // Edit action here
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Iconsax.trash,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        // Delete action here
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
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ()),
          // );
        },
        backgroundColor: RTAColors.primary,
        child: Icon(Iconsax.add, color: RTAColors.white),
      ),
    );
  }
}
