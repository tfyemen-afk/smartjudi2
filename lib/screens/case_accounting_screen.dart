import 'package:flutter/material.dart';

/// Case-Specific Accounting System Screen - نظام محاسبة خاص بالقضايا
class CaseAccountingScreen extends StatelessWidget {
  const CaseAccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام محاسبة خاص بالقضايا'),
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
                      Icon(Icons.account_balance_wallet, color: Colors.green, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'نظام محاسبة متكامل',
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
                    'نظام محاسبة خاص بكل قضية يدير حساباتها بشكل منفصل ومتكامل',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.account_balance,
            title: 'إدارة حسابات القضايا',
            description: 'نظام محاسبة منفصل لكل قضية يدير جميع حساباتها',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.handshake,
            title: 'اتفاقيات الأتعاب',
            description: 'معالجة وإدارة اتفاقيات الأتعاب المتعلقة بالمحاماة',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.link,
            title: 'ربط مع الأرشيف والجلسات',
            description: 'نظام مرتبط بأرشيف القضايا وجلساتها',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.receipt,
            title: 'الفواتير والإيصالات',
            description: 'إنشاء وإدارة الفواتير والإيصالات للقضايا',
            color: Colors.purple,
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
