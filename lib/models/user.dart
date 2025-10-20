class User {
  final String id; // ✅ Changé de int à String pour supporter les UUID
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final bool isVip;
  final bool isActive;
  final DateTime? createdAt; // ✅ Nullable car pas toujours renvoyé
  final DateTime? updatedAt; // ✅ Date de dernière modification
  final int? productsCount; // ✅ Nombre de produits (pour admin)

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.isVip,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.productsCount,
  });

  // Convertir JSON en User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String, // UUID
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String? ?? '', // Au cas où non fourni
      role: json['role'] as String? ?? 'USER', // Valeur par défaut si non fourni
      isVip: json['isVip'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true, // Valeur par défaut si non fourni
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      productsCount: json['_count'] != null 
          ? (json['_count']['products'] as int?)
          : null,
    );
  }

  // Convertir User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'isVip': isVip,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Getters utiles
  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'ADMIN';
  bool get isModerator => role == 'MODERATOR';
  bool get isUser => role == 'USER';
  bool get isSeller => role == 'SELLER';
}
