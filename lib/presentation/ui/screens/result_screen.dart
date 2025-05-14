import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/data/models/result_model.dart';
import 'package:race_tracking/presentation/provider/result_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/search_form.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Load results when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResultProvider>(context, listen: false).loadResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Race Results', style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<ResultProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text(provider.errorMessage));
            }

            if (provider.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No results available yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadResults(),
                      child: Text('Reload Results'),
                    ),
                  ],
                ),
              );
            }

            // Generate rows from real result data
            final List<DataRow> rows =
                provider.results.map((result) {
                  final swimTime = result.swimTime ?? 0;
                  final bikeTime = result.bikeTime ?? 0;
                  final runTime = result.runTime ?? 0;
                  final t1Time = result.t1Time ?? 0;
                  final t2Time = result.t2Time ?? 0;

                  // Format times for display
                  final formattedSwimTime = _formatMilliseconds(swimTime);
                  final formattedBikeTime = _formatMilliseconds(bikeTime);
                  final formattedRunTime = _formatMilliseconds(runTime);
                  final formattedT1Time = _formatMilliseconds(t1Time);
                  final formattedT2Time = _formatMilliseconds(t2Time);
                  final formattedTotalTime = _formatMilliseconds(
                    result.totalTime,
                  );

                  // Format speeds
                  final speedText =
                      '${result.swimSpeed?.toStringAsFixed(1) ?? "-"}/' +
                      '${result.bikeSpeed?.toStringAsFixed(1) ?? "-"}/' +
                      '${result.runSpeed?.toStringAsFixed(1) ?? "-"} km/h';

                  return DataRow(
                    cells: [
                      DataCell(Text('${result.rank}')),
                      DataCell(Text(result.bib ?? '-')),
                      DataCell(Text(result.name ?? 'Unknown')),
                      DataCell(Text(formattedSwimTime)),
                      DataCell(Text(formattedBikeTime)),
                      DataCell(Text(formattedRunTime)),
                      DataCell(Text(formattedTotalTime)),
                      DataCell(Text(speedText)),
                    ],
                  );
                }).toList();

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SearchForm(
                        onChanged: (value) {
                          // TODO: Implement search
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await _exportExcel(provider.results);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Results exported successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
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
            );
          },
        ),
      ),
    );
  }

  // Helper function to format milliseconds as HH:MM:SS
  String _formatMilliseconds(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  // Export to Excel functionality
  Future<void> _exportExcel(List<ResultModel> results) async {
    final excel = Excel.createExcel();
    final sheet = excel['ResultRace'];
    excel.delete('Sheet1');

    final mainHeaders = [
      'Rank',
      'BIB',
      'Name',
      'Swimming',
      '',
      'T1',
      'Cycling',
      '',
      'T2',
      'Running',
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
      'Time', // Swimming
      'Speed',
      'Time', // T1
      'Time', // Cycling
      'Speed',
      'Time', // T2
      'Time', // Running
      'Speed',
      '',
      '',
    ];

    for (int i = 0; i < subHeaders.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .value = TextCellValue(subHeaders[i]);
    }

    for (int i = 0; i < results.length; i++) {
      final result = results[i];

      // Format times
      final swimTime = _formatMilliseconds(result.swimTime ?? 0);
      final t1Time = _formatMilliseconds(result.t1Time ?? 0);
      final bikeTime = _formatMilliseconds(result.bikeTime ?? 0);
      final t2Time = _formatMilliseconds(result.t2Time ?? 0);
      final runTime = _formatMilliseconds(result.runTime ?? 0);
      final totalTime = _formatMilliseconds(result.totalTime);

      // Format speeds
      final swimSpeed =
          result.swimSpeed != null
              ? "${result.swimSpeed!.toStringAsFixed(1)} km/h"
              : "-";
      final bikeSpeed =
          result.bikeSpeed != null
              ? "${result.bikeSpeed!.toStringAsFixed(1)} km/h"
              : "-";
      final runSpeed =
          result.runSpeed != null
              ? "${result.runSpeed!.toStringAsFixed(1)} km/h"
              : "-";

      final speedText = '${swimSpeed}/${bikeSpeed}/${runSpeed}';

      // Write row data
      final rowData = [
        (i + 1).toString(),
        result.bib ?? '-',
        result.name ?? 'Unknown',
        swimTime,
        swimSpeed,
        t1Time,
        bikeTime,
        bikeSpeed,
        t2Time,
        runTime,
        runSpeed,
        totalTime,
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
}
