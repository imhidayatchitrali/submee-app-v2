import 'package:flutter/material.dart';

class ProgressBars extends StatelessWidget {
  const ProgressBars({
    super.key,
    required this.currentProgress,
  });
  final int currentProgress;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final progress = calculateProgress();
    return Row(
      children: [
        Expanded(child: _buildProgressBar(progress[0], primaryColor)),
        const SizedBox(width: 16), // Space between bars
        Expanded(child: _buildProgressBar(progress[1], primaryColor)),
        const SizedBox(width: 16), // Space between bars
        Expanded(child: _buildProgressBar(progress[2], primaryColor)),
      ],
    );
  }

  List<double> calculateProgress() {
    if (currentProgress <= 3) {
      return [currentProgress / 3, 0, 0];
    } else if (currentProgress <= 6) {
      return [1, (currentProgress - 3) / 3, 0];
    } else if (currentProgress <= 9) {
      return [1, 1, (currentProgress - 6) / 3];
    }
    return [1, 1, 1];
  }

  Widget _buildProgressBar(double progress, Color? primaryColor) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: currentProgress < 9 ? Colors.black : primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
