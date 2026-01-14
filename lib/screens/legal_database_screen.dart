import 'package:flutter/material.dart';

/// Legal Database and Directory Screen - قاعدة البيانات القانونية والدليل
class LegalDatabaseScreen extends StatelessWidget {
  const LegalDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قاعدة البيانات القانونية والدليل'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.book,
            title: 'دليل الإجراءات',
            description: 'دليل شامل لجميع الإجراءات القانونية والقضائية',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.search,
            title: 'البحث الذكي',
            description: 'بحث ذكي متقدم مع إمكانية النسخ والتحميل',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.library_books,
            title: 'القوانين اليمنية المحدثة',
            description: 'جميع القوانين اليمنية المحدثة، القرارات والمنشورات',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.people,
            title: 'دليل المحامين',
            description: 'دليل شامل للمحامين مع إمكانية البحث والتواصل',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.balance,
            title: 'المحاكم والنيابات',
            description: 'معلومات شاملة عن المحاكم والنيابات العامة في الجمهورية اليمنية',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('قريباً: $title')),
          );
        },
      ),
    );
  }
}
