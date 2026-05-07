import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/features/auth/providers/onboarding_provider.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

/// Avatars are persisted with **`POST /api/v1/onboarding/set-avatar`** (`multipart/form-data`, Bearer required):
/// - **Preset:** form field **`avatarUrl`** = same path as `GET /api/v1/onboarding/avatars` (e.g. `/assets/avatars/male/avatar-m-1.png`).
/// - **Custom:** multipart part **`file`** (image bytes).
class SetupAvatarScreen extends StatefulWidget {
  const SetupAvatarScreen({super.key});

  @override
  State<SetupAvatarScreen> createState() => _SetupAvatarScreenState();
}

class _SetupAvatarScreenState extends State<SetupAvatarScreen> {
  String _selectedGender = 'male';
  String? _selectedPresetPath;
  Uint8List? _pickedAvatarBytes;
  String? _uploadedResolvedUrl;

  bool _isUploadingCustom = false;
  bool _isContinuing = false;

  final ImagePicker _picker = ImagePicker();

  OnboardingProvider? _onboardingListenerTarget;

  /// API-relative paths (e.g. `/assets/avatars/…`); use [ApiConstants.resolvePublicUrl] when loading images.
  List<String> _urlsFor(OnboardingProvider onboarding) {
    final p = onboarding.presetAvatars;
    if (p == null) return const [];
    return _selectedGender == 'female' ? p.female : p.male;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OnboardingProvider>().loadPresetAvatars();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final onboarding = context.read<OnboardingProvider>();
    if (!identical(_onboardingListenerTarget, onboarding)) {
      _onboardingListenerTarget?.removeListener(_syncSelectionWithPresets);
      _onboardingListenerTarget = onboarding;
      onboarding.addListener(_syncSelectionWithPresets);
    }
  }

  void _syncSelectionWithPresets() {
    final o = _onboardingListenerTarget;
    if (o == null || !mounted) return;
    final urls = _urlsFor(o);
    if (_selectedPresetPath != null && !urls.contains(_selectedPresetPath)) {
      setState(() => _selectedPresetPath = null);
    }
  }

  @override
  void dispose() {
    _onboardingListenerTarget?.removeListener(_syncSelectionWithPresets);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.buttonColor,
          backgroundColor: AppColors.glassyDark,
          onRefresh: () => context.read<OnboardingProvider>().loadPresetAvatars(
            refreshing: true,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitle(),
                8.column,
                _buildSubtitle(),
                40.column,
                _buildGenderSelection(onboarding),
                55.column,
                _buildUploadButton(),
                if (_pickedAvatarBytes != null) ...[
                  20.column,
                  _buildCustomPreview(),
                ],
                43.column,
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildAvatarGridSection(onboarding),
                ),
                32.column,
                _buildContinueButton(),
                32.column,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Setup Avatar',
        style: AppTextStyles.heading2.copyWith(
          fontSize: 28.font,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        'Choose the avatar that represents you',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.text.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildGenderSelection(OnboardingProvider onboarding) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGenderButton(
          onboarding,
          'male',
          Icons.male,
          'Male',
          _selectedGender == 'male',
        ),
        16.row,
        _buildGenderButton(
          onboarding,
          'female',
          Icons.female,
          'Female',
          _selectedGender == 'female',
        ),
      ],
    );
  }

  Widget _buildGenderButton(
    OnboardingProvider onboarding,
    String gender,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedGender = gender;
          final urls = _urlsFor(onboarding);
          if (_selectedPresetPath != null &&
              !urls.contains(_selectedPresetPath)) {
            _selectedPresetPath = null;
          }
        });
      },
      child: Container(
        width: 108.buttonHeight,
        height: 44.buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(50.radius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.background : AppColors.text,
              size: 20,
            ),
            8.row,
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.background : AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    final busy = _isUploadingCustom || _isContinuing;
    return GestureDetector(
      onTap: busy
          ? null
          : () {
              HapticFeedback.lightImpact();
              _showPickSourceSheet();
            },
      child: Opacity(
        opacity: busy ? 0.55 : 1,
        child: Container(
          height: 50.buttonHeight,
          width: 217.buttonHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(50.radius),
          ),
          child: Center(
            child: _isUploadingCustom
                ? SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.text.withValues(alpha: 0.85),
                    ),
                  )
                : Text(
                    'Upload Picture',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPreview() {
    final bytes = _pickedAvatarBytes;
    if (bytes == null || bytes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          _isUploadingCustom
              ? 'Uploading…'
              : _uploadedResolvedUrl != null
              ? 'Your picture is ready'
              : 'Could not upload. Try another photo or pick again.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text.withValues(alpha: 0.75),
          ),
        ),
        12.column,
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _uploadedResolvedUrl != null && !_isUploadingCustom
                  ? AppColors.buttonColor
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarGridSection(OnboardingProvider onboarding) {
    if (onboarding.presetAvatarsShimmerLoading) {
      return _buildAvatarShimmerGrid();
    }

    if (onboarding.presetAvatars == null) {
      if (onboarding.presetAvatarsError != null) {
        return _buildAvatarLoadErrorState(onboarding);
      }
      return _buildAvatarShimmerGrid();
    }

    final urls = _urlsFor(onboarding);
    if (urls.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.padding),
        child: Text(
          onboarding.presetAvatarsError != null
              ? onboarding.presetAvatarsError!
              : 'No preset avatars for this category yet.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) => _buildNetworkAvatarTile(urls[index]),
    );
  }

  Widget _buildAvatarShimmerGrid() {
    final base = const Color(0xFF161616);
    final highlight = const Color(0xFF2C2C2C);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: 9,
        itemBuilder: (_, __) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF808080),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarLoadErrorState(OnboardingProvider onboarding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.padding),
      child: Column(
        children: [
          Text(
            onboarding.presetAvatarsError ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.75),
            ),
          ),
          16.column,
          TextButton(
            onPressed: () =>
                context.read<OnboardingProvider>().loadPresetAvatars(),
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
    );
  }

  Widget _buildNetworkAvatarTile(String apiPath) {
    final isSelected = _selectedPresetPath == apiPath;
    final imageUrl = ApiConstants.resolvePublicUrl(apiPath);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _pickedAvatarBytes = null;
          _uploadedResolvedUrl = null;
          _selectedPresetPath = apiPath;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.buttonColor : Colors.transparent,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            fadeInDuration: const Duration(milliseconds: 200),
            memCacheWidth: 256,
            memCacheHeight: 256,
            progressIndicatorBuilder: (_, __, _) {
              final base = const Color(0xFF161616);
              final highlight = const Color(0xFF2C2C2C);
              return Shimmer.fromColors(
                baseColor: base,
                highlightColor: highlight,
                period: const Duration(milliseconds: 1400),
                child: const ColoredBox(color: Color(0xFF808080)),
              );
            },
            errorWidget: (_, __, ___) {
              return ColoredBox(
                color: AppColors.glassyDark,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 36,
                  color: AppColors.text.withValues(alpha: 0.4),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final presetOk =
        _selectedPresetPath != null && _selectedPresetPath!.trim().isNotEmpty;
    final customOk =
        _uploadedResolvedUrl != null && _uploadedResolvedUrl!.trim().isNotEmpty;
    final canContinue =
        !_isContinuing && !_isUploadingCustom && (presetOk || customOk);

    return CustomButton.signUp(
      text: 'Continue',
      width: double.infinity,
      isLoading: _isContinuing,
      onPressed: canContinue ? _handleContinue : null,
    );
  }

  void _showPickSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF252525),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.radius)),
      ),
      builder: (sheetContext) {
        final padBottom = MediaQuery.paddingOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.padding + padBottom, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.text,
                ),
                title: Text(
                  'Choose from gallery',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.text,
                ),
                title: Text(
                  'Take a photo',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: 1536,
        maxHeight: 1536,
        imageQuality: 88,
      );
    } on PlatformException {
      await AppToast.showError('Could not access photos or camera.');
      return;
    }
    if (!mounted || picked == null) return;

    Uint8List bytes;
    try {
      bytes = await picked.readAsBytes();
    } catch (_) {
      await AppToast.showError('Could not read the selected image.');
      return;
    }
    final name = picked.name.trim().isEmpty ? 'avatar.jpg' : picked.name.trim();

    if (!mounted) return;
    final onboarding = context.read<OnboardingProvider>();

    setState(() {
      _pickedAvatarBytes = bytes;
      _uploadedResolvedUrl = null;
      _selectedPresetPath = null;
      _isUploadingCustom = true;
    });

    final url = await onboarding.uploadAvatarBytes(bytes, filename: name);

    if (!mounted) return;
    setState(() {
      _isUploadingCustom = false;
      _uploadedResolvedUrl = url;
    });
  }

  Future<void> _handleContinue() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final preset = _selectedPresetPath?.trim();
    final custom = _uploadedResolvedUrl?.trim();

    String? canonical;
    if (preset != null && preset.isNotEmpty) {
      if (!mounted) return;
      final onboarding = context.read<OnboardingProvider>();
      setState(() => _isContinuing = true);
      try {
        canonical = await onboarding.setPresetAvatar(preset);
      } finally {
        if (mounted) setState(() => _isContinuing = false);
      }
    } else if (custom != null && custom.isNotEmpty) {
      canonical = custom;
    }

    if (!mounted || canonical == null || canonical.isEmpty) return;

    final auth = context.read<AuthProvider>();
    await auth.updateStoredAvatarUrl(canonical);
    if (!mounted) return;

    context.push(AppRouter.followFavourites);
  }
}
