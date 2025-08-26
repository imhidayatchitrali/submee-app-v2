import 'package:flutter/material.dart';

class ConfirmationBanner extends StatelessWidget {
  const ConfirmationBanner({
    Key? key,
    required this.title,
    required this.body,
    required this.buttonText,
    this.onPressed,
  }) : super(key: key);
  final String title;
  final String body;
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.displayMedium,
            ),
            Text(
              body,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            FilledButton(
              onPressed: () {
                if (onPressed != null) {
                  onPressed!();
                  Navigator.of(context).pop();
                }
              },
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
