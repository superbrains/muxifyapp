import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// Bottom sheet that prompts the user for a playlist name. Returns the
/// trimmed name on confirm, `null` if dismissed.
class CreatePlaylistSheet extends StatefulWidget {
  const CreatePlaylistSheet({super.key, this.initialName, this.title});

  final String? initialName;
  final String? title;

  static Future<String?> show(
    BuildContext context, {
    String? initialName,
    String? title,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) =>
          CreatePlaylistSheet(initialName: initialName, title: title),
    );
  }

  @override
  State<CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<CreatePlaylistSheet> {
  late final TextEditingController _controller;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _canSubmit = _controller.text.trim().isNotEmpty;
    _controller.addListener(_recompute);
  }

  void _recompute() {
    final next = _controller.text.trim().isNotEmpty;
    if (next != _canSubmit) {
      setState(() => _canSubmit = next);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_recompute);
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.headerGradient.withValues(alpha: 0.45),
              AppColors.background,
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.radius)),
          border: Border(
            top: BorderSide(color: AppColors.text.withValues(alpha: 0.06)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24.padding,
              16.padding,
              24.padding,
              24.padding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44.maxWidth,
                    height: 4.maxHeight,
                    decoration: BoxDecoration(
                      color: AppColors.text.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4.radius),
                    ),
                  ),
                ),
                20.column,
                Text(
                  widget.title ?? 'Name your playlist',
                  style: AppTextStyles.heading2.copyWith(fontSize: 22.font),
                ),
                6.column,
                Text(
                  'Free songs and tracks you\'ve unlocked can be added.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.font,
                    color: AppColors.text.withValues(alpha: 0.62),
                  ),
                ),
                22.column,
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: AppColors.buttonColor,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 16.font),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'e.g. Workout Mix',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: AppColors.glassyDark.withValues(alpha: 0.7),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.padding,
                      vertical: 16.padding,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.radius),
                      borderSide: BorderSide(
                        color: AppColors.text.withValues(alpha: 0.06),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.radius),
                      borderSide: BorderSide(
                        color: AppColors.text.withValues(alpha: 0.06),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.radius),
                      borderSide: BorderSide(
                        color: AppColors.buttonColor.withValues(alpha: 0.55),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                24.column,
                SizedBox(
                  height: 52.buttonHeight,
                  child: FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      disabledBackgroundColor:
                          AppColors.buttonColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.radius),
                      ),
                    ),
                    child: Text(
                      widget.initialName == null ? 'Create playlist' : 'Save',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16.font),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
