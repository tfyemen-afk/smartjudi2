import 'package:flutter/material.dart';

/// About Us Screen - من نحن
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('من نحن'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.gavel,
                size: 100,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'منصة SmartJudi القضائية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'منصة إلكترونية شاملة لإدارة النظام القضائي في اليمن. تهدف إلى تسهيل الإجراءات القضائية وزيادة الشفافية والكفاءة في النظام القضائي.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'رؤيتنا',
              'أن نكون المنصة الرائدة في المنطقة لتقديم الخدمات القضائية الإلكترونية.',
              Icons.visibility,
            ),
            _buildSection(
              'رسالتنا',
              'تسهيل الوصول إلى العدالة من خلال التكنولوجيا الحديثة.',
              Icons.message,
            ),
            _buildSection(
              'قيمنا',
              'الشفافية، العدالة، الكفاءة، الأمان، الابتكار.',
              Icons.star,
            ),
            const SizedBox(height: 24),
            const Text(
              'المميزات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeature('رفع الدعاوى إلكترونياً'),
            _buildFeature('متابعة حالة الدعاوى'),
            _buildFeature('المكتبة القانونية'),
            _buildFeature('المساعد الذكي'),
            _buildFeature('الجلسات اليومية'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(feature),
        ],
      ),
    );
  }
}

