/// Case Timeline Model - الجدول الزمني للقضية
///
/// Represents a single chronological event in a case's lifecycle.
/// The backend constructs this from multiple sources (filings, hearings,
/// documents, judgments, appeals) and returns it at:
///
///   GET /api/lawsuits/{id}/timeline/
///
/// Event types (event_type):
///   filing     → رفع الدعوى
///   hearing    → جلسة
///   document   → وثيقة مرفوعة
///   judgment   → حكم
///   appeal     → استئناف / طعن
///   payment    → أمر أداء
///   note       → ملاحظة
///   status_change → تغيير الحالة
///   ai_analysis   → تحليل ذكاء اصطناعي

class CaseTimelineEvent {
  /// المعرّف الفريد للحدث (قد يكون `hearing_12`, `judgment_5`, إلخ)
  final String eventId;

  /// نوع الحدث
  final String eventType;

  /// تاريخ الحدث (ميلادي)
  final DateTime eventDate;

  /// تاريخ الحدث (هجري) — للعرض
  final String? hijriDate;

  /// عنوان مختصر للحدث بالعربية
  final String title;

  /// تفاصيل إضافية (اختياري)
  final String? description;

  /// معرّف الكيان المرتبط بالحدث (hearing_id / judgment_id / …)
  final int? relatedId;

  /// رابط وثيقة مرفقة (إن وجد)
  final String? documentUrl;

  /// اسم المستخدم الذي أنشأ الحدث
  final String? createdBy;

  const CaseTimelineEvent({
    required this.eventId,
    required this.eventType,
    required this.eventDate,
    this.hijriDate,
    required this.title,
    this.description,
    this.relatedId,
    this.documentUrl,
    this.createdBy,
  });

  factory CaseTimelineEvent.fromJson(Map<String, dynamic> json) {
    return CaseTimelineEvent(
      eventId: json['event_id']?.toString() ??
          '${json['event_type']}_${json['id']}',
      eventType: json['event_type'] ?? 'note',
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'])
          : (json['date'] != null
              ? DateTime.parse(json['date'])
              : DateTime.now()),
      hijriDate: json['hijri_date'],
      title: json['title'] ?? json['summary'] ?? '',
      description: json['description'] ?? json['notes'],
      relatedId: json['related_id'] ?? json['id'],
      documentUrl: json['document_url'] ?? json['file_url'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'event_type': eventType,
        'event_date': eventDate.toIso8601String().split('T')[0],
        if (hijriDate != null) 'hijri_date': hijriDate,
        'title': title,
        if (description != null) 'description': description,
        if (relatedId != null) 'related_id': relatedId,
        if (documentUrl != null) 'document_url': documentUrl,
        if (createdBy != null) 'created_by': createdBy,
      };

  // ── Display helpers ────────────────────────────────────────────────────────

  String get eventTypeDisplay {
    switch (eventType) {
      case 'filing':
        return 'رفع الدعوى';
      case 'hearing':
        return 'جلسة';
      case 'document':
        return 'وثيقة';
      case 'judgment':
        return 'حكم';
      case 'appeal':
        return 'استئناف';
      case 'payment':
        return 'أمر أداء';
      case 'status_change':
        return 'تغيير الحالة';
      case 'ai_analysis':
        return 'تحليل ذكي';
      case 'note':
        return 'ملاحظة';
      default:
        return eventType;
    }
  }

  /// أيقونة الحدث (Material Icons codepoint)
  String get iconName {
    switch (eventType) {
      case 'filing':
        return 'gavel';
      case 'hearing':
        return 'event';
      case 'document':
        return 'description';
      case 'judgment':
        return 'balance';
      case 'appeal':
        return 'upload_file';
      case 'payment':
        return 'payments';
      case 'status_change':
        return 'swap_horiz';
      case 'ai_analysis':
        return 'psychology';
      default:
        return 'circle';
    }
  }
}
