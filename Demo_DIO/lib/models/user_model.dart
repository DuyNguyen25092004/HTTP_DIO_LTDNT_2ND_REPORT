class UserModel {
  final String id;
  final String email;
  final String password;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
