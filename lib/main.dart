import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/lawsuit_provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/legal_library_screen.dart';
import 'screens/smart_assistant_screen.dart';
import 'screens/training_screen.dart';
import 'screens/inquiries_screen.dart';
import 'screens/contact_us_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/blog_screen.dart';
import 'screens/laws_screen.dart';
import 'screens/services_screen.dart';
import 'screens/complaint_screen.dart';
import 'screens/daily_sessions_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/electronic_lawsuit_screen.dart';
import 'screens/supreme_court_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/subscribe_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/payment_order_screen.dart';
import 'screens/appeal_screen.dart';
import 'screens/legal_database_screen.dart';
import 'screens/ai_case_analysis_screen.dart';
import 'screens/case_management_screen.dart';
import 'screens/case_accounting_screen.dart';
import 'screens/legal_forms_screen.dart';
import 'screens/remote_consultations_screen.dart';
import 'screens/procedures_guide_screen.dart';
import 'screens/inheritance_calculation_screen.dart';
import 'screens/area_calculation_screen.dart';
import 'screens/notary_accounting_screen.dart';
import 'screens/contracts_agencies_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/notifications_screen.dart';
import 'screens/electronic_services_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create shared ApiService instance
    final apiService = ApiService();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider(apiService: apiService);
            authProvider.initialize();
            return authProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => LawsuitProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final settingsProvider = SettingsProvider();
            settingsProvider.initialize();
            return settingsProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(apiService),
          update: (_, authProvider, previous) {
            return NotificationProvider(apiService);
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'SmartJudi - منصة قضائية',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Cairo', // Arabic font (you may need to add it)
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'Cairo',
            ),
            themeMode: settingsProvider.darkModeEnabled 
                ? ThemeMode.dark 
                : ThemeMode.light,
            home: const AuthWrapper(),
            routes: {
              '/register': (context) => const RegisterScreen(),
              '/legal-library': (context) => const LegalLibraryScreen(),
              '/smart-assistant': (context) => const SmartAssistantScreen(),
              '/training': (context) => const TrainingScreen(),
              '/inquiries': (context) => const InquiriesScreen(),
              '/contact-us': (context) => const ContactUsScreen(),
              '/about-us': (context) => const AboutUsScreen(),
              '/blog': (context) => const BlogScreen(),
              '/laws': (context) => const LawsScreen(),
              '/services': (context) => const ServicesScreen(),
              '/complaint': (context) => const ComplaintScreen(),
              '/daily-sessions': (context) => const DailySessionsScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/electronic-lawsuit': (context) => const ElectronicLawsuitScreen(),
              '/supreme-court': (context) => const SupremeCourtScreen(),
              '/faq': (context) => const FAQScreen(),
              '/subscribe': (context) => const SubscribeScreen(),
              '/payment-order': (context) => const PaymentOrderScreen(),
              '/appeal': (context) => const AppealScreen(),
              '/legal-database': (context) => const LegalDatabaseScreen(),
              '/ai-case-analysis': (context) => const AICaseAnalysisScreen(),
              '/case-management': (context) => const CaseManagementScreen(),
              '/case-accounting': (context) => const CaseAccountingScreen(),
              '/legal-forms': (context) => const LegalFormsScreen(),
              '/remote-consultations': (context) => const RemoteConsultationsScreen(),
              '/procedures-guide': (context) => const ProceduresGuideScreen(),
              '/inheritance-calculation': (context) => const InheritanceCalculationScreen(),
              '/area-calculation': (context) => const AreaCalculationScreen(),
              '/notary-accounting': (context) => const NotaryAccountingScreen(),
              '/contracts-agencies': (context) => const ContractsAgenciesScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/electronic-services': (context) => const ElectronicServicesScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Auth Wrapper - Shows login or home based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show login if not authenticated, home if authenticated
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
