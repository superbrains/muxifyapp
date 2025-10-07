import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;

  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              24.column,
              Align(alignment: Alignment.centerLeft, child: _buildHeader()),
              40.column,
              _buildTitle(),
              8.column,
              _buildSubtitle(),
              40.column,
              _buildNewPasswordField(),
              16.column,
              _buildConfirmPasswordField(),
              250.column,
              _buildCreateButton(),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
    return Text(
      'Create a new password you can remember',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.text.withValues(alpha: 0.7),
      ),
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

  Widget _buildCreateButton() {
    return CustomButton.signUp(
      text: 'Create Password',
      width: double.infinity,
      onPressed: () {
        HapticFeedback.lightImpact();
        if (_newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            _newPasswordController.text == _confirmPasswordController.text) {
          context.go(AppRouter.login);
        }
      },
    );
  }
}
