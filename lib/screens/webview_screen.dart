import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// WebView Screen - لعرض الروابط داخل التطبيق
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    // Set timeout for loading (30 seconds)
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'انتهت مهلة التحميل. يرجى التحقق من الاتصال بالإنترنت والمحاولة مرة أخرى.';
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    // Set a common User Agent to avoid being blocked by government servers
    // This mimics a real Chrome browser on Android
    const String userAgent = "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36";

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Transparent background
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            developer.log('Loading progress: $progress%', name: 'WebViewScreen');
            if (progress > 80 && _isLoading) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            developer.log('Page started loading: $url', name: 'WebViewScreen');
            _timeoutTimer?.cancel();
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            
            _timeoutTimer = Timer(const Duration(seconds: 30), () {
              if (mounted && _isLoading) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'انتهت مهلة التحميل. قد يكون الموقع غير متاح حالياً.';
                });
              }
            });
          },
          onPageFinished: (String url) {
            developer.log('Page finished loading: $url', name: 'WebViewScreen');
            _timeoutTimer?.cancel();
            if (mounted) {
              setState(() => _isLoading = false);
            }
            
            // Critical: Force visibility via JS as a fallback
            _controller.runJavaScript("document.body.style.visibility='visible';");
          },
          onWebResourceError: (WebResourceError error) {
            developer.log('WebResourceError: ${error.errorCode} - ${error.description}', name: 'WebViewScreen');
            _timeoutTimer?.cancel();
            
            // Ignore some non-critical errors
            if (error.errorCode == -999) return; // Cancelled

            setState(() {
              _isLoading = false;
              String errorMsg;
              switch (error.errorCode) {
                case -2: errorMsg = 'فشل في الوصول للخادم. تأكد من اتصالك بالإنترنت.'; break;
                case -6: errorMsg = 'فشل الاتصال الآمن بالخادم.'; break;
                case -8: errorMsg = 'انتهت مهلة الموقع في الرد.'; break;
                default: 
                  errorMsg = 'فشل تحميل الصفحة. قد يكون هناك مشكلة في شهادة الأمان للموقع الحكومي.';
              }
              _errorMessage = errorMsg;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    // Platform specific tuning
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _loadUrl();
  }

  void _loadUrl() {
    try {
      final uri = widget.url.startsWith('http') 
          ? Uri.parse(widget.url) 
          : Uri.parse('http://${widget.url}');
      _controller.loadRequest(uri);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'الرابط غير صالح';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7), // Neutral light background
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: const Color(0xFF1A1A1A),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _isLoading = true;
                _errorMessage = null;
                _controller.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => _openExternally(),
            ),
          ],
        ),
        body: IndexedStack(
          index: _errorMessage != null ? 1 : (_isLoading ? 2 : 0),
          children: [
            // Index 0: WebView
            WebViewWidget(controller: _controller),
            
            // Index 1: Error Screen
            _buildErrorScreen(),
            
            // Index 2: Loading Screen
            _buildLoadingScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFE91E63)),
          const SizedBox(height: 20),
          Text(
            'جاري فتح الخدمة الإلكترونية...',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Text(
            'قد تستغرق المواقع الحكومية وقتاً أطول للرد',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_update_warning, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'خطأ في الاتصال',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'بعض المواقع الحكومية تتطلب متصفح Chrome الخارجي لتعمل بشكل صحيح بسبب قيود الأمان.',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _openExternally(),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('فتح في متصفح النظام الخارجي', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            TextButton(
              onPressed: () => _controller.reload(),
              child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
