class AuthResponseModel {
  final String id;
  final String email;
  final String rol;

  AuthResponseModel({
    required this.id,
    required this.email,
    required this.rol,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Soporta respuestas directas o anidadas dentro de un objeto "user" / "data"
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user']
        : (json['data'] is Map<String, dynamic> ? json['data'] : json);

    return AuthResponseModel(
      id: (userMap['id'] ?? json['id'])?.toString() ?? '',
      email: userMap['email'] ?? json['email'] ?? '',
      rol: userMap['rol'] ?? json['rol'] ?? userMap['role'] ?? json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'rol': rol,
    };
  }
}