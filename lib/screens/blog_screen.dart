import 'package:flutter/material.dart';

/// Blog Screen - مدونة
class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock blog posts
    final blogPosts = [
      {
        'title': 'تحديثات جديدة في النظام القضائي',
        'date': '2024-01-15',
        'author': 'فريق SmartJudi',
        'excerpt': 'نقدم لكم آخر التحديثات والتحسينات في منصة SmartJudi...',
      },
      {
        'title': 'كيفية رفع دعوى إلكترونية',
        'date': '2024-01-10',
        'author': 'فريق SmartJudi',
        'excerpt': 'دليل شامل لرفع الدعاوى إلكترونياً عبر المنصة...',
      },
      {
        'title': 'القوانين الجديدة لعام 2024',
        'date': '2024-01-05',
        'author': 'فريق SmartJudi',
        'excerpt': 'ملخص لأهم القوانين والتعديلات الجديدة...',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدونة'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          final post = blogPosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to blog post details
                Navigator.pushNamed(context, '/blog-details', arguments: post);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          post['date'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          post['author'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['excerpt'] ?? '',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اقرأ المزيد...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

