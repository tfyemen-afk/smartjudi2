import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import 'dart:developer' as developer;

/// Inquiries Screen - الاستعلامات
/// Enhanced with detailed lawsuit information display
class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  final TextEditingController _caseNumberController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _lawsuitInfo;
  Map<String, dynamic>? _lawsuitDetails;

  @override
  void dispose() {
    _caseNumberController.dispose();
    super.dispose();
  }

  Future<void> _searchLawsuit() async {
    final caseNumber = _caseNumberController.text.trim();
    if (caseNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الدعوى')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _lawsuitInfo = null;
      _lawsuitDetails = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Search for lawsuit
      final response = await authProvider.apiService.getLawsuits(
        queryParams: {'case_number': caseNumber},
      );
      
      if (response['results'] != null && (response['results'] as List).isNotEmpty) {
        final lawsuit = (response['results'] as List).first;
        setState(() {
          _lawsuitInfo = {
            'case_number': lawsuit['case_number'] ?? caseNumber,
            'status': lawsuit['case_status_display'] ?? lawsuit['status_display'] ?? lawsuit['status'] ?? 'غير معروف',
            'case_status': lawsuit['case_status'] ?? lawsuit['status'] ?? 'غير معروف',
            'court': lawsuit['court_detail']?['name'] ?? lawsuit['court'] ?? 'غير معروف',
            'date': lawsuit['filing_date'] ?? lawsuit['created_at'] ?? '',
            'case_type': lawsuit['case_type_display'] ?? lawsuit['case_type'] ?? 'غير معروف',
            'subject': lawsuit['subject'] ?? 'غير محدد',
            'governorate': lawsuit['governorate'] ?? 'غير محدد',
          };
          _lawsuitDetails = lawsuit;
        });
      } else {
        setState(() {
          _lawsuitInfo = null;
          _lawsuitDetails = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على دعوى بهذا الرقم')),
          );
        }
      }
    } catch (e) {
      developer.log('Error searching lawsuit: $e', name: 'InquiriesScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في البحث: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستعلامات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: Colors.blue, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'البحث عن دعوى',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _caseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الدعوى',
                        hintText: 'أدخل رقم الدعوى',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _searchLawsuit(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _searchLawsuit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('بحث'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_lawsuitInfo != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gavel, color: Colors.blue, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'معلومات الدعوى',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('رقم الدعوى', _lawsuitInfo!['case_number']),
                      _buildInfoRow('نوع القضية', _lawsuitInfo!['case_type']),
                      _buildInfoRow('موضوع الدعوى', _lawsuitInfo!['subject']),
                      _buildInfoRow('الحالة', _lawsuitInfo!['status']),
                      _buildInfoRow('المحكمة', _lawsuitInfo!['court']),
                      _buildInfoRow('المحافظة', _lawsuitInfo!['governorate']),
                      _buildInfoRow('التاريخ', _lawsuitInfo!['date']),
                      if (_lawsuitDetails != null && _lawsuitDetails!['facts'] != null) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'وقائع الدعوى',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lawsuitDetails!['facts'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
