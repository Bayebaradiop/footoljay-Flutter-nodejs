import 'api_client.dart';
import '../models/notification.dart';

class NotificationService {
  // Récupérer toutes mes notifications
  static Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '/notifications?page=$page&limit=$limit',
    );
    return (response['notifications'] as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  // Récupérer le nombre de notifications non lues
  static Future<int> getUnreadCount() async {
    final response = await ApiClient.get('/notifications/unread-count');
    return response['unreadCount'] ?? 0;
  }

  // Marquer une notification comme lue
  static Future<void> markAsRead(String id) async { // ✅ Changé de int à String
    await ApiClient.put('/notifications/$id/read', {});
  }

  // Marquer toutes les notifications comme lues
  static Future<void> markAllAsRead() async {
    await ApiClient.put('/notifications/read-all', {});
  }

  // Supprimer une notification
  static Future<void> deleteNotification(String id) async { // ✅ Changé de int à String
    await ApiClient.delete('/notifications/$id');
  }

  // Supprimer toutes les notifications lues
  static Future<void> deleteAllRead() async {
    final notifications = await getNotifications();
    for (var notification in notifications) {
      if (notification.isRead) {
        await deleteNotification(notification.id);
      }
    }
  }
}
