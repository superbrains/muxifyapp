import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app browser that opens an ad's click-through URL. Uses the same
/// `webview_flutter` controller pattern as the payment-status screen.
class AdWebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const AdWebViewScreen({super.key, required this.url, this.title});

  @override
  State<AdWebViewScreen> createState() => _AdWebViewScreenState();
}

class _AdWebViewScreenState extends State<AdWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        title: Text(
          widget.title?.trim().isNotEmpty == true ? widget.title!.trim() : 'Sponsored',
          style: const TextStyle(color: AppColors.text, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.buttonColor),
            ),
        ],
      ),
    );
  }
}
