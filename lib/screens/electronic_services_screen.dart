import 'package:flutter/material.dart';
import 'webview_screen.dart';

/// Electronic Services Screen - الخدمات الإلكترونية والروابط
class ElectronicServicesScreen extends StatelessWidget {
  const ElectronicServicesScreen({super.key});

  // الخدمات الإلكترونية
  final List<Map<String, String>> _electronicServices = const [
    {
      'title': 'البحث عن قضية',
      'url': 'http://mojcitr.myftp.biz:8008/JUDDATALIST/CustomRetCaseMaster',
    },
    {
      'title': 'خدمة الدعاوى الإلكتروني',
      'url': 'https://judg.moj.gov.ye:8065/',
    },
    {
      'title': 'البحث عن الامناء الشرعيين',
      'url': 'http://mojcitr.myftp.biz:8008/OMANALIST/CustomGetOmanaWithPic',
    },
    {
      'title': 'البحث عن المعاملات',
      'url': 'http://mojcitr.myftp.biz:8008/InoutData/CustomInOutData',
    },
    {
      'title': 'البحث عن الجلسات اليومية',
      'url': 'http://mojcitr.myftp.biz:8008/JudgmentData/CustomRetCourtSittingByDate',
    },
  ];

  // روابط تهمك
  final List<Map<String, String>> _importantLinks = const [
    {
      'title': 'مجلس القضاء الأعلى',
      'url': 'http://www.sjc-yemen.com/',
    },
    {
      'title': 'المحكمة العليا',
      'url': 'https://ysc.org.ye/',
    },
    {
      'title': 'النيابة العامة',
      'url': 'https://agoye.gov.ye/',
    },
    {
      'title': 'المعهد العالي للقضاء',
      'url': 'http://www.hji-yemen.com/',
    },
    {
      'title': 'الجريدة الرسمية',
      'url': 'https://moj.gov.ye/OfficialGazette',
    },
  ];

  // روابط إضافية
  final List<Map<String, String>> _additionalLinks = const [
    {
      'title': 'وزارة العدل',
      'url': 'https://moj.gov.ye/',
    },
    {
      'title': 'تنزيل القوانين والتشريعات',
      'url': 'https://moj.gov.ye/LawsM',
    },
  ];

  void _openURL(String url, String title, BuildContext context) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد رابط متاح لهذه الخدمة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            url: url,
            title: title,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء فتح الرابط: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخدمات الإلكترونية والروابط'),
        backgroundColor: const Color(0xFF1E3A8A), // Dark blue
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Dark blue
              Color(0xFF1E40AF), // Slightly lighter blue
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الخدمات الإلكترونية
              _buildSection(
                title: 'الخدمات الالكترونية',
                items: _electronicServices,
                onItemTap: (url, title) => _openURL(url, title, context),
              ),
              const SizedBox(height: 32),
              
              // روابط تهمك
              _buildSection(
                title: 'روابط تهمك',
                items: _importantLinks,
                onItemTap: (url, title) => _openURL(url, title, context),
              ),
              const SizedBox(height: 32),
              
              // روابط إضافية
              _buildSection(
                title: 'روابط إضافية',
                items: _additionalLinks,
                onItemTap: (url, title) => _openURL(url, title, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, String>> items,
    required Function(String, String) onItemTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF60A5FA), // Light blue
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // قائمة العناصر
        ...items.map((item) => _buildServiceItem(
          title: item['title']!,
          url: item['url']!,
          onTap: () => onItemTap(item['url']!, item['title']!),
        )),
      ],
    );
  }

  Widget _buildServiceItem({
    required String title,
    required String url,
    required VoidCallback onTap,
  }) {
    final bool hasUrl = url.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasUrl ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // السهم
                Icon(
                  Icons.arrow_back_ios,
                  color: hasUrl ? const Color(0xFF60A5FA) : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                
                // النص
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: hasUrl ? Colors.white : Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                
                // أيقونة إذا كان هناك رابط
                if (hasUrl)
                  const Icon(
                    Icons.launch,
                    color: Color(0xFF60A5FA),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
