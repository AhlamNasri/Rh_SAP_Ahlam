class AuthUser {
  const AuthUser({
    required this.token,
    required this.email,
    required this.roles,
    required this.fullName,
    this.userId,
    this.employeeId,
  });

  final String token;
  final String email;
  final List<String> roles;
  final String fullName;
  final int? userId;
  final int? employeeId;

  factory AuthUser.fromLogin(Map<String, dynamic> json) {
    return AuthUser(
      token: json['token']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: List<String>.from(json['roles'] ?? const []),
      fullName: json['fullName']?.toString() ?? json['email']?.toString() ?? '',
      userId: (json['userId'] as num?)?.toInt(),
      employeeId: (json['employeeId'] as num?)?.toInt(),
    );
  }

  factory AuthUser.fromMe(Map<String, dynamic> json, String token) {
    return AuthUser(
      token: token,
      email: json['email']?.toString() ?? '',
      roles: List<String>.from(json['roles'] ?? const []),
      fullName: json['employeeName']?.toString() ?? json['email']?.toString() ?? '',
      userId: (json['id'] as num?)?.toInt(),
      employeeId: (json['employeeId'] as num?)?.toInt(),
    );
  }
}
