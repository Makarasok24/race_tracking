import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/core/services/notification_service.dart';
import 'package:race_tracking/data/data_sources/firebase_participant_data_source.dart';
import 'package:race_tracking/data/data_sources/firebase_race_timing_data_source.dart';
import 'package:race_tracking/data/data_sources/firebase_result_data_source.dart';
import 'package:race_tracking/data/repositories/participant_repository_impl.dart';
import 'package:race_tracking/data/repositories/race_timing_repository_impl.dart';
import 'package:race_tracking/data/repositories/result_repositry_impl.dart';
import 'package:race_tracking/presentation/provider/notification_history_provider.dart';
import 'package:race_tracking/presentation/provider/race_timing_provider.dart';
import 'package:race_tracking/presentation/provider/result_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/ui/screens/notification_history_screen.dart';
import 'package:race_tracking/presentation/ui/screens/participant_screen.dart';
import 'package:race_tracking/presentation/ui/screens/race_segment.dart';
import 'package:race_tracking/presentation/ui/screens/result_screen.dart';
import 'package:race_tracking/presentation/widgets/icon_button_navbar.dart';
import 'package:race_tracking/presentation/widgets/notification_display_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create repositories
  final raceTimingRepository = RaceTimingRepositoryImpl(
    dataSource: FirebaseRaceTimingDataSource(),
  );

  final participantRepository = ParticipantRepositoryImpl(
    dataSource: FirebaseParticipantDataSource(),
  );

  final resultRepository = ResultRepositoryImpl(
    dataSource: FirebaseResultDataSource(),
  );

  // Create notification service and initialize it
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Provide the notification service
        Provider<NotificationService>.value(value: notificationService),

        // Race timing provider with notification service
        ChangeNotifierProvider(
          create:
              (_) => RaceTimingProvider(
                repository: raceTimingRepository,
                participantRepository: participantRepository,
                resultRepository: resultRepository,
                notificationService: notificationService,
              ),
        ),

        // Result provider remains unchanged
        ChangeNotifierProvider(
          create:
              (_) => ResultProvider(
                resultRepository: resultRepository,
                participantRepository: participantRepository,
              ),
        ),

        // Add notification history provider
        ChangeNotifierProvider(
          create:
              (_) => NotificationHistoryProvider(
                notificationService: notificationService,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Convert MyApp to StatefulWidget to manage notification subscription
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Triathlon Race Tracker',
      theme: appTheme,
      home: NotificationDisplayWidget(child: const MyHomePage()),
      routes: {
        '/notifications': (context) => const NotificationHistoryScreen(),
      },
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

  // All page widgets - fixed to match navigation items
  final List<Widget> _pages = [
    const ParticipantScreen(),
    const RaceSegment(),
    const ResultScreen(),
    const NotificationHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Add this to test notifications on startup with a longer delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Give more time for app to fully render
      Future.delayed(const Duration(seconds: 5), () => _testNotification());
    });
  }

  // Test notification function - you can remove this after confirming it works
  void _testNotification() {
    // Add additional safety checks
    if (!mounted) return;

    try {
      final notificationService = Provider.of<NotificationService>(
        context,
        listen: false,
      );

      notificationService.sendNotification(
        title: 'Welcome to Race Tracker',
        message: 'Enjoy tracking your racing!',
        type: NotificationType.raceStart,
        data: {'test': true},
      );

      print("✅ Test notification requested");
    } catch (e) {
      print("❌ Error sending test notification: $e");
    }
  }

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
      // Add badge to show unread notifications count
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: RTAColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed, // Important for 4+ items
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
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                IconButtonNavBar(
                  icon: Icons.notifications,
                  isSelected: _currentIndex == 3,
                ),
                Consumer<NotificationHistoryProvider>(
                  builder: (context, provider, child) {
                    final unreadCount = provider.notifications.length;
                    if (unreadCount <= 0) return const SizedBox.shrink();

                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child:
                            unreadCount > 9
                                ? const Text(
                                  '9+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                : const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
