import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'lawsuits_list_screen.dart';
import 'lawsuit_detail_screen.dart';
import 'inquiries_screen.dart';
import 'settings_screen.dart';
import 'payment_order_screen.dart';
import 'appeal_screen.dart';

/// Home Screen - Dashboard based on user role
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('منصة SmartJudi القضائية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.fullName),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('الدعاوى'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('خدماتنا'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/services');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('المكتبة القانونية'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/legal-library');
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('المساعد الذكي'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/smart-assistant');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('الاستعلامات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inquiries');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('الجلسات اليومية'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/daily-sessions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('رفع دعوى إلكترونية'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/electronic-lawsuit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('أمر الأداء'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentOrderScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('الطعون'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppealScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('القوانين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/laws');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('التدريب والتأهيل'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/training');
              },
            ),
            ListTile(
              leading: const Icon(Icons.balance),
              title: const Text('المحكمة العليا'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/supreme-court');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('مدونة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/blog');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('أسئلة شائعة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/faq');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('من نحن'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about-us');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('تواصل بنا'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact-us');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('اشتراك'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscribe');
              },
            ),
            if (user.isJudge || user.isAdmin)
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('الجلسات'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to hearings screen
                },
              ),
            if (user.isJudge || user.isAdmin)
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('الأحكام'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to judgments screen
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const LawsuitsListScreen(),
          const InquiriesScreen(), // Search screen
          const SettingsScreen(), // Settings screen
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel),
            label: 'الدعاوى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
      // FloatingActionButton moved to LawsuitsListScreen
    );
  }
}

