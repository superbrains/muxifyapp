import 'dart:convert';

/// Matches `POST /api/v1/auth/login` JSON (camelCase from ASP.NET).
class AuthUserDto {
  const AuthUserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final String? avatar;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatar: json['avatar'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  AuthUserDto copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? avatar,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'avatar': avatar,
    'isVerified': isVerified,
    if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
  };

  /// Restore from prefs ([LocalStorageService.getAuthUserJson]).
  static AuthUserDto? tryParseStored(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUserDto.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}

class AuthLoginResult {
  const AuthLoginResult({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  final AuthUserDto user;
  final String token;
  final String refreshToken;

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;
    if (userMap == null) {
      throw FormatException('Missing user object in login response');
    }
    return AuthLoginResult(
      user: AuthUserDto.fromJson(userMap),
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  /// Round-trip for persistence / debugging (matches API shape).
  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'token': token,
        'refreshToken': refreshToken,
      };
}
