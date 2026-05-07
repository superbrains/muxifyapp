import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/models/onboarding/check_username_response.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/auth/providers/onboarding_provider.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class CreateUsernameScreen extends StatefulWidget {
  const CreateUsernameScreen({super.key});

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();

  Timer? _debounce;
  int _generation = 0;

  bool _checking = false;
  bool _settingUsername = false;
  CheckUsernameResponse? _lastResponse;
  String? _lastQuery;

  String get _normalized => _usernameController.text.trim().toLowerCase();

  bool get _resultMatches =>
      _lastResponse != null && _lastQuery != null && _lastQuery == _normalized;

  bool get _canContinue =>
      !_settingUsername &&
      _normalized.length >= 3 &&
      _normalized.length <= 30 &&
      _resultMatches &&
      _lastResponse!.available;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    setState(() {});

    _debounce?.cancel();
    final g = ++_generation;
    final n = _normalized;

    if (n.isEmpty) {
      setState(() {
        _checking = false;
        _lastResponse = null;
        _lastQuery = null;
      });
      return;
    }

    if (n.length < 3 || n.length > 30) {
      setState(() {
        _checking = false;
        _lastResponse = null;
        _lastQuery = null;
      });
      return;
    }

    setState(() => _checking = true);

    _debounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted || g != _generation) return;

      CheckUsernameResponse? resp;
      try {
        resp = await context.read<OnboardingProvider>().checkUsername(n);
      } on ApiRequestException catch (e) {
        if (!mounted || g != _generation) return;
        setState(() {
          _checking = false;
          _lastResponse = null;
          _lastQuery = null;
        });
        await AppToast.showError(e.message);
        return;
      } catch (_) {
        if (!mounted || g != _generation) return;
        setState(() {
          _checking = false;
          _lastResponse = null;
          _lastQuery = null;
        });
        await AppToast.showError('Could not check username. Try again.');
        return;
      }

      if (!mounted || g != _generation) return;
      final still = _normalized;
      if (still != n) return;

      setState(() {
        _checking = false;
        _lastResponse = resp;
        _lastQuery = n;
      });
    });
  }

  Future<void> _onContinue() async {
    if (!_canContinue) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    setState(() => _settingUsername = true);
    try {
      await context.read<OnboardingProvider>().setUsername(_normalized);
      if (!mounted) return;
      context.push(AppRouter.setupAvatar);
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
    } catch (_) {
      await AppToast.showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _settingUsername = false);
    }
  }

  void _applySuggestion(String username) {
    _usernameController.value = TextEditingValue(
      text: username.toLowerCase(),
      selection: TextSelection.collapsed(offset: username.length),
    );
  }

  static const Color _availabilityErrorRed = Color(0xFFE53935);

  List<String> get _effectiveSuggestions {
    final response = _lastResponse;
    if (response == null || response.available) return const [];

    final seen = <String>{};
    final out = <String>[];
    for (final s in response.suggestions) {
      final t = s.trim().toLowerCase();
      if (t.length < 3 || t.length > 30) continue;
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(t)) continue;
      if (seen.add(t)) out.add(t);
      if (out.length >= 12) break;
    }
    return out;
  }

  /// Trailing indicator: spinner while checking; green ✓ / red ✗ when matched to server.
  Widget? _buildUsernameSuffixIcon() {
    final n = _normalized;
    if (n.isEmpty) return null;
    if (n.length < 3 || n.length > 30) return null;

    final inset = EdgeInsets.only(right: 12.padding);

    if (_checking) {
      return Padding(
        padding: inset,
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.text.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    if (!_resultMatches) {
      return const SizedBox.shrink();
    }

    if (_lastResponse!.available) {
      return Padding(
        padding: inset,
        child: Icon(
          Icons.check_circle_rounded,
          color: AppColors.green,
          size: 26,
        ),
      );
    }

    return Padding(
      padding: inset,
      child: Icon(Icons.cancel_rounded, color: _availabilityErrorRed, size: 26),
    );
  }

  Widget _buildUsernameHelperText() {
    final n = _normalized;
    if (n.isEmpty) return const SizedBox.shrink();
    if (n.length < 3) {
      return Padding(
        padding: EdgeInsets.only(top: 8.padding),
        child: Text(
          'At least 3 characters',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.text.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    if (n.length > 30) {
      return Padding(
        padding: EdgeInsets.only(top: 8.padding),
        child: Text(
          'Maximum 30 characters',
          style: AppTextStyles.bodySmall.copyWith(color: _availabilityErrorRed),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              40.column,
              _buildTitle(),
              8.column,
              _buildSubtitle(),
              40.column,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUsernameField(),
                      16.column,
                      _buildSuggestions(),
                    ],
                  ),
                ),
              ),
              _buildContinueButton(),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Create Username',
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
        'Your username is your unique identifier on Muxify',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.text.withValues(alpha: 0.8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        8.column,
        TextFormField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          autocorrect: false,
          enableSuggestions: false,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF141414),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            // Inline `prefix` shares the input row and baseline alignment; `prefixIcon` often floats high.
            prefix: Padding(
              padding: EdgeInsets.only(right: 4.padding),
              child: Text(
                '@',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 40.padding,
              minHeight: 40.padding,
            ),
            suffixIcon: _buildUsernameSuffixIcon(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.padding,
              vertical: 14.padding,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            LengthLimitingTextInputFormatter(30),
          ],
        ),
        _buildUsernameHelperText(),
      ],
    );
  }

  Widget _buildSuggestions() {
    if (!_resultMatches || _lastResponse == null || _lastResponse!.available) {
      return const SizedBox.shrink();
    }
    final suggestions = _effectiveSuggestions;
    if (suggestions.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 16.padding),
        child: Text(
          'That username is already taken.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.text.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 20.padding),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.padding),
        decoration: BoxDecoration(
          color: AppColors.glassyDark,
          borderRadius: BorderRadius.circular(14.radius),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: AppColors.text.withValues(alpha: 0.7),
                ),
                8.row,
                Expanded(
                  child: Text(
                    'That name is taken. Try one of these:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            14.column,
            SizedBox(
              height: 40.buttonHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => 8.row,
                itemBuilder: (context, index) {
                  final value = suggestions[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _applySuggestion(value);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 14.padding),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(999.radius),
                        border: Border.all(
                          color: AppColors.text.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        '@$value',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return CustomButton.signUp(
      text: 'Continue',
      width: double.infinity,
      isLoading: _settingUsername,
      onPressed: _canContinue && !_settingUsername ? _onContinue : null,
    );
  }
}
