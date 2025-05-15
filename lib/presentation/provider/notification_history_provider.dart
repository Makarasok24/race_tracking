import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:race_tracking/core/services/notification_service.dart';

class NotificationHistoryProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  // Active notifications to display in UI
  final List<RaceNotification> _activeNotifications = [];
  List<RaceNotification> get activeNotifications =>
      List.unmodifiable(_activeNotifications);

  // Get notifications from service
  List<RaceNotification> get notifications =>
      _notificationService.recentNotifications;

  late StreamSubscription<RaceNotification> _subscription;

  NotificationHistoryProvider({
    required NotificationService notificationService,
  }) : _notificationService = notificationService {
    // Subscribe to notification stream
    _subscription = _notificationService.notificationStream.listen((
      notification,
    ) {
      // Only add race start and race finish notifications
      if (notification.type == NotificationType.raceStart ||
          notification.type == NotificationType.raceFinish) {
        _activeNotifications.add(notification);
        notifyListeners();

        // Auto-dismiss after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (_activeNotifications.contains(notification)) {
            _activeNotifications.remove(notification);
            notifyListeners();
          }
        });
      }
    });
  }

  // Dismiss a specific notification
  void dismissNotification(RaceNotification notification) {
    if (_activeNotifications.contains(notification)) {
      _activeNotifications.remove(notification);
      notifyListeners();
    }
  }

  // Clear all notifications from history
  void clearAllNotifications() {
    _notificationService.clearNotifications();
    _activeNotifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
