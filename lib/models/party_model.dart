/// Party Model - Base model for Plaintiff and Defendant
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
    this.createdAt,
    this.updatedAt,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'],
      lawsuitId: json['lawsuit'] is int 
          ? json['lawsuit'] as int
          : (json['lawsuit'] is Map ? (json['lawsuit'] as Map)['id'] : null) ?? json['lawsuit_id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? 'male',
      nationality: json['nationality'] ?? '',
      occupation: json['occupation'],
      address: json['address'] ?? '',
      phone: json['phone'],
      attorneyName: json['attorney_name'],
      attorneyPhone: json['attorney_phone'],
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
}

/// Plaintiff Model
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
    super.createdAt,
    super.updatedAt,
  });

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
      createdAt: party.createdAt,
      updatedAt: party.updatedAt,
    );
  }
}

/// Defendant Model
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
    super.createdAt,
    super.updatedAt,
  });

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
      createdAt: party.createdAt,
      updatedAt: party.updatedAt,
    );
  }
}

