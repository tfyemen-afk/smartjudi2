import 'package:flutter/material.dart';

/// Procedures Guide Screen - دليل الإجراءات للأمين الشرعي
class ProceduresGuideScreen extends StatelessWidget {
  const ProceduresGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الإجراءات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.book,
            title: 'دليل الإجراءات للأمناء',
            description: 'دليل شامل لجميع الإجراءات المتعلقة بعمل الأمناء الشرعيين',
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
            description: 'جميع القوانين اليمنية المحدثة، القرارات والتعميمات',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.people,
            title: 'دليل الأمناء',
            description: 'معرفة الأمناء ومناطق اختصاصهم والبحث عنهم والتواصل معهم',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.location_on,
            title: 'مناطق الاختصاص',
            description: 'معلومات شاملة عن مناطق اختصاص الأمناء الشرعيين',
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
