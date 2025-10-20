import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class LyricsModal extends StatefulWidget {
  const LyricsModal({super.key});

  @override
  State<LyricsModal> createState() => _LyricsModalState();
}

class _LyricsModalState extends State<LyricsModal> {
  // Mock lyrics data
  final List<String> _lyrics = [
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
    "Lorem ipsum dolor sit amet consectetur.",
  ];

  int _currentLineIndex = 2; // Currently focused line (0-based index)
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Calculate which line should be focused based on scroll position
    final scrollOffset = _scrollController.offset;
    final itemHeight =
        50.0; // Approximate height of each lyric line with padding
    final newIndex = (scrollOffset / itemHeight).round();

    if (newIndex != _currentLineIndex &&
        newIndex >= 0 &&
        newIndex < _lyrics.length) {
      setState(() {
        _currentLineIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 380.maxWidth,
        height: 635.maxHeight,
        padding: EdgeInsets.only(
          left: 20.padding,
          right: 20.padding,
          top: 10.padding,
        ),
        decoration: BoxDecoration(
          color: AppColors.modalBackground.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Lyrics Content
            Expanded(child: _buildLyricsContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Lyrics',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 20.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        116.row,
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            width: 30.maxWidth,
            height: 30.maxHeight,
            decoration: BoxDecoration(
              color: AppColors.text.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, color: Colors.white, size: 16.icon),
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsContent() {
    return Padding(
      padding: EdgeInsets.only(top: 34.padding),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _lyrics.length,
        itemBuilder: (context, index) {
          final distance = (index - _currentLineIndex).abs();
          final isCurrentLine = index == _currentLineIndex;

          return Padding(
            padding: EdgeInsets.only(bottom: 16.padding),
            child: _buildLyricLine(
              text: _lyrics[index],
              isCurrentLine: isCurrentLine,
              distance: distance,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLyricLine({
    required String text,
    required bool isCurrentLine,
    required int distance,
  }) {
    // Calculate opacity based on distance from current line
    double opacity;

    if (isCurrentLine) {
      opacity = 1.0;
    } else if (distance == 1) {
      opacity = 0.6;
    } else if (distance == 2) {
      opacity = 0.3;
    } else if (distance == 3) {
      opacity = 0.15;
    } else {
      opacity = 0.05;
    }

    return Text(
      text,
      style: AppTextStyles.specialText.copyWith(
        color: Colors.white.withValues(alpha: opacity),
        fontSize: 20.font,
        fontWeight: FontWeight.w700,
        // height: 1.4,
      ),
      textAlign: TextAlign.left,
    );
  }
}
