import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

/// Legal Library Screen - المكتبة القانونية
class LegalLibraryScreen extends StatefulWidget {
  const LegalLibraryScreen({super.key});

  @override
  State<LegalLibraryScreen> createState() => _LegalLibraryScreenState();
}

class _LegalLibraryScreenState extends State<LegalLibraryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _laws = [];
  String _searchQuery = '';

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
      developer.log('Error loading laws: $e', name: 'LegalLibraryScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل القوانين: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة القانونية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _LawSearchDelegate(_laws),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laws.isEmpty
              ? const Center(child: Text('لا توجد قوانين متاحة'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _laws.length,
                  itemBuilder: (context, index) {
                    final law = _laws[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.book, size: 40),
                        title: Text(law['name'] ?? ''),
                        subtitle: Text('${law['category']} - ${law['year']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // TODO: Navigate to law details
                          Navigator.pushNamed(context, '/law-details', arguments: law);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class _LawSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> _laws;

  _LawSearchDelegate(this._laws);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _laws.where((law) =>
        law['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final law = results[index];
        return ListTile(
          title: Text(law['name'] ?? ''),
          subtitle: Text('${law['category']} - ${law['year']}'),
          onTap: () {
            close(context, law['name'] ?? '');
            Navigator.pushNamed(context, '/law-details', arguments: law);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

