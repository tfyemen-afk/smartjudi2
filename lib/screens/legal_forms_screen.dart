import 'package:flutter/material.dart';

/// Ready-Made Legal Forms and Resources Screen - النماذج القانونية الجاهزة والموارد
class LegalFormsScreen extends StatelessWidget {
  const LegalFormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'نماذج المحاكم',
        'icon': Icons.gavel,
        'color': Colors.blue,
        'description': 'جميع نماذج المحاكم الرسمية',
      },
      {
        'title': 'الطلبات',
        'icon': Icons.description,
        'color': Colors.green,
        'description': 'نماذج الطلبات القانونية',
      },
      {
        'title': 'الردود',
        'icon': Icons.reply,
        'color': Colors.orange,
        'description': 'نماذج الردود على الدعاوى',
      },
      {
        'title': 'الاستئنافات',
        'icon': Icons.trending_up,
        'color': Colors.purple,
        'description': 'نماذج الاستئنافات والطعون',
      },
      {
        'title': 'المرافعات',
        'icon': Icons.mic,
        'color': Colors.red,
        'description': 'نماذج المرافعات الشفهية والكتابية',
      },
      {
        'title': 'الاتفاقيات',
        'icon': Icons.handshake,
        'color': Colors.teal,
        'description': 'نماذج الاتفاقيات والعقود',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('النماذج القانونية الجاهزة والموارد'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.description, color: Colors.orange, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'نماذج جاهزة لجميع أنواع النماذج القانونية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => _buildCategoryCard(
                context,
                title: category['title'] as String,
                icon: category['icon'] as IconData,
                color: category['color'] as Color,
                description: category['description'] as String,
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
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
