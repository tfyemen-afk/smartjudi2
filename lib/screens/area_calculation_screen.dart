import 'package:flutter/material.dart';

/// Area Calculation Screen - حساب المساحات
class AreaCalculationScreen extends StatelessWidget {
  const AreaCalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب المساحات'),
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
                      Icon(Icons.map, color: Colors.orange, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'حساب المساحات وإسقاط الأراضي',
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
                    'حساب المساحات عبر خرائط متقدمة وتقريبية',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.map,
            title: 'خرائط متقدمة',
            description: 'خرائط متقدمة وتقريبية لحساب المساحات وإسقاط الأراضي',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.square_foot,
            title: 'تخطيط المساحة',
            description: 'تخطيط المساحة وحفظ وأرشفة المساحات الخاصة بالعمل',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.home,
            title: 'بيع وشراء العقارات',
            description: 'إدارة عمليات بيع وشراء العقارات مع حساب المساحات',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.archive,
            title: 'أرشفة المساحات',
            description: 'حفظ وأرشفة جميع المساحات المحسوبة',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.location_on,
            title: 'تحديد المواقع',
            description: 'تحديد مواقع الأراضي والعقارات على الخرائط',
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
