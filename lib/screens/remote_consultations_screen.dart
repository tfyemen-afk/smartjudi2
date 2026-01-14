import 'package:flutter/material.dart';

/// Remote Legal Consultations Screen - الاستشارات القانونية عن بُعد
class RemoteConsultationsScreen extends StatelessWidget {
  const RemoteConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستشارات القانونية عن بُعد'),
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
                      Icon(Icons.video_call, color: Colors.red, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'استشارات قانونية مباشرة',
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
                    'احصل على استشارات قانونية مباشرة من محامين محترفين',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.person,
            title: 'محامون محترفون',
            description: 'استشارات قانونية مباشرة مع محامين مدفوعين وذوي خبرة',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.chat,
            title: 'دردشة مع المحامين',
            description: 'ميزة الدردشة للتواصل المباشر مع المحامين',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.payment,
            title: 'دفع إلكتروني',
            description: 'دفع إلكتروني آمن للاستشارات عن بُعد',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.video_library,
            title: 'استشارات مرئية',
            description: 'إمكانية إجراء استشارات مرئية مع المحامين',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.history,
            title: 'سجل الاستشارات',
            description: 'حفظ وتتبع جميع الاستشارات السابقة',
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
