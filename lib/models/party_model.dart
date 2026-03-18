/// Party Model - Base model for all case participants
///
/// Covers all party roles used in the Yemeni judicial system:
///   plaintiff     → المدعي
///   defendant     → المدعى عليه
///   witness       → الشاهد
///   expert        → الخبير
///   legal_agent   → الوكيل القانوني
///   notary        → الأمين الشرعي
///
/// The [role] field distinguishes party type on models that use a single
/// unified parties table. [PlaintiffModel] and [DefendantModel] are kept
/// as typed sub-classes for backward-compatibility with existing API calls.
class PartyModel {
  final int? id;
  final int lawsuitId;
  final String name;
  final String gender;
  final String nationality;
  final String? occupation;
  final String address;
  final String? phone;
  final String? attorneyName;
  final String? attorneyPhone;

  /// رقم الهوية الوطنية / رقم السجل التجاري
  final String? idNumber;

  /// دور الطرف في القضية (plaintiff | defendant | witness | expert |
  /// legal_agent | notary)
  ///
  /// القيم الافتراضية القديمة (plaintiff / defendant) محفوظة
  /// للتوافق مع الـ API الحالي.
  final String role;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  PartyModel({
    this.id,
    required this.lawsuitId,
    required this.name,
    required this.gender,
    required this.nationality,
    this.occupation,
    required this.address,
    this.phone,
    this.attorneyName,
    this.attorneyPhone,
    this.idNumber,
    this.role = 'plaintiff',
    this.createdAt,
    this.updatedAt,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'],
      lawsuitId: json['lawsuit'] is int
          ? json['lawsuit'] as int
          : (json['lawsuit'] is Map
                  ? (json['lawsuit'] as Map)['id']
                  : null) ??
              json['lawsuit_id'] ??
              0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? 'male',
      nationality: json['nationality'] ?? '',
      occupation: json['occupation'],
      address: json['address'] ?? '',
      phone: json['phone'],
      attorneyName: json['attorney_name'],
      attorneyPhone: json['attorney_phone'],
      idNumber: json['id_number'],
      role: json['role'] ?? 'plaintiff',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lawsuit_id': lawsuitId,
      'name': name,
      'gender': gender,
      'nationality': nationality,
      if (occupation != null) 'occupation': occupation,
      'address': address,
      if (phone != null) 'phone': phone,
      if (attorneyName != null) 'attorney_name': attorneyName,
      if (attorneyPhone != null) 'attorney_phone': attorneyPhone,
      if (idNumber != null) 'id_number': idNumber,
      'role': role,
    };
  }

  String get genderDisplay {
    switch (gender) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return gender;
    }
  }

  /// عرض دور الطرف بالعربية
  String get roleDisplay {
    switch (role) {
      case 'plaintiff':
        return 'مدعي';
      case 'defendant':
        return 'مدعى عليه';
      case 'witness':
        return 'شاهد';
      case 'expert':
        return 'خبير';
      case 'legal_agent':
        return 'وكيل قانوني';
      case 'notary':
        return 'أمين شرعي';
      default:
        return role;
    }
  }
}

/// Plaintiff Model - backward-compatible wrapper
class PlaintiffModel extends PartyModel {
  PlaintiffModel({
    super.id,
    required super.lawsuitId,
    required super.name,
    required super.gender,
    required super.nationality,
    super.occupation,
    required super.address,
    super.phone,
    super.attorneyName,
    super.attorneyPhone,
    super.idNumber,
    super.createdAt,
    super.updatedAt,
  }) : super(role: 'plaintiff');

  factory PlaintiffModel.fromJson(Map<String, dynamic> json) {
    final party = PartyModel.fromJson(json);
    return PlaintiffModel(
      id: party.id,
      lawsuitId: party.lawsuitId,
      name: party.name,
      gender: party.gender,
      nationality: party.nationality,
      occupation: party.occupation,
      address: party.address,
      phone: party.phone,
      attorneyName: party.attorneyName,
      attorneyPhone: party.attorneyPhone,
      idNumber: party.idNumber,
      createdAt: party.createdAt,
      updatedAt: party.updatedAt,
    );
  }
}

/// Defendant Model - backward-compatible wrapper
class DefendantModel extends PartyModel {
  DefendantModel({
    super.id,
    required super.lawsuitId,
    required super.name,
    required super.gender,
    required super.nationality,
    super.occupation,
    required super.address,
    super.phone,
    super.attorneyName,
    super.attorneyPhone,
    super.idNumber,
    super.createdAt,
    super.updatedAt,
  }) : super(role: 'defendant');

  factory DefendantModel.fromJson(Map<String, dynamic> json) {
    final party = PartyModel.fromJson(json);
    return DefendantModel(
      id: party.id,
      lawsuitId: party.lawsuitId,
      name: party.name,
      gender: party.gender,
      nationality: party.nationality,
      occupation: party.occupation,
      address: party.address,
      phone: party.phone,
      attorneyName: party.attorneyName,
      attorneyPhone: party.attorneyPhone,
      idNumber: party.idNumber,
      createdAt: party.createdAt,
      updatedAt: party.updatedAt,
    );
  }
}
