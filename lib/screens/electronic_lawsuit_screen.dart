import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'lawsuit_detail_screen.dart';

/// Electronic Lawsuit Screen - رفع دعوى الكترونية
class ElectronicLawsuitScreen extends StatelessWidget {
  const ElectronicLawsuitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('رفع دعوى إلكترونية')),
        body: const Center(
          child: Text('يرجى تسجيل الدخول أولاً'),
        ),
      );
    }

    // Allow all authenticated users to create lawsuits
    // No role restriction needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع دعوى إلكترونية'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, size: 40, color: Colors.blue),
                    const SizedBox(height: 8),
                    const Text(
                      'رفع دعوى إلكترونية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يمكنك رفع دعوى جديدة إلكترونياً من خلال النموذج التالي',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LawsuitDetailScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('رفع دعوى جديدة'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'متطلبات رفع الدعوى:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRequirement('رقم الدعوى'),
            _buildRequirement('نوع الدعوى'),
            _buildRequirement('المحكمة'),
            _buildRequirement('موضوع الدعوى'),
            _buildRequirement('المرفقات (إن وجدت)'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(requirement),
        ],
      ),
    );
  }
}

