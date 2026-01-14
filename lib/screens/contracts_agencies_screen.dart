import 'package:flutter/material.dart';

/// Contracts and Agencies Screen - العقود والوكالات
class ContractsAgenciesScreen extends StatelessWidget {
  const ContractsAgenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العقود والوكالات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.indigo, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'المحررات الذكية والآلية',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'العقود والوكالات وجميع المحررات الذكية والآلية',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.description,
            title: 'العقود والوكالات',
            description: 'إنشاء وإدارة العقود والوكالات بسهولة',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.edit,
            title: 'إدخال بسهولة',
            description: 'إدخال البيانات بسهولة مع تدقيق إملائي وصيغ جاهزة',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.spellcheck,
            title: 'تدقيق إملائي',
            description: 'تدقيق إملائي تلقائي للمحررات',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.article,
            title: 'صيغ جاهزة',
            description: 'صيغ جاهزة لجميع أنواع المحررات',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.archive,
            title: 'أرشيف المحررات',
            description: 'أرشيف المحررات بآلية الوزارة مع تخزين محلي',
            color: Colors.red,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.backup,
            title: 'نسخة احتياطية',
            description: 'نسخة احتياطية للبطائق والمستندات',
            color: Colors.teal,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.image,
            title: 'تخزين الصور',
            description: 'تخزين الصور وجميع أنواع المستندات المهمة',
            color: Colors.indigo,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.receipt,
            title: 'سندات القبض والتوريد',
            description: 'إدارة سندات القبض والتوريد',
            color: Colors.brown,
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
