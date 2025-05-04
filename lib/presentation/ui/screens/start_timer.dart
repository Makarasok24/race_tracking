import 'package:flutter/material.dart';
import 'dart:async';

class StartTimer extends StatefulWidget {
  const StartTimer({Key? key}) : super(key: key);

  @override
  State<StartTimer> createState() => _StartTimerState();
}

class _StartTimerState extends State<StartTimer> {
  String mainTimer = "14:04:47";

  // Mock data for racers
  List<Map<String, dynamic>> racers = [
    {"number": "100", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "101", "name": "Sok Sothy", "time": "14:04:47", "status": false},
    {
      "number": "102",
      "name": "Theng Vathanak",
      "time": "14:04:50",
      "status": false,
    },
    {"number": "103", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "104", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "105", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "106", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "107", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "108", "name": "Sok Sothy", "time": "", "status": false},
    {"number": "109", "name": "Sok Sothy", "time": "14:04:47", "status": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with orange background
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            color: const Color(0xFFEFB87A), // Orange background
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Title
                const Text(
                  'Start timer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Timer display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            color: Colors.black,
            width: double.infinity,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      mainTimer,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Racers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: racers.length,
              itemBuilder: (context, index) {
                final racer = racers[index];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Racer number
                      SizedBox(
                        width: 30,
                        child: Text(
                          racer["number"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Racer name
                      Expanded(
                        flex: 2,
                        child: Text(
                          racer["name"],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      // Timer value (if any)
                      Expanded(
                        flex: 1,
                        child: Text(
                          racer["time"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Action button (Start or Reset)
                      SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button press
                            setState(() {
                              if (racer["time"] == "") {
                                racer["time"] = mainTimer;
                              } else {
                                racer["time"] = "";
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                racer["time"] == ""
                                    ? Colors.black
                                    : Colors.grey[300],
                            foregroundColor:
                                racer["time"] == ""
                                    ? Colors.white
                                    : Colors.black,
                            minimumSize: const Size(70, 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                          child: Text(
                            racer["time"] == "" ? "Start" : "Reset",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
