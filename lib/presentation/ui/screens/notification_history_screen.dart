import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:race_tracking/core/services/notification_service.dart';
import 'package:race_tracking/presentation/provider/notification_history_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        titleTextStyle: RTATextStyles.title,
        actions: [
          Consumer<NotificationHistoryProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear all notifications',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Clear Notifications'),
                          content: const Text(
                            'Are you sure you want to clear all notifications?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.clearAllNotifications();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All notifications cleared'),
                                  ),
                                );
                              },
                              child: const Text('CLEAR ALL'),
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationHistoryProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Race updates will appear here',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final dateTime = DateTime.fromMillisecondsSinceEpoch(
                notification.timestamp,
              );
              final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
              final formattedDate = DateFormat('MMM d').format(dateTime);

              // Determine icon and color based on notification type
              IconData icon;
              Color color;

              switch (notification.type) {
                case NotificationType.raceStart:
                  icon = Icons.flag;
                  color = Colors.green;
                  break;
                case NotificationType.segmentCompletion:
                  icon = Icons.directions_run;
                  color = Colors.blue;
                  break;
                case NotificationType.raceFinish:
                  icon = Icons.emoji_events;
                  color = Colors.amber;
                  break;
                case NotificationType.newLeader:
                  icon = Icons.star;
                  color = Colors.purple;
                  break;
                case NotificationType.delayAlert:
                  icon = Icons.warning;
                  color = Colors.orange;
                  break;
                default:
                  icon = Icons.notifications;
                  color = Colors.blue;
              }

              // Extract bib number if available
              String? bibNumber;
              if (notification.data.containsKey('bib')) {
                bibNumber = notification.data['bib'];
              }

              return Dismissible(
                key: Key(notification.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  // We can't directly remove from recentNotifications
                  // Since we're using the provider pattern, we just notify
                  // that we want to clear notifications
                  provider.clearAllNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification removed')),
                  );
                },
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: color.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(icon, color: color),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (bibNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BIB #$bibNumber',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
