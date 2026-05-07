import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/validators.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({
    super.key,
    this.initialToken,
    this.email,
  });

  /// From deep link or email: `?token=...`
  final String? initialToken;

  /// Optional; for display context only.
  final String? email;

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get _hasPresetToken {
    final t = widget.initialToken?.trim() ?? '';
    return t.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final t = widget.initialToken?.trim();
    if (t != null && t.isNotEmpty) {
      _tokenController.text = t;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final pwd = _newPasswordController.text;
    final token = _tokenController.text.trim();
    final ok = await auth.submitPasswordReset(token: token, password: pwd);
    if (!mounted || !ok) return;
    context.go(AppRouter.login);
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return Validators.required(value);
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  String? _tokenValidator(String? value) {
    if (_hasPresetToken) return null;
    return Validators.required(value);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                24.column,
                Align(alignment: Alignment.centerLeft, child: _buildHeader(context)),
                40.column,
                _buildTitle(),
                8.column,
                _buildSubtitle(),
                40.column,
                if (!_hasPresetToken) ...[
                  _buildTokenField(),
                  16.column,
                ],
                _buildNewPasswordField(),
                16.column,
                _buildConfirmPasswordField(),
                250.column,
                CustomButton.signUp(
                  text: 'Create Password',
                  width: double.infinity,
                  isLoading: auth.isResetPasswordSubmitting,
                  onPressed: () => _submit(auth),
                ),
                32.column,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.text,
              size: 18,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.buttonColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999.radius),
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.buttonColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Create New Password',
      style: AppTextStyles.heading1.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle() {
    final hint = widget.email?.trim();
    return Text(
      hint != null && hint.isNotEmpty
          ? 'Use the reset token from your email for $hint.'
          : 'Use the reset token from your email, then choose a new password.',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.text.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTokenField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset token',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.column,
        CustomInputField(
          controller: _tokenController,
          hintText: 'Paste the token from the reset email',
          borderRadius: 12.radius,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 16.padding,
          ),
          validator: _tokenValidator,
        ),
      ],
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.column,
        CustomInputField(
          controller: _newPasswordController,
          hintText: 'New Password',
          obscureText: !_isNewPasswordVisible,
          borderRadius: 12.radius,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 16.padding,
          ),
          validator: Validators.signupPassword,
          suffixIcon: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.padding),
              child: Icon(
                _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.text.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat New Password',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.column,
        CustomInputField(
          controller: _confirmPasswordController,
          hintText: 'Repeat New Password',
          obscureText: !_isConfirmPasswordVisible,
          borderRadius: 12.radius,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 16.padding,
          ),
          validator: _confirmPasswordValidator,
          suffixIcon: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.padding),
              child: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.text.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
