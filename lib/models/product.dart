import 'user.dart';

class Product {
  final String id; // ✅ Changé de int à String pour UUID
  final String title;
  final String description;
  final List<String> photos;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String sellerId; // ✅ Changé userId en sellerId pour correspondre au backend
  final User? user;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.photos,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    required this.sellerId,
    this.user,
  });

  // Convertir JSON en Product
  factory Product.fromJson(Map<String, dynamic> json) {
    // Extraire les URLs des photos depuis le tableau d'objets photos
    List<String> photoUrls = [];
    if (json['photos'] != null && json['photos'] is List) {
      photoUrls = (json['photos'] as List)
          .map((photo) {
            if (photo is Map<String, dynamic> && photo['url'] != null) {
              return photo['url'] as String;
            }
            return null;
          })
          .whereType<String>() // Filtrer les null
          .toList();
    }

    // Le backend peut renvoyer 'user' ou 'seller', on accepte les deux
    Map<String, dynamic>? userOrSellerData;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      userOrSellerData = json['user'] as Map<String, dynamic>;
    } else if (json['seller'] != null && json['seller'] is Map<String, dynamic>) {
      userOrSellerData = json['seller'] as Map<String, dynamic>;
    }

    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      photos: photoUrls,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      sellerId: json['sellerId'] as String,
      user: userOrSellerData != null ? User.fromJson(userOrSellerData) : null,
    );
  }

  // Convertir Product en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photos': photos,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'sellerId': sellerId, // ✅ Corrigé userId en sellerId
      'user': user?.toJson(),
    };
  }

  // Getters pour vérifier le statut
  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isExpired => status == 'EXPIRED';
  
  // Alias pour user -> seller (compatibilité)
  User? get seller => user;

  // Label du statut en français
  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Approuvé';
      case 'REJECTED':
        return 'Rejeté';
      case 'EXPIRED':
        return 'Expiré';
      default:
        return status;
    }
  }

  // Couleur selon le statut
  String get statusColor {
    switch (status) {
      case 'PENDING':
        return 'orange';
      case 'APPROVED':
        return 'green';
      case 'REJECTED':
        return 'red';
      case 'EXPIRED':
        return 'grey';
      default:
        return 'grey';
    }
  }
}
