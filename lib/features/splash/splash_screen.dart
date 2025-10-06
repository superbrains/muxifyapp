import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_strings.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go(AppRouter.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: Stack(
          children: [
            Center(child: Image.asset('assets/pngs/logo.png', width: 164)),
            24.column,

            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Text(
                AppStrings.appName,
                style: AppTextStyles.heading1WithColor(Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

            8.column,
          ],
        ),
      ),
    );
  }
}
