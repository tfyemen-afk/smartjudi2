/// User Model
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? nationalId;
  final String? phone;
  final String? address;
  final int? courtId;
  final String? courtName;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.nationalId,
    this.phone,
    this.address,
    this.courtId,
    this.courtName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object from Django
    final userData = json['user'] ?? json;
    
    // Validate required fields
    if (userData['id'] == null) {
      throw Exception('User ID is missing in response');
    }
    if (userData['username'] == null && json['username'] == null) {
      throw Exception('Username is missing in response');
    }
    if (json['role'] == null) {
      throw Exception('User role is missing in response');
    }
    
    return UserModel(
      id: userData['id'] ?? json['id'] ?? 0,
      username: json['username'] ?? userData['username'] ?? '',
      email: json['email'] ?? userData['email'] ?? '',
      firstName: json['first_name'] ?? userData['first_name'],
      lastName: json['last_name'] ?? userData['last_name'],
      role: json['role'] ?? '',
      nationalId: json['national_id'],
      phone: json['phone_number'] ?? json['phone'],
      address: json['address'],
      courtId: json['court'] ?? json['court_id'],
      courtName: json['court_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'national_id': nationalId,
      'phone': phone,
      'address': address,
      'court_id': courtId,
      'court_name': courtName,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isJudge => role == 'judge';
  bool get isLawyer => role == 'lawyer';
  bool get isCitizen => role == 'citizen';
  bool get isAdmin => role == 'admin';
  bool get isNotary => role == 'notary';
}

