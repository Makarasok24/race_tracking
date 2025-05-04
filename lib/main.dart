import 'package:flutter/material.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/ui/screens/race_form.dart';
import 'package:race_tracking/presentation/ui/screens/start_screen.dart';
import 'package:race_tracking/presentation/widgets/icon_button_navbar.dart';
import 'package:race_tracking/test/add_participant_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: const AddParticipantTest(),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? StartScreen() : RaceForm(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: RTAColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              isSelected: _currentIndex == 0,
              icon: Icons.edit,
            ),
            label: 'Race',
          ),
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.people,
              isSelected: _currentIndex == 1,
            ),
            label: 'Participants',
          ),
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.access_alarm_rounded,
              isSelected: _currentIndex == 2,
            ),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.dashboard_rounded,
              isSelected: _currentIndex == 3,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: IconButtonNavBar(
              icon: Icons.emoji_events,
              isSelected: _currentIndex == 4,
            ),
            label: 'Results',
          ),
        ],
      ),
    );
  }
}