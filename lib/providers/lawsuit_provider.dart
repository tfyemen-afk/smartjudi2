import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/lawsuit_model.dart';

/// Lawsuit Provider for managing lawsuits state
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

  List<LawsuitModel> get lawsuits => _lawsuits;
  LawsuitModel? get selectedLawsuit => _selectedLawsuit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;

  // Load lawsuits
  Future<void> loadLawsuits({bool refresh = false, Map<String, String>? filters}) async {
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
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        ...?filters,
      };

      final response = await _apiService.getLawsuits(queryParams: queryParams);
      
      // Handle different response formats from Django
      List<dynamic> resultsList;
      int? totalCount;
      bool hasMore;
      
      // Check if response has 'data' wrapper (from StandardResultsSetPagination)
      if (response.containsKey('data')) {
        final data = response['data'];
        // If data is a Map with 'results', it's the paginated format
        if (data is Map && data.containsKey('results')) {
          resultsList = data['results'] as List? ?? [];
          totalCount = data['count'] as int? ?? 0;
          hasMore = data['next'] != null;
        } 
        // If data is a List, it's a direct list
        else if (data is List) {
          resultsList = data;
          totalCount = data.length;
          hasMore = false;
        } 
        // Otherwise, try to get from pagination object
        else {
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
      } 
      // Standard Django REST Framework pagination format
      else if (response.containsKey('results')) {
        resultsList = (response['results'] as List?) ?? [];
        totalCount = response['count'] as int? ?? 0;
        hasMore = response['next'] != null;
      } 
      // Fallback: empty list
      else {
        resultsList = [];
        totalCount = 0;
        hasMore = false;
      }
      
      final results = resultsList
          .map((json) => LawsuitModel.fromJson(json))
          .toList();

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

  // Load single lawsuit
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

  // Create lawsuit
  Future<bool> createLawsuit(LawsuitModel lawsuit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newLawsuit = await _apiService.createLawsuit(lawsuit);
      _lawsuits.insert(0, newLawsuit);
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

  // Update lawsuit
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

  // Delete lawsuit
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

  // Clear selected lawsuit
  void clearSelectedLawsuit() {
    _selectedLawsuit = null;
    notifyListeners();
  }
}

