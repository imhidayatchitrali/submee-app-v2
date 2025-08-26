import 'package:flutter/material.dart';

class ModalWrapper extends StatelessWidget {
  const ModalWrapper({
    Key? key,
    required this.title,
    required this.child,
    this.onClose,
    required this.contentPadding,
    this.borderRadius = 16.0,
  }) : super(key: key);
  final String? title;
  final Widget child;
  final VoidCallback? onClose;
  final EdgeInsets contentPadding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IntrinsicHeight(
        // Makes the dialog as small as possible vertically
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Makes the column as small as possible
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              if (title != null)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(),
                          Text(
                            title!,
                            style: textTheme.labelLarge,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, size: 24),
                            onPressed: onClose ?? () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Divider line
                    const Divider(height: 16),
                  ],
                ),

              // Content area with the child widget
              Padding(
                padding: contentPadding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the modal easily
void showCustomModal({
  required BuildContext context,
  required Widget child,
  String? title,
  VoidCallback? onClose,
  bool barrierDismissible = true,
  EdgeInsets contentPadding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  double borderRadius = 16.0,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => ModalWrapper(
      title: title,
      onClose: onClose,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      child: child,
    ),
  );
}
