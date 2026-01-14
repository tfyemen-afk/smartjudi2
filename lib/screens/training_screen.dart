import 'package:flutter/material.dart';

/// Training and Qualification Screen - التدريب والتأهيل
class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التدريب والتأهيل'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTrainingCard(
            context,
            'دورة أساسيات القانون',
            'تعلم أساسيات القانون اليمني',
            Icons.school,
            Colors.blue,
          ),
          _buildTrainingCard(
            context,
            'دورة الإجراءات القضائية',
            'تعلم الإجراءات القضائية والمرافعات',
            Icons.gavel,
            Colors.green,
          ),
          _buildTrainingCard(
            context,
            'دورة كتابة المذكرات',
            'تعلم كيفية كتابة المذكرات القانونية',
            Icons.description,
            Colors.orange,
          ),
          _buildTrainingCard(
            context,
            'دورة المحاماة',
            'دورة متخصصة في المحاماة',
            Icons.balance,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to course details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فتح دورة: $title')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

