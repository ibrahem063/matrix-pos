class AppUserModel {
  final String id;
  final String name;
  final String email;
  final String role; // admin or cashier

  const AppUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
  bool get isCashier => role == 'cashier';

  factory AppUserModel.fromMap(String id, Map<String, dynamic> data) {
    return AppUserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'cashier',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
