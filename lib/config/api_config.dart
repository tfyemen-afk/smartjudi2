/// API Configuration
///
/// All endpoint constants are gathered here so the rest of the app
/// never hard-codes paths. When the Django backend evolves, only this
/// file needs to change.
class ApiConfig {
  // ── Base URL ────────────────────────────────────────────────────────────────
  // Production URL (Render)
  static const String baseUrl = 'https://smartjudi-nls1.onrender.com';

  // Development URLs (uncomment to use):
  // static const String baseUrl = 'http://192.168.0.147:8000'; // Local Network
  // static const String baseUrl = 'http://10.0.2.2:8000';     // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:8000';    // iOS Simulator

  // ── Auth endpoints ──────────────────────────────────────────────────────────
  static const String loginEndpoint = '/api/token/';
  static const String refreshTokenEndpoint = '/api/token/refresh/';
  static const String profilesEndpoint = '/api/profiles/';

  // ── Core Case Archive endpoints ─────────────────────────────────────────────
  static const String lawsuitsEndpoint = '/api/lawsuits/';
  static const String plaintiffsEndpoint = '/api/plaintiffs/';
  static const String defendantsEndpoint = '/api/defendants/';
  static const String attachmentsEndpoint = '/api/attachments/';
  static const String responsesEndpoint = '/api/responses/';
  static const String appealsEndpoint = '/api/appeals/';
  static const String hearingsEndpoint = '/api/hearings/';
  static const String judgmentsEndpoint = '/api/judgments/';
  static const String auditLogsEndpoint = '/api/audit-logs/';

  // ── Case Timeline (Step 8) ──────────────────────────────────────────────────
  /// GET /api/lawsuits/{id}/timeline/
  /// Returns a unified chronological list of all case events.
  static String caseTimelineEndpoint(int lawsuitId) =>
      '/api/lawsuits/$lawsuitId/timeline/';

  // ── AI Case Analysis (Step 7) ───────────────────────────────────────────────
  /// POST /api/lawsuits/{id}/analyze/
  /// Triggers RAG-based AI analysis for a specific case.
  static String caseAnalyzeEndpoint(int lawsuitId) =>
      '/api/lawsuits/$lawsuitId/analyze/';

  // ── Courts endpoints ────────────────────────────────────────────────────────
  static const String governoratesEndpoint = '/api/governorates/';
  static const String districtsEndpoint = '/api/districts/';
  static const String courtTypesEndpoint = '/api/court-types/';
  static const String courtSpecializationsEndpoint =
      '/api/court-specializations/';
  static const String courtsEndpoint = '/api/courts/';

  // ── Laws endpoints ──────────────────────────────────────────────────────────
  static const String legalCategoriesEndpoint = '/api/legal-categories/';
  static const String lawsEndpoint = '/api/laws/';
  static const String lawChaptersEndpoint = '/api/law-chapters/';
  static const String lawSectionsEndpoint = '/api/law-sections/';
  static const String lawArticlesEndpoint = '/api/law-articles/';
  static const String caseLegalReferencesEndpoint =
      '/api/case-legal-references/';

  // ── Logs endpoints ──────────────────────────────────────────────────────────
  static const String userSessionsEndpoint = '/api/user-sessions/';
  static const String searchLogsEndpoint = '/api/search-logs/';
  static const String aiChatLogsEndpoint = '/api/ai-chat-logs/';

  // ── Payments endpoints ──────────────────────────────────────────────────────
  static const String paymentOrdersEndpoint = '/api/payment-orders/';

  // ── Legal templates endpoints ───────────────────────────────────────────────
  static const String legalTemplatesEndpoint = '/api/legal-templates/';
  static const String financialClaimsEndpoint = '/api/financial-claims/';

  // ── AI Assistant endpoints ──────────────────────────────────────────────────
  static const String aiChatEndpoint = '/api/ai/chat/';
  static const String aiDocumentsAddEndpoint = '/api/ai/documents/add/';
  static const String aiDocumentsDeleteEndpoint = '/api/ai/documents/delete/';

  // ── Connection settings ─────────────────────────────────────────────────────
  static const Duration timeout = Duration(seconds: 60);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
