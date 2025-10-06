import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension AppSizes on num {
  Widget get column => SizedBox(height: toDouble().h);

  Widget get row => SizedBox(width: toDouble().w);

  double get padding => toDouble().w;

  double get margin => toDouble().w;

  double get radius => toDouble().r;

  double get icon => toDouble().sp;

  double get font => toDouble().sp;

  double get elevation => toDouble().h;

  double get border => toDouble().w;

  double get buttonHeight => toDouble().h;

  double get appBarHeight => toDouble().h;

  double get bottomNavHeight => toDouble().h;

  double get maxWidth => toDouble().w;
}
