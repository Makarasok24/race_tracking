import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/search_form.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for participants
    final List<Map<String, dynamic>> participants = [
      {
        'bib': '101',
        'name': 'John Doe',
        'swimStart': '08:00:00',
        'swimEnd': '08:25:30',
        'cycleStart': '08:30:00',
        'cycleEnd': '09:45:15',
        'runStart': '09:50:00',
        'runEnd': '11:05:45',
      },
      {
        'bib': '102',
        'name': 'Jane Smith',
        'swimStart': '08:00:00',
        'swimEnd': '08:22:45',
        'cycleStart': '08:27:00',
        'cycleEnd': '09:35:30',
        'runStart': '09:40:00',
        'runEnd': '10:50:15',
      },
      {
        'bib': '103',
        'name': 'Mike Johnson',
        'swimStart': '08:00:00',
        'swimEnd': '08:30:15',
        'cycleStart': '08:35:00',
        'cycleEnd': '09:55:45',
        'runStart': '10:00:00',
        'runEnd': '11:20:30',
      },
      {
        'bib': '104',
        'name': 'Sarah Williams',
        'swimStart': '08:00:00',
        'swimEnd': '08:20:00',
        'cycleStart': '08:25:00',
        'cycleEnd': '09:30:00',
        'runStart': '09:35:00',
        'runEnd': '10:40:00',
      },
      {
        'bib': '105',
        'name': 'David Brown',
        'swimStart': '08:00:00',
        'swimEnd': '08:35:45',
        'cycleStart': '08:40:00',
        'cycleEnd': '10:05:30',
        'runStart': '10:10:00',
        'runEnd': '11:30:15',
      },
    ];

    // Calculate durations and speeds for each participant
    final List<DataRow> rows =
        participants.map((participant) {
          // chnage from string to time
          final swimStart = _parseTime(participant['swimStart']);
          final swimEnd = _parseTime(participant['swimEnd']);
          final cycleStart = _parseTime(participant['cycleStart']);
          final cycleEnd = _parseTime(participant['cycleEnd']);
          final runStart = _parseTime(participant['runStart']);
          final runEnd = _parseTime(participant['runEnd']);

          // Calculate durations in seconds
          final swimDuration = swimEnd.difference(swimStart).inSeconds;
          final cycleDuration = cycleEnd.difference(cycleStart).inSeconds;
          final runDuration = runEnd.difference(runStart).inSeconds;
          final totalDuration = runEnd.difference(swimStart).inSeconds;

          // Calculate speeds in km/h
          final swimSpeed = _calculateSpeed(1, swimDuration); // 1km swim
          final cycleSpeed = _calculateSpeed(20, cycleDuration); // 20km cycling
          final runSpeed = _calculateSpeed(10, runDuration); // 10km run

          return DataRow(
            cells: [
              DataCell(Text('${participants.indexOf(participant) + 1}')),
              DataCell(Text(participant['bib'])),
              DataCell(Text(participant['name'])),
              DataCell(Text('${_formatDuration(swimDuration)}')),
              DataCell(Text('${_formatDuration(cycleDuration)}')),
              DataCell(Text('${_formatDuration(runDuration)}')),
              DataCell(Text('${_formatDuration(totalDuration)}')),
              DataCell(
                Text(
                  '${swimSpeed.toStringAsFixed(1)}/${cycleSpeed.toStringAsFixed(1)}/${runSpeed.toStringAsFixed(1)} km/h',
                ),
              ),
            ],
          );
        }).toList();

    Future<void> exportExcel(List<Map<String, dynamic>> participants) async {
      final excel = Excel.createExcel();
      final sheet = excel['ResultRace'];
      excel.delete('Sheet1');

      final mainHeaders = [
        'Rank',
        'BIB',
        'Name',
        'Swimming',
        '',
        '',
        'Cycling',
        '',
        '',
        'Running',
        '',
        '',
        'Total Time',
        'Speed (S/C/R)',
      ];

      for (int i = 0; i < mainHeaders.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(mainHeaders[i]);
      }

      final subHeaders = [
        '',
        '',
        '',
        'Start Time', // Swimming
        'End Time',
        'Duration',
        'Start Time', // Cycling
        'End Time',
        'Duration',
        'Start Time', // Running
        'End Time',
        'Duration',
        '',
        '',
      ];

      for (int i = 0; i < subHeaders.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
            .value = TextCellValue(subHeaders[i]);
      }

      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
      ); // Swimming
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0),
      ); // Cycling
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0),
      ); // Running

      for (int i = 0; i < participants.length; i++) {
        final participant = participants[i];
        final swimStart = participant['swimStart'];
        final swimEnd = participant['swimEnd'];
        final swimDuration =
            _parseTime(swimEnd).difference(_parseTime(swimStart)).inSeconds;

        final cycleStart = participant['cycleStart'];
        final cycleEnd = participant['cycleEnd'];
        final cycleDuration =
            _parseTime(cycleEnd).difference(_parseTime(cycleStart)).inSeconds;

        final runStart = participant['runStart'];
        final runEnd = participant['runEnd'];
        final runDuration =
            _parseTime(runEnd).difference(_parseTime(runStart)).inSeconds;

        final totalDuration =
            _parseTime(runEnd).difference(_parseTime(swimStart)).inSeconds;

        final swimSpeed = _calculateSpeed(1, swimDuration);
        final cycleSpeed = _calculateSpeed(20, cycleDuration);
        final runSpeed = _calculateSpeed(10, runDuration);
        final speedText =
            '${swimSpeed.toStringAsFixed(1)}/${cycleSpeed.toStringAsFixed(1)}/${runSpeed.toStringAsFixed(1)} km/h';

        // Write row data
        final rowData = [
          (i + 1).toString(),
          participant['bib'],
          participant['name'],
          swimStart,
          swimEnd,
          _formatDuration(swimDuration),
          cycleStart,
          cycleEnd,
          _formatDuration(cycleDuration),
          runStart,
          runEnd,
          _formatDuration(runDuration),
          _formatDuration(totalDuration),
          speedText,
        ];

        for (int j = 0; j < rowData.length; j++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 2))
              .value = TextCellValue(rowData[j]);
        }
      }

      excel.save(fileName: "RaceResult.xlsx");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Race Results', style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                // Expanded to take available horizontal space
                // Expanded(child: SearchForm(onChanged: ,)),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await exportExcel(participants);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error exporting: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Iconsax.export_3, color: RTAColors.primary),
                  label: Text(
                    'Export',
                    style: TextStyle(color: RTAColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: RTAColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Rank")),
                      DataColumn(label: Text('BIB')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Swimming')),
                      DataColumn(label: Text('Cycling')),
                      DataColumn(label: Text('Running')),
                      DataColumn(label: Text("Total Time")),
                      DataColumn(label: Text("Speed (S/C/R)")),
                    ],
                    rows: rows,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to parse time string to DateTime
  DateTime _parseTime(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return DateTime(2023, 1, 1, parts[0], parts[1], parts[2]);
  }

  // Helper function to format duration as HH:MM:SS
  String _formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  // Helper function to calculate speed in km/h
  //  v = d/t
  double _calculateSpeed(double distanceKm, int durationSeconds) {
    if (durationSeconds == 0) return 0;
    final hours = durationSeconds / 3600;
    return distanceKm / hours;
  }
}
