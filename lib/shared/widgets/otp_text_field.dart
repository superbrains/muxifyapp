import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class OtpTextField extends StatefulWidget {
  final int otpLength;
  final void Function(String) onOtpCompleted;
  final String errorMessage;
  final Color filledColor;
  final Color borderColor;
  final Color errorColor;
  final TextStyle? textStyle;
  final TextEditingController? controller;

  const OtpTextField({
    super.key,
    this.otpLength = 5,
    required this.onOtpCompleted,
    this.errorMessage = '',
    this.filledColor = AppColors.glassyDark,
    this.borderColor = const Color(0x33FFFFFF),
    this.errorColor = AppColors.buttonColor,
    this.textStyle,
    this.controller,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: widget.controller,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      showCursor: false,
      length: widget.otpLength,
      onCompleted: widget.onOtpCompleted,
      preFilledWidget: Text(
        '-',
        style:
            widget.textStyle ??
            AppTextStyles.heading2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withValues(alpha: 0.3),
            ),
      ),
      defaultPinTheme: PinTheme(
        height: 48,
        width: 48,
        textStyle:
            widget.textStyle ??
            AppTextStyles.heading2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          color: widget.filledColor,
          border: Border.all(
            color: widget.errorMessage.isNotEmpty
                ? widget.errorColor
                : widget.borderColor,
          ),
        ),
      ),
      submittedPinTheme: PinTheme(
        height: 48,
        width: 48,
        textStyle:
            widget.textStyle ??
            AppTextStyles.heading2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
        decoration: BoxDecoration(
          color: widget.filledColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.errorMessage.isNotEmpty
                ? widget.errorColor
                : widget.borderColor,
          ),
        ),
      ),
    );
  }
}
