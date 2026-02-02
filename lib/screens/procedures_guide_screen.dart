
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';

import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ProceduresGuideScreen extends StatefulWidget {
  const ProceduresGuideScreen({Key? key}) : super(key: key);

  @override
  State<ProceduresGuideScreen> createState() => _ProceduresGuideScreenState();
}

class _ProceduresGuideScreenState extends State<ProceduresGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _procedures = [];
  List<dynamic> _sources = [];
  
  String? _selectedSource;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = false;
  Timer? _debounce;
  
  @override
  void initState() {
    super.initState();
    _loadSources();
    _searchProcedures(); // Initial load
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  Future<void> _loadSources() async {
    try {
      final apiService = Provider.of<AuthProvider>(context, listen: false).apiService;
      if (apiService != null) {
        final result = await apiService.getLegalProceduresSources();
        if (mounted) {
          setState(() {
            _sources = result['sources'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading sources: $e');
    }
  }

  Future<void> _searchProcedures({bool loadMore = false}) async {
    if (!loadMore) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
          _procedures = [];
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingMore = true;
        });
      }
    }

    try {
      final apiService = Provider.of<AuthProvider>(context, listen: false).apiService;
      if (apiService != null) {
        final result = await apiService.getLegalProcedures(
          page: _currentPage,
          search: _searchController.text,
          source: _selectedSource,
        );
        
        if (mounted) {
          final results = result['results'] as List?;
          final count = result['count'] as int? ?? 0;
          
          setState(() {
            if (loadMore) {
              _procedures.addAll(results ?? []);
            } else {
              _procedures = results ?? [];
            }
            
            _totalCount = count;
            _hasMore = _procedures.length < _totalCount;
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error searching procedures: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء البحث: $e')),
        );
      }
    }
  }
  
  Future<void> _loadMore() async {
    _currentPage++;
    await _searchProcedures(loadMore: true);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchProcedures();
    });
  }

  void _showProcedureDetails(Map<String, dynamic> procedure) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProcedureDetailsSheet(procedure: procedure),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('دليل الإجراءات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'ابحث في الإجراءات...',
                      hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchProcedures();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_sources.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Source Filter
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sources.length + 1,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedSource == null;
                          return FilterChip(
                            label: const Text('الكل', style: TextStyle(fontFamily: 'Cairo')),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedSource = null;
                              });
                              _searchProcedures();
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: const Color(0xFF1A237E).withOpacity(0.1),
                            checkmarkColor: const Color(0xFF1A237E),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFF1A237E) : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontFamily: 'Cairo',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: isSelected 
                                ? const BorderSide(color: Color(0xFF1A237E), width: 1)
                                : BorderSide.none,
                            ),
                          );
                        }
                        
                        final source = _sources[index - 1];
                        final title = source['source_title'];
                        final isSelected = _selectedSource == title;
                        
                        return FilterChip(
                          label: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedSource = selected ? title : null;
                            });
                            _searchProcedures();
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: const Color(0xFF1A237E).withOpacity(0.1),
                          checkmarkColor: const Color(0xFF1A237E),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF1A237E) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'Cairo',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: isSelected 
                              ? const BorderSide(color: Color(0xFF1A237E), width: 1)
                              : BorderSide.none,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _procedures.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'ابحث في دليل الإجراءات',
                              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _procedures.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _procedures.length) {
                             return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                          }
                          
                          final procedure = _procedures[index];
                          final bodyText = procedure['body_highlighted'] ?? procedure['body'] ?? '';
                          // Handle titles that might be too long
                          final title = procedure['title'] ?? 'بدون عنوان';
                          final source = procedure['source_title'] ?? '';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () => _showProcedureDetails(procedure),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (source.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8EAF6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          source,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            color: Color(0xFF1A237E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (bodyText.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Html(
                                        data: bodyText,
                                        style: {
                                          "body": Style(
                                            fontFamily: 'Cairo',
                                            fontSize: FontSize(13),
                                            color: Colors.grey[700],
                                            maxLines: 3,
                                            textOverflow: TextOverflow.ellipsis,
                                            margin: Margins.zero,
                                          ),
                                          "mark": Style(
                                            backgroundColor: const Color(0xFFFFEB3B),
                                            color: Colors.black,
                                          ),
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProcedureDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> procedure;

  const _ProcedureDetailsSheet({Key? key, required this.procedure}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      procedure['title'] ?? 'تفاصيل الإجراء',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (procedure['source_title'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          procedure['source_title'],
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Html(
                    data: procedure['body'] ?? '',
                    style: {
                      "body": Style(
                          fontFamily: 'Cairo',
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.8),
                          textAlign: TextAlign.justify,
                          color: Colors.black87,
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
