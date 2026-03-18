/// Hearing Model - جلسة قضائية
///
/// Represents a single court hearing session linked to a lawsuit.
/// Maps to the Django `Hearing` model at endpoint `/api/hearings/`.
///
/// Hearing types (hearing_type):
///   pleading   → مرافعة
///   witness    → سماع شهود
///   expert     → تقرير خبير
///   initial    → جلسة أولى
///   judgment   → جلسة حكم
///   other      → أخرى
///
/// Decisions (decision):
///   adjourned  → مؤجلة
///   judgment   → صدر حكم
///   postponed  → مرجأة
///   continued  → تواصل
///   other      → أخرى
class HearingModel {
  final int? id;
  final int lawsuitId;
  final String? lawsuitNumber;

  /// تاريخ الجلسة (ميلادي)
  final DateTime hearingDate;

  /// تاريخ الجلسة (هجري) — للعرض فقط
  final String? hijriDate;

  /// نوع الجلسة
  final String hearingType;

  /// قرار الجلسة
  final String decision;

  /// ملاحظات القاضي / المحامي على الجلسة
  final String? notes;

  /// تاريخ الجلسة القادمة (ميلادي)
  final DateTime? nextHearingDate;

  /// تاريخ الجلسة القادمة (هجري)
  final String? nextHijriDate;

  /// اسم القاضي في هذه الجلسة (قد يختلف عن قاضي القضية)
  final String? judgeName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  HearingModel({
    this.id,
    required this.lawsuitId,
    this.lawsuitNumber,
    required this.hearingDate,
    this.hijriDate,
    this.hearingType = 'pleading',
    this.decision = 'adjourned',
    this.notes,
    this.nextHearingDate,
    this.nextHijriDate,
    this.judgeName,
    this.createdAt,
    this.updatedAt,
  });

  factory HearingModel.fromJson(Map<String, dynamic> json) {
    return HearingModel(
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
      hearingDate: json['hearing_date'] != null
          ? DateTime.parse(json['hearing_date'])
          : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
      hijriDate: json['hijri_date'],
      hearingType: json['hearing_type'] ?? json['type'] ?? 'pleading',
      decision: json['decision'] ?? 'adjourned',
      notes: json['notes'],
      nextHearingDate: json['next_hearing_date'] != null
          ? DateTime.parse(json['next_hearing_date'])
          : null,
      nextHijriDate: json['next_hijri_date'],
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
      'hearing_date': hearingDate.toIso8601String().split('T')[0],
      if (hijriDate != null) 'hijri_date': hijriDate,
      'hearing_type': hearingType,
      'decision': decision,
      if (notes != null) 'notes': notes,
      if (nextHearingDate != null)
        'next_hearing_date':
            nextHearingDate!.toIso8601String().split('T')[0],
      if (nextHijriDate != null) 'next_hijri_date': nextHijriDate,
      if (judgeName != null) 'judge_name': judgeName,
    };
  }

  // ── Display helpers ────────────────────────────────────────────────────────

  String get hearingTypeDisplay {
    switch (hearingType) {
      case 'pleading':
        return 'مرافعة';
      case 'witness':
        return 'سماع شهود';
      case 'expert':
        return 'تقرير خبير';
      case 'initial':
        return 'جلسة أولى';
      case 'judgment':
        return 'جلسة حكم';
      case 'other':
        return 'أخرى';
      default:
        return hearingType;
    }
  }

  String get decisionDisplay {
    switch (decision) {
      case 'adjourned':
        return 'مؤجلة';
      case 'judgment':
        return 'صدر حكم';
      case 'postponed':
        return 'مرجأة';
      case 'continued':
        return 'تواصل';
      case 'other':
        return 'أخرى';
      default:
        return decision;
    }
  }

  /// لون الشارة بناءً على القرار
  bool get isResolved => decision == 'judgment';
}
