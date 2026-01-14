import 'package:flutter/material.dart';

/// Notary Accounting System Screen - نظام محاسبي للأمين الشرعي
class NotaryAccountingScreen extends StatelessWidget {
  const NotaryAccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام محاسبي'),
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
                      Icon(Icons.account_balance, color: Colors.teal, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'نظام محاسبي متكامل',
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
                    'نظام محاسبي للموردين وأصحاب العقار والمشترين',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.people,
            title: 'إدارة الحسابات',
            description: 'نظام محاسبي للموردين وأصحاب العقار والمشترين',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.assessment,
            title: 'التثمين',
            description: 'تثمين العقارات والممتلكات مع ربط الحسابات',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.link,
            title: 'ربط مع الأرشيف',
            description: 'ربط الحسابات بالأرشيف والمساعد الذكي',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.currency_exchange,
            title: 'أسعار الصرف',
            description: 'تحديثات أسعار الصرف والذهب والأسعار السابقة',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.trending_up,
            title: 'متابعة الأسعار',
            description: 'متابعة وتحديث أسعار الصرف والذهب',
            color: Colors.red,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.history,
            title: 'السجلات السابقة',
            description: 'الاحتفاظ بسجلات الأسعار السابقة للمراجعة',
            color: Colors.teal,
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
