import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/lawsuit_model.dart';
import '../models/hearing_model.dart';
import '../models/judgment_model.dart';
import '../models/case_timeline_model.dart';

/// Lawsuit Provider for managing lawsuits state - with archive support
///
/// Filters supported:
///   search           → full-text search (case_number, subject, party name…)
///   caseType         → case_type
///   caseStatus       → case_status
///   archiveStatus    → archive_status (active | semi_active | archived)
///   governorate      → governorate name
///   courtLevel       → court_level (first_instance | appeal | supreme)
///   lawyer           → lawyer username / id
///   filingDateFrom   → filing_date__gte
///   filingDateTo     → filing_date__lte
///   ordering         → Django ordering param
class LawsuitProvider with ChangeNotifier {
  final ApiService _apiService;

  LawsuitProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<LawsuitModel> _lawsuits = [];
  LawsuitModel? _selectedLawsuit;
  bool _isLoading = false;
  String? _errorMessage;
  int _totalCount = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  // Archive stats
  Map<String, dynamic>? _archiveStats;

  // ── Active filters ──────────────────────────────────────────────────────────
  String? _searchQuery;
  String? _caseTypeFilter;
  String? _caseStatusFilter;
  String? _archiveStatusFilter;
  String? _governorateFilter;

  /// درجة المحكمة (first_instance | appeal | supreme)
  String? _courtLevelFilter;

  /// معرّف / اسم المحامي
  String? _lawyerFilter;

  String? _filingDateFrom;
  String? _filingDateTo;
  String? _ordering;

  // ── Case detail sub-data ────────────────────────────────────────────────────
  List<HearingModel> _hearings = [];
  List<JudgmentModel> _judgments = [];
  List<CaseTimelineEvent> _timeline = [];
  Map<String, dynamic>? _aiAnalysis;

  bool _isLoadingHearings = false;
  bool _isLoadingJudgments = false;
  bool _isLoadingTimeline = false;
  bool _isAnalyzing = false;
  String? _analysisError;

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<LawsuitModel> get lawsuits => _lawsuits;
  LawsuitModel? get selectedLawsuit => _selectedLawsuit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  Map<String, dynamic>? get archiveStats => _archiveStats;

  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get caseTypeFilter => _caseTypeFilter;
  String? get caseStatusFilter => _caseStatusFilter;
  String? get archiveStatusFilter => _archiveStatusFilter;
  String? get governorateFilter => _governorateFilter;
  String? get courtLevelFilter => _courtLevelFilter;
  String? get lawyerFilter => _lawyerFilter;
  String? get ordering => _ordering;

  // Sub-data getters
  List<HearingModel> get hearings => _hearings;
  List<JudgmentModel> get judgments => _judgments;
  List<CaseTimelineEvent> get timeline => _timeline;
  Map<String, dynamic>? get aiAnalysis => _aiAnalysis;
  bool get isLoadingHearings => _isLoadingHearings;
  bool get isLoadingJudgments => _isLoadingJudgments;
  bool get isLoadingTimeline => _isLoadingTimeline;
  bool get isAnalyzing => _isAnalyzing;
  String? get analysisError => _analysisError;

  bool get hasActiveFilters =>
      (_searchQuery != null && _searchQuery!.isNotEmpty) ||
      _caseTypeFilter != null ||
      _caseStatusFilter != null ||
      _archiveStatusFilter != null ||
      _governorateFilter != null ||
      _courtLevelFilter != null ||
      _lawyerFilter != null ||
      _filingDateFrom != null ||
      _filingDateTo != null;

  // ── Filter setters ──────────────────────────────────────────────────────────
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCaseTypeFilter(String? type) {
    _caseTypeFilter = type;
    notifyListeners();
  }

  void setCaseStatusFilter(String? status) {
    _caseStatusFilter = status;
    notifyListeners();
  }

  void setArchiveStatusFilter(String? status) {
    _archiveStatusFilter = status;
    notifyListeners();
  }

  void setGovernorateFilter(String? governorate) {
    _governorateFilter = governorate;
    notifyListeners();
  }

  /// Set the court level filter (first_instance | appeal | supreme)
  void setCourtLevelFilter(String? courtLevel) {
    _courtLevelFilter = courtLevel;
    notifyListeners();
  }

  /// Set the lawyer filter by username or numeric ID
  void setLawyerFilter(String? lawyer) {
    _lawyerFilter = lawyer;
    notifyListeners();
  }

  void setDateRange(String? from, String? to) {
    _filingDateFrom = from;
    _filingDateTo = to;
    notifyListeners();
  }

  void setOrdering(String? ordering) {
    _ordering = ordering;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _caseTypeFilter = null;
    _caseStatusFilter = null;
    _archiveStatusFilter = null;
    _governorateFilter = null;
    _courtLevelFilter = null;
    _lawyerFilter = null;
    _filingDateFrom = null;
    _filingDateTo = null;
    _ordering = null;
    notifyListeners();
  }

  // ── Query params builder ────────────────────────────────────────────────────
  Map<String, String> _buildQueryParams() {
    final params = <String, String>{
      'page': _currentPage.toString(),
    };

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      params['search'] = _searchQuery!;
    }
    if (_caseTypeFilter != null) {
      params['case_type'] = _caseTypeFilter!;
    }
    if (_caseStatusFilter != null) {
      params['case_status'] = _caseStatusFilter!;
    }
    if (_archiveStatusFilter != null) {
      params['archive_status'] = _archiveStatusFilter!;
    }
    if (_governorateFilter != null) {
      params['governorate'] = _governorateFilter!;
    }
    if (_courtLevelFilter != null) {
      params['court_level'] = _courtLevelFilter!;
    }
    if (_lawyerFilter != null) {
      params['lawyer'] = _lawyerFilter!;
    }
    if (_filingDateFrom != null) {
      params['filing_date_from'] = _filingDateFrom!;
    }
    if (_filingDateTo != null) {
      params['filing_date_to'] = _filingDateTo!;
    }
    if (_ordering != null) {
      params['ordering'] = _ordering!;
    }

    return params;
  }

  // ── Load lawsuits ───────────────────────────────────────────────────────────
  Future<void> loadLawsuits(
      {bool refresh = false, Map<String, String>? filters}) async {
    if (refresh) {
      _currentPage = 1;
      _lawsuits = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = _buildQueryParams();
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final response =
          await _apiService.getLawsuits(queryParams: queryParams);

      List<dynamic> resultsList;
      int? totalCount;
      bool hasMore;

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map && data.containsKey('results')) {
          resultsList = data['results'] as List? ?? [];
          totalCount = data['count'] as int? ?? 0;
          hasMore = data['next'] != null;
        } else if (data is List) {
          resultsList = data;
          totalCount = data.length;
          hasMore = false;
        } else {
          final pagination = response['pagination'] as Map?;
          if (pagination != null) {
            totalCount = pagination['count'] as int? ?? 0;
            hasMore = pagination['next'] != null;
          } else {
            totalCount = 0;
            hasMore = false;
          }
          resultsList = [];
        }
      } else if (response.containsKey('results')) {
        resultsList = (response['results'] as List?) ?? [];
        totalCount = response['count'] as int? ?? 0;
        hasMore = response['next'] != null;
      } else {
        resultsList = [];
        totalCount = 0;
        hasMore = false;
      }

      final results =
          resultsList.map((json) => LawsuitModel.fromJson(json)).toList();

      if (refresh) {
        _lawsuits = results;
      } else {
        _lawsuits.addAll(results);
      }

      _totalCount = totalCount ?? 0;
      _hasMore = hasMore;
      _currentPage++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Archive stats ───────────────────────────────────────────────────────────
  Future<void> loadArchiveStats() async {
    try {
      _archiveStats = await _apiService.getArchiveStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading archive stats: $e');
    }
  }

  // ── Single lawsuit ──────────────────────────────────────────────────────────
  Future<void> loadLawsuit(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedLawsuit = await _apiService.getLawsuit(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────
  Future<LawsuitModel?> createLawsuit(LawsuitModel lawsuit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newLawsuit = await _apiService.createLawsuit(lawsuit);
      _lawsuits.insert(0, newLawsuit);
      _selectedLawsuit = newLawsuit;
      _isLoading = false;
      notifyListeners();
      return newLawsuit;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateLawsuit(int id, LawsuitModel lawsuit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedLawsuit = await _apiService.updateLawsuit(id, lawsuit);
      final index = _lawsuits.indexWhere((l) => l.id == id);
      if (index != -1) {
        _lawsuits[index] = updatedLawsuit;
      }
      if (_selectedLawsuit?.id == id) {
        _selectedLawsuit = updatedLawsuit;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLawsuit(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteLawsuit(id);
      _lawsuits.removeWhere((l) => l.id == id);
      if (_selectedLawsuit?.id == id) {
        _selectedLawsuit = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Archive operations ──────────────────────────────────────────────────────
  Future<bool> archiveLawsuit(int id, {String? reason}) async {
    try {
      await _apiService.archiveLawsuit(id, reason: reason);
      await loadLawsuits(refresh: true);
      await loadArchiveStats();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unarchiveLawsuit(int id) async {
    try {
      await _apiService.unarchiveLawsuit(id);
      await loadLawsuits(refresh: true);
      await loadArchiveStats();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Hearings (case detail) ──────────────────────────────────────────────────
  /// Load hearings for a specific lawsuit
  Future<void> loadHearings(int lawsuitId) async {
    _isLoadingHearings = true;
    notifyListeners();

    try {
      final response = await _apiService.getHearings(lawsuitId: lawsuitId);
      final list = _extractList(response);
      _hearings = list.map((j) => HearingModel.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error loading hearings: $e');
      _hearings = [];
    } finally {
      _isLoadingHearings = false;
      notifyListeners();
    }
  }

  /// Create a hearing and refresh the list
  Future<bool> createHearing(Map<String, dynamic> data) async {
    try {
      await _apiService.createHearing(data);
      final lawsuitId = data['lawsuit'] as int?;
      if (lawsuitId != null) await loadHearings(lawsuitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update a hearing and refresh the list
  Future<bool> updateHearing(
      int id, Map<String, dynamic> data, int lawsuitId) async {
    try {
      await _apiService.updateHearing(id, data);
      await loadHearings(lawsuitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a hearing and refresh the list
  Future<bool> deleteHearing(int id, int lawsuitId) async {
    try {
      await _apiService.deleteHearing(id);
      await loadHearings(lawsuitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Judgments (case detail) ─────────────────────────────────────────────────
  /// Load judgments for a specific lawsuit
  Future<void> loadJudgments(int lawsuitId) async {
    _isLoadingJudgments = true;
    notifyListeners();

    try {
      final response = await _apiService.getJudgments(lawsuitId: lawsuitId);
      final list = _extractList(response);
      _judgments = list.map((j) => JudgmentModel.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error loading judgments: $e');
      _judgments = [];
    } finally {
      _isLoadingJudgments = false;
      notifyListeners();
    }
  }

  /// Create a judgment and refresh the list
  Future<bool> createJudgment(Map<String, dynamic> data) async {
    try {
      await _apiService.createJudgment(data);
      final lawsuitId = data['lawsuit'] as int?;
      if (lawsuitId != null) await loadJudgments(lawsuitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update a judgment and refresh the list
  Future<bool> updateJudgment(
      int id, Map<String, dynamic> data, int lawsuitId) async {
    try {
      await _apiService.updateJudgment(id, data);
      await loadJudgments(lawsuitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a judgment and refresh the list
  Future<bool> deleteJudgment(int id, int lawsuitId) async {
    try {
      await _apiService.deleteJudgment(id);
      await loadJudgments(lawsuitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Case Timeline (Step 8) ──────────────────────────────────────────────────
  /// Fetch the chronological timeline for a case from the backend.
  Future<void> loadCaseTimeline(int lawsuitId) async {
    _isLoadingTimeline = true;
    notifyListeners();

    try {
      final response = await _apiService.getCaseTimeline(lawsuitId);
      final list = _extractList(response);
      _timeline = list.map((e) => CaseTimelineEvent.fromJson(e)).toList();
      // Sort ascending by date
      _timeline.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    } catch (e) {
      debugPrint('Error loading case timeline: $e');
      _timeline = [];
    } finally {
      _isLoadingTimeline = false;
      notifyListeners();
    }
  }

  // ── AI Case Analysis (Step 7) ───────────────────────────────────────────────
  /// Trigger AI analysis for a case and store results in [aiAnalysis].
  ///
  /// After success the [selectedLawsuit] is refreshed so the updated
  /// ai_summary / related_laws fields are reflected immediately.
  Future<bool> analyzeCaseWithAI(int lawsuitId) async {
    _isAnalyzing = true;
    _analysisError = null;
    notifyListeners();

    try {
      _aiAnalysis = await _apiService.analyzeCaseWithAI(lawsuitId);
      // Refresh lawsuit to get the persisted AI fields
      await loadLawsuit(lawsuitId);
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _analysisError = e.toString();
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  void clearSelectedLawsuit() {
    _selectedLawsuit = null;
    notifyListeners();
  }

  // ── Internal helpers ────────────────────────────────────────────────────────

  /// Extract a flat list from various API response shapes.
  List<dynamic> _extractList(Map<String, dynamic> response) {
    if (response.containsKey('results')) {
      return (response['results'] as List?) ?? [];
    }
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is List) return data;
      if (data is Map && data.containsKey('results')) {
        return (data['results'] as List?) ?? [];
      }
    }
    return [];
  }
}
