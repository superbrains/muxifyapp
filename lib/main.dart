import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/themes/app_theme.dart';
import 'package:muxify/core/constants/app_strings.dart';
import 'package:muxify/core/services/storage_service.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/audio_playback/widgets/global_player_overlay.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/features/auth/providers/onboarding_provider.dart';
import 'package:muxify/features/home/providers/home_provider.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/music_player/providers/lyrics_provider.dart';
import 'package:muxify/features/music_player/providers/music_player_interaction_provider.dart';
import 'package:muxify/features/my_music/providers/library_provider.dart';
import 'package:muxify/features/my_music/providers/local_playlists_provider.dart';
import 'package:muxify/features/my_music/providers/playable_tracks_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.muxify.audio.channel',
    androidNotificationChannelName: 'Muxify Playback',
    androidNotificationOngoing: true,
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
            ChangeNotifierProvider(create: (_) => HomeProvider()),
            ChangeNotifierProvider(
              create: (_) => UnlockedContentProvider()..hydrate(),
            ),
            ChangeNotifierProxyProvider<UnlockedContentProvider,
                ArtistProfileProvider>(
              create: (_) => ArtistProfileProvider(),
              update: (_, unlocked, previous) {
                final provider = previous ?? ArtistProfileProvider();
                provider.updatePersistedUnlocks(unlocked.ids);
                return provider;
              },
            ),
            ChangeNotifierProxyProvider<ArtistProfileProvider, AudioProvider>(
              create: (ctx) => AudioProvider(
                streamUrlProvider: ctx.read<ArtistProfileProvider>(),
              ),
              update: (_, _, previous) => previous!,
            ),
            ChangeNotifierProvider(create: (_) => LyricsProvider()),
            ChangeNotifierProvider(
              create: (_) => MusicPlayerInteractionProvider(),
            ),
            ChangeNotifierProvider(create: (_) => LibraryProvider()),
            ChangeNotifierProvider(create: (_) => PlayableTracksProvider()),
            ChangeNotifierProxyProvider<UnlockedContentProvider,
                LocalPlaylistsProvider>(
              create: (_) => LocalPlaylistsProvider()..hydrate(),
              update: (_, unlocked, previous) {
                final provider = previous ?? (LocalPlaylistsProvider()..hydrate());
                provider.bindUnlockedSource(unlocked);
                return provider;
              },
            ),
          ],
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            routerConfig: AppRouter.router,
            builder: (context, child) =>
                GlobalPlayerOverlay(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
