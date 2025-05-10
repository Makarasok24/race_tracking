import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/data/data_sources/firebase_race_timing_data_source.dart';
import 'package:race_tracking/data/repositories/race_timing_repository_impl.dart';
import 'package:race_tracking/presentation/provider/race_timing_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/ui/screens/participant_screen.dart';
import 'package:race_tracking/presentation/ui/screens/race_segment.dart';
import 'package:race_tracking/presentation/ui/screens/result_screen.dart';
import 'package:race_tracking/presentation/widgets/icon_button_navbar.dart';

void main() {
  final raceTimingRepository = RaceTimingRepositoryImpl(
    dataSource: FirebaseRaceTimingDataSource(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RaceTimingProvider(repository: raceTimingRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triathlon Race Tracker',
      theme: appTheme,
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // all page widgets - fixed to match navigation items
  final List<Widget> _pages = [
    const ParticipantScreen(),
    const RaceSegment(),
    const ResultScreen(),
    // const ResultsScreen(), // Add a results screen - you'll need to create this
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: RTAColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: (index) {
          // Make sure we don't go out of bounds
          if (index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.people,
              isSelected: _currentIndex == 0,
            ),
            label: 'Participants',
          ),
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.access_alarm_rounded,
              isSelected: _currentIndex == 1,
            ),
            label: 'Race',
          ),
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.emoji_events,
              isSelected: _currentIndex == 2,
            ),
            label: 'Results',
          ),
        ],
      ),
    );
  }
}
