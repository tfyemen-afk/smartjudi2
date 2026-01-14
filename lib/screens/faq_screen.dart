import 'package:flutter/material.dart';

/// FAQ Screen - أسئلة شائعة
class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'كيف يمكنني رفع دعوى إلكترونية؟',
      'answer':
          'يمكنك رفع دعوى إلكترونية من خلال الذهاب إلى قسم "رفع دعوى إلكترونية" وملء النموذج المطلوب.',
    },
    {
      'question': 'ما هي المستندات المطلوبة لرفع دعوى؟',
      'answer':
          'المستندات المطلوبة تختلف حسب نوع الدعوى. بشكل عام، تحتاج إلى: الهوية الوطنية، المستندات المتعلقة بالقضية، والمرفقات الأخرى حسب الحاجة.',
    },
    {
      'question': 'كيف يمكنني متابعة حالة دعواي؟',
      'answer':
          'يمكنك متابعة حالة دعواك من خلال قسم "الاستعلامات" وإدخال رقم الدعوى.',
    },
    {
      'question': 'ما هي رسوم رفع الدعوى؟',
      'answer':
          'الرسوم تختلف حسب نوع الدعوى والمحكمة. يمكنك الاطلاع على جدول الرسوم من قسم "الخدمات".',
    },
    {
      'question': 'كيف يمكنني التواصل مع المحكمة؟',
      'answer':
          'يمكنك التواصل مع المحكمة من خلال قسم "تواصل بنا" أو الاتصال بالرقم المخصص.',
    },
    {
      'question': 'هل يمكنني رفع دعوى بدون محامي؟',
      'answer':
          'نعم، يمكنك رفع دعوى بدون محامي، لكن يُنصح بالاستعانة بمحامٍ في القضايا المعقدة.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أسئلة شائعة'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                faq['question'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['answer'] ?? '',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

