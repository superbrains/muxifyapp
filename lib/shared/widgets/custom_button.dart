import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final ButtonVariant variant;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.variant = ButtonVariant.elevated,
  });

  const CustomButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : variant = ButtonVariant.outlined;

  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : variant = ButtonVariant.text;

  const CustomButton.signUp({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : variant = ButtonVariant.signUp;

  const CustomButton.signIn({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : variant = ButtonVariant.signIn;

  @override
  Widget build(BuildContext context) {
    final Widget buttonContent = _buildButtonContent();

    switch (variant) {
      case ButtonVariant.elevated:
        return SizedBox(
          width: width,
          height: height ?? 48.buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: width,
          height: height ?? 48.buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonVariant.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonVariant.signUp:
        return SizedBox(
          width: width,
          height: height ?? 48.buttonHeight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(12.radius),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(12.radius),
                child: Center(child: buttonContent),
              ),
            ),
          ),
        );
      case ButtonVariant.signIn:
        return SizedBox(
          width: width,
          height: height ?? 48.buttonHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.radius),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : onPressed,
                    borderRadius: BorderRadius.circular(12.radius),
                    child: Center(child: buttonContent),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.text),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.icon, color: AppColors.text),
          8.row,
          Text(text, style: AppTextStyles.buttonText),
        ],
      );
    }

    return Text(text, style: AppTextStyles.buttonText);
  }
}

enum ButtonVariant { elevated, outlined, text, signUp, signIn }
