import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';

class LockedSongImageList extends StatelessWidget {
  final List<String> images;

  const LockedSongImageList({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.maxHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 22.padding),
        itemCount: images.length,
        separatorBuilder: (context, index) => 12.row,
        itemBuilder: (context, index) {
          return Container(
            width: 360.maxWidth,
            height: 360.maxHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.radius),
              image: DecorationImage(
                image: AssetImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

