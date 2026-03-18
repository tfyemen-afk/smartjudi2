/// Lawsuit Model - with archive lifecycle support
/// Represents a full legal case in the SmartJudi archive system.
///
/// Field mapping to Django backend (smartju app):
///   court_level      → first_instance | appeal | supreme
///   department       → free-text court department/chamber
///   lawyer_id        → FK to auth user acting as lawyer
///   ai_summary       → AI-generated case summary (nullable)
///   related_laws     → JSON list of relevant law article IDs
///   similar_cases    → JSON list of similar case IDs
///   legal_risk_level → low | medium | high  (AI output)
///   success_probability → 0.0–1.0 float (AI output)
class LawsuitModel {
  final int? id;
  final String caseNumber;
  final String caseType;
  final String status;
  final String? caseStatus;
  final String? subject;
  final String? description;
  final String? facts;
  final String? legalBasis;
  final String? legalReasons;
  final String? requests;
  final String? governorate;
  final String? notes;
  final DateTime? filingDate;
  final DateTime? gregorianDate;
  final String? hijriDate;
  final int? courtId;
  final String? courtName;
  final int? judgeId;
  final String? judgeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Court level & department (Step 2) ──────────────────────────────────────
  /// درجة المحكمة: first_instance | appeal | supreme
  final String? courtLevel;

  /// الشعبة / الدائرة المختصة داخل المحكمة
  final String? department;

  // ── Lawyer assignment (Step 2) ────────────────────────────────────────────
  /// معرّف المحامي المسؤول عن هذه القضية (FK إلى جدول المستخدمين)
  final int? lawyerId;

  /// اسم المحامي للعرض (قادم من backend)
  final String? lawyerName;

  // ── Archive lifecycle fields ───────────────────────────────────────────────
  final String archiveStatus;
  final DateTime? archiveDate;
  final String? archiveReason;
  final bool isDeleted;
  final DateTime? deletedAt;
  final int? parentLawsuitId;

  // ── Counts (denormalised from backend serializer) ─────────────────────────
  final int childLawsuitsCount;
  final int plaintiffsCount;
  final int defendantsCount;
  final int attachmentsCount;
  final int hearingsCount;
  final int judgmentsCount;

  // ── AI Legal Analysis Layer (Step 7) ──────────────────────────────────────
  /// ملخص ذكاء اصطناعي للقضية (يُنشأ من نظام RAG)
  final String? aiSummary;

  /// قائمة مراجع المواد القانونية المرتبطة بالقضية (JSON array of strings)
  final List<String> relatedLaws;

  /// قائمة أرقام القضايا المشابهة (JSON array of strings)
  final List<String> similarCases;

  /// مستوى المخاطرة القانونية: low | medium | high
  final String? legalRiskLevel;

  /// احتمالية النجاح (0.0 – 1.0)
  final double? successProbability;

  // ── RAG Metadata (Step 10) ────────────────────────────────────────────────
  /// بيانات وصفية إضافية لفهرسة RAG (JSON object كـ string)
  final String? ragMetadata;

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
    this.gregorianDate,
    this.hijriDate,
    this.courtId,
    this.courtName,
    this.judgeId,
    this.judgeName,
    this.createdAt,
    this.updatedAt,
    // New fields
    this.courtLevel,
    this.department,
    this.lawyerId,
    this.lawyerName,
    // Archive
    this.archiveStatus = 'active',
    this.archiveDate,
    this.archiveReason,
    this.isDeleted = false,
    this.deletedAt,
    this.parentLawsuitId,
    // Counts
    this.childLawsuitsCount = 0,
    this.plaintiffsCount = 0,
    this.defendantsCount = 0,
    this.attachmentsCount = 0,
    this.hearingsCount = 0,
    this.judgmentsCount = 0,
    // AI
    this.aiSummary,
    this.relatedLaws = const [],
    this.similarCases = const [],
    this.legalRiskLevel,
    this.successProbability,
    this.ragMetadata,
  });

  factory LawsuitModel.fromJson(Map<String, dynamic> json) {
    // Helper: parse a JSON array field that might come as List or null
    List<String> _parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

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
      gregorianDate: json['gregorian_date'] != null
          ? DateTime.parse(json['gregorian_date'])
          : null,
      hijriDate: json['hijri_date'],
      courtId: json['court_fk'] ?? json['court'] ?? json['court_id'],
      courtName: json['court_detail'] != null
          ? json['court_detail']['court_name']
          : json['court_name'],
      judgeId: json['judge'] ?? json['judge_id'],
      judgeName: json['judge_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      // Court level & department
      courtLevel: json['court_level'],
      department: json['department'],
      // Lawyer
      lawyerId: json['lawyer'] ?? json['lawyer_id'],
      lawyerName: json['lawyer_name'],
      // Archive fields
      archiveStatus: json['archive_status'] ?? 'active',
      archiveDate: json['archive_date'] != null
          ? DateTime.parse(json['archive_date'])
          : null,
      archiveReason: json['archive_reason'],
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      parentLawsuitId: json['parent_lawsuit'],
      // Counts
      childLawsuitsCount: json['child_lawsuits_count'] ?? 0,
      plaintiffsCount: json['plaintiffs_count'] ?? 0,
      defendantsCount: json['defendants_count'] ?? 0,
      attachmentsCount: json['attachments_count'] ?? 0,
      hearingsCount: json['hearings_count'] ?? 0,
      judgmentsCount: json['judgments_count'] ?? 0,
      // AI fields
      aiSummary: json['ai_summary'],
      relatedLaws: _parseStringList(json['related_laws']),
      similarCases: _parseStringList(json['similar_cases']),
      legalRiskLevel: json['legal_risk_level'],
      successProbability: json['success_probability'] != null
          ? double.tryParse(json['success_probability'].toString())
          : null,
      ragMetadata: json['rag_metadata']?.toString(),
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
      if (filingDate != null)
        'filing_date': filingDate!.toIso8601String().split('T')[0],
      if (gregorianDate != null)
        'gregorian_date': gregorianDate!.toIso8601String().split('T')[0],
      if (hijriDate != null) 'hijri_date': hijriDate,
      if (courtId != null) 'court_fk': courtId,
      if (judgeId != null) 'judge': judgeId,
      if (parentLawsuitId != null) 'parent_lawsuit': parentLawsuitId,
      // New fields
      if (courtLevel != null) 'court_level': courtLevel,
      if (department != null) 'department': department,
      if (lawyerId != null) 'lawyer': lawyerId,
    };
  }

  // ── Display helpers ────────────────────────────────────────────────────────

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
      case 'personal_status':
        return 'أحوال شخصية';
      case 'labor':
        return 'عمالية';
      default:
        return caseType;
    }
  }

  String get archiveStatusDisplay {
    switch (archiveStatus) {
      case 'active':
        return 'نشط';
      case 'semi_active':
        return 'شبه نشط';
      case 'archived':
        return 'محفوظ';
      default:
        return archiveStatus;
    }
  }

  String get caseStatusDisplay {
    final s = caseStatus ?? '';
    switch (s) {
      case 'جديد':
        return 'جديد';
      case 'قيد_النظر':
        return 'قيد النظر';
      case 'مكتمل':
        return 'مكتمل';
      case 'مغلق':
        return 'مغلق';
      default:
        return s.isNotEmpty ? s : statusDisplay;
    }
  }

  /// درجة المحكمة للعرض بالعربية
  String get courtLevelDisplay {
    switch (courtLevel ?? '') {
      case 'first_instance':
        return 'ابتدائي';
      case 'appeal':
        return 'استئناف';
      case 'supreme':
        return 'عليا / تمييز';
      default:
        return courtLevel ?? '';
    }
  }

  /// مستوى المخاطرة للعرض
  String get legalRiskDisplay {
    switch (legalRiskLevel ?? '') {
      case 'low':
        return 'منخفض';
      case 'medium':
        return 'متوسط';
      case 'high':
        return 'عالٍ';
      default:
        return legalRiskLevel ?? '—';
    }
  }

  /// احتمالية النجاح كنسبة مئوية
  String get successProbabilityDisplay {
    if (successProbability == null) return '—';
    return '${(successProbability! * 100).toStringAsFixed(0)}٪';
  }
}
