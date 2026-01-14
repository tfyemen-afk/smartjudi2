/// Lawsuit Model
class LawsuitModel {
  final int? id;
  final String caseNumber;
  final String caseType;
  final String status;
  final String? caseStatus; // New field
  final String? subject; // New field
  final String? description;
  final String? facts; // New field
  final String? legalBasis; // New field
  final String? legalReasons; // New field
  final String? requests; // New field
  final String? governorate; // New field
  final String? notes; // New field
  final DateTime? filingDate;
  final int? courtId;
  final String? courtName;
  final int? judgeId;
  final String? judgeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LawsuitModel({
    this.id,
    required this.caseNumber,
    required this.caseType,
    this.status = 'pending',
    this.caseStatus,
    this.subject,
    this.description,
    this.facts,
    this.legalBasis,
    this.legalReasons,
    this.requests,
    this.governorate,
    this.notes,
    this.filingDate,
    this.courtId,
    this.courtName,
    this.judgeId,
    this.judgeName,
    this.createdAt,
    this.updatedAt,
  });

  factory LawsuitModel.fromJson(Map<String, dynamic> json) {
    return LawsuitModel(
      id: json['id'],
      caseNumber: json['case_number'] ?? '',
      caseType: json['case_type'] ?? '',
      status: json['status'] ?? 'pending',
      caseStatus: json['case_status'],
      subject: json['subject'],
      description: json['description'],
      facts: json['facts'],
      legalBasis: json['legal_basis'],
      legalReasons: json['legal_reasons'],
      requests: json['requests'],
      governorate: json['governorate'],
      notes: json['notes'],
      filingDate: json['filing_date'] != null 
          ? DateTime.parse(json['filing_date']) 
          : null,
      courtId: json['court_fk'] ?? json['court'] ?? json['court_id'],
      courtName: json['court_detail'] != null 
          ? json['court_detail']['court_name'] 
          : json['court_name'],
      judgeId: json['judge'] ?? json['judge_id'],
      judgeName: json['judge_name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'case_number': caseNumber,
      'case_type': caseType,
      if (status.isNotEmpty) 'status': status,
      if (caseStatus != null) 'case_status': caseStatus,
      if (subject != null) 'subject': subject,
      if (description != null) 'description': description,
      if (facts != null) 'facts': facts,
      if (legalBasis != null) 'legal_basis': legalBasis,
      if (legalReasons != null) 'legal_reasons': legalReasons,
      if (requests != null) 'requests': requests,
      if (governorate != null) 'governorate': governorate,
      if (notes != null) 'notes': notes,
      if (filingDate != null) 'filing_date': filingDate!.toIso8601String().split('T')[0],
      if (courtId != null) 'court_fk': courtId,
      if (judgeId != null) 'judge': judgeId,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتملة';
      case 'appealed':
        return 'مستأنفة';
      case 'closed':
        return 'مغلقة';
      default:
        return status;
    }
  }

  String get caseTypeDisplay {
    switch (caseType) {
      case 'امر_اداء':
        return 'أمر أداء';
      case 'دعوى':
        return 'دعوى';
      case 'رد_على_دعوى':
        return 'رد على دعوى';
      case 'استئناف':
        return 'استئناف';
      case 'طعن':
        return 'طعن';
      case 'civil':
        return 'مدنية';
      case 'criminal':
        return 'جنائية';
      case 'commercial':
        return 'تجارية';
      case 'administrative':
        return 'إدارية';
      case 'family':
        return 'أحوال شخصية';
      default:
        return caseType;
    }
  }
}

