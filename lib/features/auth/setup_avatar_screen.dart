import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/custom_button.dart';

class SetupAvatarScreen extends StatefulWidget {
  const SetupAvatarScreen({super.key});

  @override
  State<SetupAvatarScreen> createState() => _SetupAvatarScreenState();
}

class _SetupAvatarScreenState extends State<SetupAvatarScreen> {
  String _selectedGender = 'male';
  int? _selectedAvatarIndex;
  bool _isUploading = false;

  final List<String> _avatarAssets = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
    'assets/avatars/avatar_5.png',
    'assets/avatars/avatar_6.png',
    'assets/avatars/avatar_7.png',
    'assets/avatars/avatar_8.png',
    'assets/avatars/avatar_9.png',
  ];

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitle(),
                8.column,
                _buildSubtitle(),
                40.column,
                _buildGenderSelection(),
                55.column,
                _buildUploadButton(),
                43.column,
                _buildAvatarGrid(),
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

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGenderButton(
          'male',
          Icons.male,
          'Male',
          _selectedGender == 'male',
        ),
        16.row,
        _buildGenderButton(
          'female',
          Icons.female,
          'Female',
          _selectedGender == 'female',
        ),
      ],
    );
  }

  Widget _buildGenderButton(
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
          _selectedAvatarIndex =
              null; // Reset avatar selection when gender changes
        });
      },
      child: Container(
        width: 108.buttonHeight,
        height: 44.buttonHeight,
        // padding: EdgeInsets.symmetric(
        //   horizontal: 20.padding,
        //   vertical: 12.padding,
        // ),
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
            8.column,
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showImagePicker();
      },
      child: Container(
        height: 50.buttonHeight,
        width: 217.buttonHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(50.radius),
        ),
        child: Center(
          child: Text(
            'Upload Picture',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: _avatarAssets.length,
          itemBuilder: (context, index) {
            return _buildAvatarItem(index);
          },
        ),
      ],
    );
  }

  Widget _buildAvatarItem(int index) {
    final isSelected = _selectedAvatarIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedAvatarIndex = index;
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
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getAvatarBackgroundColor(index).withValues(alpha: 0.3),
                  _getAvatarBackgroundColor(index).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _getAvatarIcon(index),
                size: 40,
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarBackgroundColor(int index) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  IconData _getAvatarIcon(int index) {
    // Using different icons to represent different avatars
    final icons = [
      Icons.person,
      Icons.face,
      Icons.account_circle,
      Icons.person_outline,
      Icons.face_retouching_natural,
      Icons.person_pin,
      Icons.account_box,
      Icons.face_6,
      Icons.person_2,
    ];
    return icons[index % icons.length];
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedAvatarIndex != null || _isUploading;

    return CustomButton.signUp(
      text: 'Continue',
      width: double.infinity,
      onPressed: canContinue
          ? () {
              HapticFeedback.lightImpact();
              context.push(AppRouter.followFavourites);
            }
          : null,
    );
  }

  void _showImagePicker() {
    setState(() {
      _isUploading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        // Show success message or handle uploaded image
      }
    });
  }
}
