import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';

class FollowFavouritesScreen extends StatefulWidget {
  const FollowFavouritesScreen({super.key});

  @override
  State<FollowFavouritesScreen> createState() => _FollowFavouritesScreenState();
}

class _FollowFavouritesScreenState extends State<FollowFavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedArtists = {};

  final List<Map<String, String>> _artists = [
    {'name': 'Davido', 'image': 'assets/artists/davido.png'},
    {'name': 'Wizkid', 'image': 'assets/artists/wizkid.png'},
    {'name': 'Burna Boy', 'image': 'assets/artists/burna_boy.png'},
    {'name': 'Mr Funny (Sabinus)', 'image': 'assets/artists/mr_funny.png'},
    {'name': 'Flavour', 'image': 'assets/artists/flavour.png'},
    {'name': 'Rema', 'image': 'assets/artists/rema.png'},
    {'name': 'Phyno', 'image': 'assets/artists/phyno.png'},
    {'name': 'Omah Lay', 'image': 'assets/artists/omah_lay.png'},
    {'name': 'Soso', 'image': 'assets/artists/soso.png'},
    {'name': 'Lord Lamba', 'image': 'assets/artists/lord_lamba.png'},
    {'name': 'Olamide', 'image': 'assets/artists/olamide.png'},
    {'name': 'Kiekie', 'image': 'assets/artists/kiekie.png'},
  ];

  List<Map<String, String>> get _filteredArtists {
    if (_searchController.text.isEmpty) {
      return _artists;
    }
    return _artists
        .where(
          (artist) => artist['name']!.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
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
                _buildSearchBar(),
                32.column,
                _buildArtistsGrid(),
                32.column,
                _buildCompleteButton(),
                32.column,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Follow your favourites',
      style: AppTextStyles.heading2.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Be the first to access their contents before anyone',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.text.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomInputField(
      controller: _searchController,
      hintText: 'Search Artist & Creators',
      borderRadius: 50.radius,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.padding,
        vertical: 18.padding,
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildArtistsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredArtists.length,
      itemBuilder: (context, index) {
        final artist = _filteredArtists[index];
        return _buildArtistItem(artist);
      },
    );
  }

  Widget _buildArtistItem(Map<String, String> artist) {
    final isSelected = _selectedArtists.contains(artist['name']);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (isSelected) {
            _selectedArtists.remove(artist['name']);
          } else {
            _selectedArtists.add(artist['name']!);
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.buttonColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getArtistColor(artist['name']!).withValues(alpha: 0.3),
                      _getArtistColor(artist['name']!).withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.text.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          8.column,
          Text(
            artist['name']!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getArtistColor(String artistName) {
    // Generate consistent colors for each artist
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
    ];

    int hash = artistName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Widget _buildCompleteButton() {
    return CustomButton.signUp(
      text: 'Complete',
      width: double.infinity,
      onPressed: () {
        HapticFeedback.lightImpact();
        context.push(AppRouter.congratulations);
      },
    );
  }
}
