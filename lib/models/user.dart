class User {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final List<String> favoritos;
  final List<String> comentarios;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.favoritos,
    required this.comentarios,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      favoritos: List<String>.from(map['favoritos'] ?? []),
      comentarios: List<String>.from(map['comentarios'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'favoritos': favoritos,
      'comentarios': comentarios,
    };
  }
}
