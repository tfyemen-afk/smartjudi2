import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

/// Daily Sessions Screen - الجلسات اليومية
class DailySessionsScreen extends StatefulWidget {
  const DailySessionsScreen({super.key});

  @override
  State<DailySessionsScreen> createState() => _DailySessionsScreenState();
}

class _DailySessionsScreenState extends State<DailySessionsScreen> {
  late ApiService _apiService;
  bool _isLoading = false;
  List<Map<String, dynamic>> _sessions = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService = Provider.of<AuthProvider>(context, listen: false).apiService;
      _loadSessions();
    });
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getDailyHearings(_selectedDate);
      if (response['results'] != null) {
        setState(() {
          _sessions = List<Map<String, dynamic>>.from(response['results']).map((hearing) {
            return {
              'id': hearing['id'],
              'case_number': hearing['lawsuit']?['case_number'] ?? 'غير معروف',
              'court': hearing['lawsuit']?['court_detail']?['name'] ?? hearing['lawsuit']?['court'] ?? 'غير معروف',
              'time': hearing['hearing_time'] ?? '',
              'room': hearing['notes'] ?? '', // You might want to add a room field
              'judge': hearing['judge']?['username'] ?? hearing['judge_name'] ?? 'غير معروف',
            };
          }).toList();
        });
      } else {
        setState(() => _sessions = []);
      }
    } catch (e) {
      developer.log('Error loading sessions: $e', name: 'DailySessionsScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الجلسات: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجلسات اليومية'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _selectDate,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'اختر التاريخ:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                    ? const Center(child: Text('لا توجد جلسات لهذا التاريخ'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.event, size: 40),
                              title: Text('رقم الدعوى: ${session['case_number']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('المحكمة: ${session['court']}'),
                                  Text('الوقت: ${session['time']}'),
                                  Text('القاعة: ${session['room']}'),
                                  Text('القاضي: ${session['judge']}'),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // TODO: Navigate to session details
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

