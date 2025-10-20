// TODO: Implémenter le modèle Notification

class NotificationModel {
  final String id; // ✅ Changé de int à String pour UUID
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? productId; // ✅ Changé de int à String pour UUID

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.productId,
  });

  // Convertir JSON en NotificationModel
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      productId: json['productId'] as String?,
    );
  }

  // Convertir NotificationModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'productId': productId,
    };
  }

  // Icône selon le type de notification
  String get icon {
    switch (type) {
      case 'PRODUCT_APPROVED':
        return '✅';
      case 'PRODUCT_REJECTED':
        return '❌';
      case 'PRODUCT_EXPIRING':
        return '⏰';
      case 'PRODUCT_EXPIRED':
        return '⏱️';
      case 'GENERAL':
        return '📢';
      default:
        return '🔔';
    }
  }

  // Label du type en français
  String get typeLabel {
    switch (type) {
      case 'PRODUCT_APPROVED':
        return 'Produit approuvé';
      case 'PRODUCT_REJECTED':
        return 'Produit rejeté';
      case 'PRODUCT_EXPIRING':
        return 'Produit expire bientôt';
      case 'PRODUCT_EXPIRED':
        return 'Produit expiré';
      case 'GENERAL':
        return 'Notification générale';
      default:
        return 'Notification';
    }
  }
}
