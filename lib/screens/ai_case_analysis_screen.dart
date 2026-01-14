import 'package:flutter/material.dart';

/// AI-Powered Case Analysis and Preparation Screen - تحليل وإعداد القضايا بالذكاء الاصطناعي
class AICaseAnalysisScreen extends StatefulWidget {
  const AICaseAnalysisScreen({super.key});

  @override
  State<AICaseAnalysisScreen> createState() => _AICaseAnalysisScreenState();
}

class _AICaseAnalysisScreenState extends State<AICaseAnalysisScreen> {
  final TextEditingController _caseDescriptionController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _caseDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل وإعداد القضايا بالذكاء الاصطناعي'),
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
                  const Text(
                    'تحليل القضية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _caseDescriptionController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'وصف القضية',
                      hintText: 'أدخل تفاصيل القضية للتحليل...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeCase,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isAnalyzing ? 'جاري التحليل...' : 'تحليل القضية'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.description,
            title: 'إعداد الدعاوى',
            description: 'إعداد الدعاوى تلقائياً حسب البيانات المقدمة وأطراف التقاضي',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.reply,
            title: 'معالجة الردود',
            description: 'إعداد الردود على الدعاوى والطعون والخدمات المطلوبة',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.gavel,
            title: 'التحليل القانوني',
            description: 'تحليل القضايا بناءً على القوانين والتشريعات اليمنية',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  void _analyzeCase() {
    if (_caseDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال وصف القضية')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // Simulate analysis
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قريباً: ميزة التحليل بالذكاء الاصطناعي')),
      );
    });
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
