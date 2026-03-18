/// Judgment Model - حكم قضائي
///
/// Represents a court judgment issued for a lawsuit.
/// Maps to the Django `Judgment` model at endpoint `/api/judgments/`.
///
/// Court levels (court_level):
///   first_instance → ابتدائي
///   appeal         → استئناف
///   supreme        → عليا / تمييز
///
/// Judgment types (judgment_type):
///   conviction     → إدانة
///   acquittal      → تبرئة
///   civil_for      → للمدعي
///   civil_against  → على المدعى عليه
///   dismissed      → رُفضت
///   partial        → جزئي
///   other          → أخرى
class JudgmentModel {
  final int? id;
  final int lawsuitId;
  final String? lawsuitNumber;

  /// درجة المحكمة التي أصدرت الحكم
  final String courtLevel;

  /// تاريخ الحكم (ميلادي)
  final DateTime judgmentDate;

  /// تاريخ الحكم (هجري)
  final String? hijriDate;

  /// نوع الحكم
  final String judgmentType;

  /// ملخص الحكم (مختصر)
  final String summary;

  /// نص الحكم الكامل (اختياري - قد يكون طويلاً)
  final String? fullText;

  /// مرجع الوثيقة / رقم الملف المرفق
  final String? documentReference;

  /// رابط / مسار ملف الحكم
  final String? documentUrl;

  /// حالة الحكم: draft | issued | appealed | final
  final String status;

  /// اسم القاضي مصدر الحكم
  final String? judgeName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  JudgmentModel({
    this.id,
    required this.lawsuitId,
    this.lawsuitNumber,
    this.courtLevel = 'first_instance',
    required this.judgmentDate,
    this.hijriDate,
    this.judgmentType = 'other',
    required this.summary,
    this.fullText,
    this.documentReference,
    this.documentUrl,
    this.status = 'issued',
    this.judgeName,
    this.createdAt,
    this.updatedAt,
  });

  factory JudgmentModel.fromJson(Map<String, dynamic> json) {
    return JudgmentModel(
      id: json['id'],
      lawsuitId: json['lawsuit'] is int
          ? json['lawsuit'] as int
          : (json['lawsuit'] is Map
                  ? (json['lawsuit'] as Map)['id']
                  : null) ??
              json['lawsuit_id'] ??
              0,
      lawsuitNumber: json['lawsuit'] is Map
          ? (json['lawsuit'] as Map)['case_number'] as String?
          : null,
      courtLevel: json['court_level'] ?? 'first_instance',
      judgmentDate: json['judgment_date'] != null
          ? DateTime.parse(json['judgment_date'])
          : (json['date'] != null
              ? DateTime.parse(json['date'])
              : DateTime.now()),
      hijriDate: json['hijri_date'],
      judgmentType: json['judgment_type'] ?? 'other',
      summary: json['summary'] ?? json['text'] ?? '',
      fullText: json['full_text'],
      documentReference: json['document_reference'],
      documentUrl: json['document_url'] ?? json['file_url'],
      status: json['status'] ?? 'issued',
      judgeName: json['judge_name'],
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
      'lawsuit': lawsuitId,
      'court_level': courtLevel,
      'judgment_date': judgmentDate.toIso8601String().split('T')[0],
      if (hijriDate != null) 'hijri_date': hijriDate,
      'judgment_type': judgmentType,
      'summary': summary,
      if (fullText != null) 'full_text': fullText,
      if (documentReference != null) 'document_reference': documentReference,
      'status': status,
      if (judgeName != null) 'judge_name': judgeName,
    };
  }

  // ── Display helpers ────────────────────────────────────────────────────────

  String get courtLevelDisplay {
    switch (courtLevel) {
      case 'first_instance':
        return 'ابتدائي';
      case 'appeal':
        return 'استئناف';
      case 'supreme':
        return 'عليا / تمييز';
      default:
        return courtLevel;
    }
  }

  String get judgmentTypeDisplay {
    switch (judgmentType) {
      case 'conviction':
        return 'إدانة';
      case 'acquittal':
        return 'تبرئة';
      case 'civil_for':
        return 'قضي للمدعي';
      case 'civil_against':
        return 'قضي على المدعى عليه';
      case 'dismissed':
        return 'رُفضت الدعوى';
      case 'partial':
        return 'حكم جزئي';
      case 'other':
        return 'أخرى';
      default:
        return judgmentType;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'issued':
        return 'صادر';
      case 'appealed':
        return 'مطعون فيه';
      case 'final':
        return 'بات / نهائي';
      default:
        return status;
    }
  }

  bool get isFinal => status == 'final';
}
