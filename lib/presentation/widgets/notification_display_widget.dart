import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/core/services/notification_service.dart';
import 'package:race_tracking/presentation/provider/notification_history_provider.dart';

class NotificationDisplayWidget extends StatelessWidget {
  final Widget child;

  const NotificationDisplayWidget({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationHistoryProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            child, 
            if (provider.activeNotifications.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
                child: Column(
                  children:
                      provider.activeNotifications.map((notification) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: NotificationBanner(
                            notification: notification,
                            onDismiss:
                                () =>
                                    provider.dismissNotification(notification),
                            onTap: () {
                              Navigator.of(context).pushNamed('/notifications');
                              provider.dismissNotification(notification);
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}
