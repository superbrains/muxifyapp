import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/models/onboarding/suggested_artist.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/auth/providers/onboarding_provider.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FollowFavouritesScreen extends StatefulWidget {
  const FollowFavouritesScreen({super.key});

  @override
  State<FollowFavouritesScreen> createState() => _FollowFavouritesScreenState();
}

class _FollowFavouritesScreenState extends State<FollowFavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedArtistIds = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OnboardingProvider>().loadSuggestedArtists(
            count: OnboardingProvider.defaultSuggestedArtistCount,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SuggestedArtist> _filtered(List<SuggestedArtist> source) {
    final q = _searchController.text.trim().toLowerCase();
    final withIds =
        source.where((a) => a.id.trim().isNotEmpty).toList(growable: false);
    if (q.isEmpty) return withIds;
    return withIds
        .where((a) => a.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> _onRefresh() async {
    await context.read<OnboardingProvider>().loadSuggestedArtists(
          refreshing: true,
          count: OnboardingProvider.defaultSuggestedArtistCount,
        );
  }

  Future<void> _onComplete() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    final ids = List<String>.from(_selectedArtistIds);
    final onboarding = context.read<OnboardingProvider>();
    setState(() => _isSubmitting = true);
    final ok = await onboarding.submitFollowOnboarding(ids);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) context.push(AppRouter.congratulations);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              40.column,
              _buildTitle(),
              8.column,
              _buildSubtitle(),
              30.column,
              _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.buttonColor,
                  backgroundColor: AppColors.glassyDark,
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      20.verticalSliverSpacing,
                      ..._buildSuggestedContentSlivers(onboarding),
                    ],
                  ),
                ),
              ),
              _buildCompleteButton(onboarding),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Follow your favourites',
      style: AppTextStyles.heading2.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Be the first to access their contents before anyone',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.text.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomInputField(
      controller: _searchController,
      hintText: 'Search Artist & Creators',
      borderRadius: 50.radius,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.padding,
        vertical: 0.padding,
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  List<Widget> _buildSuggestedContentSlivers(OnboardingProvider onboarding) {
    final busyEmpty =
        onboarding.suggestedArtistsBusy && onboarding.suggestedArtists.isEmpty;
    final hasError = onboarding.suggestedArtistsError != null &&
        onboarding.suggestedArtists.isEmpty &&
        !onboarding.suggestedArtistsBusy;

    if (hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _SuggestedError(
            message: onboarding.suggestedArtistsError ??
                'Something went wrong.',
            onRetry: () => context.read<OnboardingProvider>().loadSuggestedArtists(
                  count: OnboardingProvider.defaultSuggestedArtistCount,
                ),
          ),
        ),
      ];
    }

    if (busyEmpty) {
      return [_buildShimmerSliverGrid()];
    }

    final filtered = _filtered(onboarding.suggestedArtists);
    if (filtered.isEmpty) {
      final any =
          onboarding.suggestedArtists.any((a) => a.id.trim().isNotEmpty);
      final msg = !any
          ? 'No suggested artists yet.'
          : (_searchController.text.trim().isEmpty
              ? 'No suggested artists yet.'
              : 'No matching artists.');
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.padding),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.zero,
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.78,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildArtistItem(filtered[index]),
        ),
      ),
      if (onboarding.suggestedArtistsRefreshing) ...[
        16.verticalSliverSpacing,
        SliverToBoxAdapter(
          child: Center(
            child: SizedBox(
              height: 4,
              width: 160,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(2),
                backgroundColor: AppColors.glassyDark,
                color: AppColors.buttonColor,
              ),
            ),
          ),
        ),
      ],
    ];
  }

  Widget _buildShimmerSliverGrid() {
    final base = const Color(0xFF161616);
    final highlight = const Color(0xFF2C2C2C);

    return SliverPadding(
      padding: EdgeInsets.zero,
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.78,
        ),
        itemCount: 12,
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            period: const Duration(milliseconds: 1400),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF808080),
                    shape: BoxShape.circle,
                  ),
                ),
                8.column,
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF808080),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtistItem(SuggestedArtist artist) {
    final isSelected = _selectedArtistIds.contains(artist.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (isSelected) {
            _selectedArtistIds.remove(artist.id);
          } else {
            _selectedArtistIds.add(artist.id);
          }
        });
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.buttonColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipOval(child: _buildArtistAvatarInner(artist)),
              ),
              if (artist.isVerified)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: EdgeInsets.all(2.padding),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 18,
                      color: AppColors.buttonColor,
                    ),
                  ),
                ),
            ],
          ),
          8.column,
          Text(
            artist.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArtistAvatarInner(SuggestedArtist artist) {
    final url = artist.resolvedImageUrl;
    if (url.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getArtistColor(artist.name).withValues(alpha: 0.3),
              _getArtistColor(artist.name).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            size: 40,
            color: AppColors.text.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      width: 80,
      height: 80,
      placeholder: Shimmer.fromColors(
        baseColor: const Color(0xFF161616),
        highlightColor: const Color(0xFF2C2C2C),
        period: const Duration(milliseconds: 1400),
        child: const ColoredBox(color: Color(0xFF808080)),
      ),
      errorWidget: ColoredBox(
        color: AppColors.glassyDark,
        child: Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: AppColors.text.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Color _getArtistColor(String artistName) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
    ];

    final hash = artistName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Widget _buildCompleteButton(OnboardingProvider onboarding) {
    final disableGrid = onboarding.suggestedArtistsBusy &&
        onboarding.suggestedArtists.isEmpty;

    return CustomButton.signUp(
      text: 'Complete',
      width: double.infinity,
      height: 56.buttonHeight,
      isLoading: _isSubmitting,
      onPressed: disableGrid
          ? null
          : _onComplete,
    );
  }
}

extension on int {
  SliverToBoxAdapter get verticalSliverSpacing =>
      SliverToBoxAdapter(child: SizedBox(height: toDouble()));
}

/// Error only when grid is otherwise empty ([loadSuggestedArtists] failed initially).
class _SuggestedError extends StatelessWidget {
  const _SuggestedError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.text.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: 16.padding),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
