import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

/// Supreme Court Screen - المحكمة العليا
class SupremeCourtScreen extends StatefulWidget {
  const SupremeCourtScreen({super.key});

  @override
  State<SupremeCourtScreen> createState() => _SupremeCourtScreenState();
}

class _SupremeCourtScreenState extends State<SupremeCourtScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _courtInfo;

  @override
  void initState() {
    super.initState();
    _loadCourtInfo();
  }

  Future<void> _loadCourtInfo() async {
    setState(() => _isLoading = true);
    try {
      // Search for supreme court
      final response = await _apiService.getCourts(queryParams: {'search': 'عليا'});
      
      if (response['results'] != null && (response['results'] as List).isNotEmpty) {
        final court = (response['results'] as List).first;
        setState(() {
          _courtInfo = {
            'name': court['name'] ?? 'المحكمة العليا',
            'address': court['address'] ?? 'صنعاء، اليمن',
            'phone': '+967 1 234 5678', // You might want to add phone to Court model
            'email': 'supreme@smartjudi.ye', // You might want to add email to Court model
            'description': 'المحكمة العليا هي أعلى سلطة قضائية في الجمهورية اليمنية.',
            'judges': [], // You might want to add judges relationship to Court model
          };
        });
      } else {
        // Fallback to default info if not found
        setState(() {
          _courtInfo = {
            'name': 'المحكمة العليا',
            'address': 'صنعاء، اليمن',
            'phone': '+967 1 234 5678',
            'email': 'supreme@smartjudi.ye',
            'description': 'المحكمة العليا هي أعلى سلطة قضائية في الجمهورية اليمنية.',
            'judges': [],
          };
        });
      }
    } catch (e) {
      developer.log('Error loading court info: $e', name: 'SupremeCourtScreen');
      // Fallback to default info on error
      setState(() {
        _courtInfo = {
          'name': 'المحكمة العليا',
          'address': 'صنعاء، اليمن',
          'phone': '+967 1 234 5678',
          'email': 'supreme@smartjudi.ye',
          'description': 'المحكمة العليا هي أعلى سلطة قضائية في الجمهورية اليمنية.',
          'judges': [],
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحكمة العليا'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courtInfo == null
              ? const Center(child: Text('لا توجد معلومات'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.balance,
                                size: 60,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _courtInfo!['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'معلومات التواصل',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              _buildInfoRow(Icons.location_on, 'العنوان', _courtInfo!['address']),
                              _buildInfoRow(Icons.phone, 'الهاتف', _courtInfo!['phone']),
                              _buildInfoRow(Icons.email, 'البريد', _courtInfo!['email']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الوصف',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Text(_courtInfo!['description'] ?? ''),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'القضاة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              ...(_courtInfo!['judges'] as List).map((judge) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(judge['name'] ?? ''),
                                              Text(
                                                judge['position'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

