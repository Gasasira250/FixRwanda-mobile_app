enum UserRole {
  customer,
  professional,
  admin,
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final String? address;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.address,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}