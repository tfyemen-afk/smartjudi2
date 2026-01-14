import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

/// Laws Screen - قوانين
class LawsScreen extends StatefulWidget {
  const LawsScreen({super.key});

  @override
  State<LawsScreen> createState() => _LawsScreenState();
}

class _LawsScreenState extends State<LawsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _laws = [];
  String _selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadLaws();
  }

  Future<void> _loadLaws() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getLaws();
      if (response['results'] != null) {
        setState(() {
          _laws = List<Map<String, dynamic>>.from(response['results']);
        });
      } else {
        setState(() => _laws = []);
      }
    } catch (e) {
      developer.log('Error loading laws: $e', name: 'LawsScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل القوانين: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> get _categories {
    final categories = _laws.map((law) => law['category'] as String).toSet().toList();
    return ['الكل', ...categories];
  }

  List<Map<String, dynamic>> get _filteredLaws {
    if (_selectedCategory == 'الكل') return _laws;
    return _laws.where((law) => law['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القوانين'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLaws.isEmpty
                    ? const Center(child: Text('لا توجد قوانين'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredLaws.length,
                        itemBuilder: (context, index) {
                          final law = _filteredLaws[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.book, size: 40),
                              title: Text(law['name'] ?? ''),
                              subtitle: Text(
                                '${law['category']} - ${law['year']} - ${law['chapters']} فصول',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/law-details',
                                  arguments: law,
                                );
                              },
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

