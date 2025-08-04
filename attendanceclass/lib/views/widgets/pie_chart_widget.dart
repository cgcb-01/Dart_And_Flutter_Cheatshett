import 'package:flutter/material.dart';
import '../../utils/app-styles.dart';
import '../../utils/app_colors.dart';

class PieChartWidget extends StatelessWidget {
  final double percentage;
  final String subjectName;
  final int attended;
  final int total;

  const PieChartWidget({
    super.key,
    required this.percentage,
    required this.subjectName,
    required this.attended,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      percentage >= 75
                          ? AppColors.presentColor
                          : percentage >= 60
                          ? Colors.orange
                          : AppColors.absentColor,
                    ),
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subjectName,
              style: AppStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('$attended/$total', style: AppStyles.smallStyle),
          ],
        ),
      ),
    );
  }
}
