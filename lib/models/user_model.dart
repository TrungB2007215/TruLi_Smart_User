class UserModel {
  // String userId;
  final String user_name;
  final String email;
  final String password;
  final String avatar;
  final String role;

  UserModel({
    // required this.userId,
    required this.user_name,
    required this.email,
    required this.password,
    required this.avatar,
    required this.role,
  });

  // Factory constructor để tạo một đối tượng từ Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      // userId: map['userId'],
      user_name: map['user_name'],
      email: map['email'],
      password: map['password'],
      avatar: map['avatar'],
      role: map['role'],
    );
  }

  // Hàm chuyển đổi đối tượng UserModel thành Map
  Map<String, dynamic> toMap() {
    return {

      'user_name': user_name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'role': role,
    };
  }
}
