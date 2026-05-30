import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_strings.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/services/local_storage_service.dart';

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
    final accessToken = (await LocalStorageService.getAccessToken())?.trim() ?? '';
    final refreshToken = (await LocalStorageService.getRefreshToken())?.trim() ?? '';
    final hasSession = accessToken.isNotEmpty || refreshToken.isNotEmpty;

    // Proactively rotate the token so the user lands on a working home without
    // the first call having to 401-then-refresh. Best-effort and raced against
    // the splash delay so a cold/offline backend never stalls startup — if it
    // fails we still proceed (reactive refresh + GET retries recover later).
    final warmUp = (hasSession && refreshToken.isNotEmpty)
        ? ApiRequester()
            .ensureFreshAccessToken()
            .timeout(const Duration(seconds: 4), onTimeout: () => false)
            .catchError((_) => false)
        : Future<bool>.value(false);

    await Future.wait<void>([
      Future<void>.delayed(const Duration(seconds: 3)),
      warmUp,
    ]);
    if (!mounted) return;

    // Never drop the session on a failed warm-up — keep the user signed in.
    context.go(hasSession ? AppRouter.home : AppRouter.welcome);
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
