import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

/// Settings Screen - الإعدادات
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          if (user != null) ...[
            // User Info Section
            UserAccountsDrawerHeader(
              accountName: Text(user.fullName),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ),
            ),
            const Divider(),
          ],

          // Account Settings
          _buildSectionHeader('إعدادات الحساب'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الملف الشخصي'),
            subtitle: const Text('عرض وتعديل معلوماتك الشخصية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('تغيير كلمة المرور'),
            subtitle: const Text('تحديث كلمة المرور الخاصة بك'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),

          // App Settings
          _buildSectionHeader('إعدادات التطبيق'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('الإشعارات'),
            subtitle: const Text('تلقي إشعارات حول الدعاوى والجلسات'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) {
              settingsProvider.setNotificationsEnabled(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'تم تفعيل الإشعارات' : 'تم إلغاء تفعيل الإشعارات'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تفعيل الوضع الليلي'),
            value: settingsProvider.darkModeEnabled,
            onChanged: (value) {
              settingsProvider.setDarkModeEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('اللغة'),
            subtitle: const Text('العربية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show language selection dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تغيير اللغة')),
              );
            },
          ),
          const Divider(),

          // Data & Storage
          _buildSectionHeader('البيانات والتخزين'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('تحميل البيانات'),
            subtitle: const Text('تحميل جميع بياناتك'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement data download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تحميل البيانات')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('حذف البيانات المحلية'),
            subtitle: const Text('حذف جميع البيانات المحفوظة محلياً'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showDeleteDataDialog(context, settingsProvider);
            },
          ),
          const Divider(),

          // About & Support
          _buildSectionHeader('حول التطبيق والدعم'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('من نحن'),
            subtitle: const Text('معلومات عن منصة SmartJudi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('مساعدة'),
            subtitle: const Text('الأسئلة الشائعة والدعم'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/faq');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('تواصل بنا'),
            subtitle: const Text('اتصل بنا أو أرسل رسالة'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('شروط الاستخدام'),
            subtitle: const Text('اقرأ شروط استخدام التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show terms and conditions
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: شروط الاستخدام')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('سياسة الخصوصية'),
            subtitle: const Text('اقرأ سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: سياسة الخصوصية')),
              );
            },
          ),
          const Divider(),

          // App Info
          _buildSectionHeader('معلومات التطبيق'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('الإصدار'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.update),
            title: Text('آخر تحديث'),
            subtitle: Text('2025-01-27'),
          ),
          const Divider(),

          // Logout
          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _showLogoutDialog(context, authProvider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await authProvider.logout();
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDataDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف البيانات المحلية'),
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف جميع البيانات المحفوظة محلياً؟\n\n'
            'سيتم حذف:\n'
            '• بيانات تسجيل الدخول\n'
            '• الإعدادات المحلية\n'
            '• البيانات المؤقتة\n\n'
            'لن يتم حذف البيانات من الخادم.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await settingsProvider.clearLocalData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف البيانات المحلية بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في حذف البيانات: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

