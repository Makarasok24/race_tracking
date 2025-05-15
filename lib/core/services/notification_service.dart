import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/firebase_config.dart';

class RaceNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic> data;
  final int timestamp;

  RaceNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.data,
    int? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'data': data,
      'timestamp': timestamp,
    };
  }

  factory RaceNotification.fromJson(Map<String, dynamic> json) {
    return RaceNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values[json['type']],
      data: json['data'] ?? {},
      timestamp: json['timestamp'],
    );
  }
}

// Types of notifications in the race tracking app
enum NotificationType {
  raceStart,
  segmentCompletion,
  raceFinish,
  newLeader,
  delayAlert,
}

class NotificationService {
  // Firebase path for notifications
  final String _notificationsPath =
      FirebaseConfig.baseUrl + 'notifications.json';

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controller for notifications
  final _notificationController =
      StreamController<RaceNotification>.broadcast();
  Stream<RaceNotification> get notificationStream =>
      _notificationController.stream;

  // Recent notifications cache
  List<RaceNotification> _recentNotifications = [];
  List<RaceNotification> get recentNotifications => _recentNotifications;

  // Initialize notification service
  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        final payload = response.payload;
        if (payload != null) {
          final data = json.decode(payload);
          final notification = RaceNotification.fromJson(data);
          _notificationController.add(notification);
        }
      },
    );

    // Request permissions on iOS
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Load recent notifications
    await _loadRecentNotifications();
  }

  // Send a race notification
  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic> data = const {},
  }) async {
    // Only process race start and race finish notifications
    if (type != NotificationType.raceStart &&
        type != NotificationType.raceFinish) {
      return;
    }

    final notification = RaceNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      data: data,
    );

    try {
      // Add to recent notifications
      _recentNotifications.insert(0, notification);
      if (_recentNotifications.length > 20) {
        _recentNotifications.removeLast();
      }

      // Show local notification
      await _showLocalNotification(notification);

      // Add to stream
      _notificationController.add(notification);

      // Store in Firebase
      _saveNotificationToFirebase(notification);
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RaceNotification notification) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'race_tracking_channel',
        'Race Tracking',
        channelDescription: 'Notifications for race tracking updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Generate notification ID from timestamp
      final notificationId = int.parse(
        notification.timestamp.toString().substring(
          notification.timestamp.toString().length - 9,
        ),
      );

      await _localNotifications.show(
        notificationId,
        notification.title,
        notification.message,
        notificationDetails,
        payload: json.encode(notification.toJson()),
      );
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // Save notification to Firebase
  Future<void> _saveNotificationToFirebase(
    RaceNotification notification,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_notificationsPath),
        body: json.encode(notification.toJson()),
      );

      if (response.statusCode != 200) {
        print('❌ Firebase error: ${response.body}');
      }
    } catch (e) {
      print('❌ Error saving notification to Firebase: $e');
    }
  }

  // Load recent notifications from Firebase
  Future<void> _loadRecentNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(_notificationsPath + '?orderBy="timestamp"&limitToLast=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map) {
          final notifications = <RaceNotification>[];
          data.forEach((key, value) {
            try {
              final notification = RaceNotification.fromJson(value);
              // Only add race start and race finish notifications
              if (notification.type == NotificationType.raceStart ||
                  notification.type == NotificationType.raceFinish) {
                notifications.add(notification);
              }
            } catch (e) {
              print('❌ Error parsing notification: $e');
            }
          });

          // Sort by timestamp (newest first)
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _recentNotifications = notifications;
        }
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
    }
  }

  // Race start notification
  Future<void> notifyRaceStart(int participantCount) {
    return sendNotification(
      title: 'Race Started!',
      message: 'The race has begun with $participantCount participants',
      type: NotificationType.raceStart,
      data: {
        'participantCount': participantCount,
        'startTime': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Race finish notification
  Future<void> notifyRaceFinish(
    String bib,
    String participantName,
    int rank,
    int totalTime,
  ) {
    return sendNotification(
      title: 'Race Finished!',
      message:
          '${participantName.isNotEmpty ? participantName : "Participant #$bib"} has finished in ${_getOrdinal(rank)} place with a time of ${_formatTime(totalTime)}',
      type: NotificationType.raceFinish,
      data: {
        'bib': bib,
        'name': participantName,
        'rank': rank,
        'totalTime': totalTime,
      },
    );
  }

  // Clear all notifications
  void clearNotifications() {
    _recentNotifications.clear();
  }

  // Format time in HH:MM:SS
  String _formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  // Get ordinal suffix for numbers (1st, 2nd, 3rd, etc.)
  String _getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // Clean up resources
  void dispose() {
    _notificationController.close();
  }
}

// Widget to display a notification banner
class NotificationBanner extends StatefulWidget {
  final RaceNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const NotificationBanner({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine icon based on notification type
    IconData icon;
    Color iconColor;

    switch (widget.notification.type) {
      case NotificationType.raceStart:
        icon = Icons.flag;
        iconColor = Colors.green;
        break;
      case NotificationType.raceFinish:
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.blue;
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.notification.message,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16),
                  onPressed: () {
                    _controller.reverse().then((_) {
                      widget.onDismiss?.call();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
