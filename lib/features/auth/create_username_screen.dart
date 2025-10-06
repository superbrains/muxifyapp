import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/custom_button.dart';

class CreateUsernameScreen extends StatefulWidget {
  const CreateUsernameScreen({super.key});

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  bool _isUsernameAvailable = false;
  bool _isCheckingAvailability = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      _checkUsernameAvailability(username);
    } else {
      setState(() {
        _isUsernameAvailable = false;
        _isCheckingAvailability = false;
      });
    }
  }

  void _checkUsernameAvailability(String username) {
    setState(() {
      _isCheckingAvailability = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isCheckingAvailability = false;
          _isUsernameAvailable =
              username.length >= 3 && !username.contains(' ');
        });
      }
    });
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
              _buildUsernameField(),
              const Spacer(),
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
            prefixIcon: Padding(
              padding: EdgeInsets.all(10.padding),
              child: Text(
                '@',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ),
            suffixIcon: _usernameController.text.isNotEmpty
                ? Container(
                    height: 25.buttonHeight,
                    width: 80.buttonHeight,
                    margin: EdgeInsets.all(10.padding),
                    padding: EdgeInsets.symmetric(horizontal: 12.padding),
                    decoration: BoxDecoration(
                      color: _isCheckingAvailability
                          ? AppColors.text.withValues(alpha: 0.3)
                          : _isUsernameAvailable
                          ? AppColors.green
                          : AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(16.radius),
                    ),
                    child: Center(
                      child: Text(
                        _isUsernameAvailable ? 'Available' : 'Taken',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.font,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.padding),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            LengthLimitingTextInputFormatter(20),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return CustomButton.signUp(
      text: 'Continue',
      width: double.infinity,
      onPressed: _isUsernameAvailable
          ? () {
              HapticFeedback.lightImpact();
              context.push(AppRouter.setupAvatar);
            }
          : null,
    );
  }
}
