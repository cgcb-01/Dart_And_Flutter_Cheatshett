import 'package:flutter/material.dart';
import '../../utils/app-styles.dart';
import '../../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.all(padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppStyles.bodyStyle.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
