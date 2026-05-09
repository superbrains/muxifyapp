import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// A 4–6 digit PIN entry surface with a custom numeric keypad.
///
/// Fires [onSubmit] when [length] digits are entered. Tap-feedback is haptic;
/// no system keyboard is shown.
class PinEntryPad extends StatefulWidget {
  const PinEntryPad({
    super.key,
    required this.onSubmit,
    this.length = 4,
    this.title,
    this.subtitle,
    this.error,
    this.busy = false,
    this.resetOnSubmit = true,
  });

  final void Function(String pin) onSubmit;
  final int length;
  final String? title;
  final String? subtitle;
  final String? error;
  final bool busy;
  final bool resetOnSubmit;

  @override
  State<PinEntryPad> createState() => _PinEntryPadState();
}

class _PinEntryPadState extends State<PinEntryPad> {
  String _value = '';

  void _push(String d) {
    if (widget.busy) return;
    if (_value.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => _value = '$_value$d');
    if (_value.length == widget.length) {
      final submitted = _value;
      Future.microtask(() {
        widget.onSubmit(submitted);
        if (widget.resetOnSubmit && mounted) {
          setState(() => _value = '');
        }
      });
    }
  }

  void _backspace() {
    if (widget.busy || _value.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _value = _value.substring(0, _value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 22.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.column,
        ],
        if (widget.subtitle != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.padding),
            child: Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.font,
                color: AppColors.text.withValues(alpha: 0.6),
                height: 1.45,
              ),
            ),
          ),
        24.column,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (i) {
            final filled = i < _value.length;
            return Container(
              width: 16.icon,
              height: 16.icon,
              margin: EdgeInsets.symmetric(horizontal: 8.padding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.buttonColor : Colors.transparent,
                border: Border.all(
                  color: filled
                      ? AppColors.buttonColor
                      : AppColors.text.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
        if (widget.error != null) ...[
          14.column,
          Text(
            widget.error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.font,
              color: const Color(0xFFE57373),
            ),
          ),
        ],
        24.column,
        if (widget.busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          _Keypad(onTap: _push, onBackspace: _backspace),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onTap, required this.onBackspace});

  final void Function(String) onTap;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final d in row) _KeyButton(label: d, onTap: () => onTap(d)),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 72.icon, height: 72.icon),
              _KeyButton(label: '0', onTap: () => onTap('0')),
              _KeyButton(
                onTap: onBackspace,
                child: Icon(Icons.backspace_outlined,
                    color: AppColors.text, size: 22.icon),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({this.label, this.child, required this.onTap})
      : assert(label != null || child != null);

  final String? label;
  final Widget? child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.icon,
      height: 72.icon,
      margin: EdgeInsets.symmetric(horizontal: 8.padding),
      child: Material(
        color: AppColors.glassyDark,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: child ??
                Text(
                  label!,
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 22.font,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
