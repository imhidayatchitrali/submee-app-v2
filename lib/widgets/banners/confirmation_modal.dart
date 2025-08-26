import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/generated/l10n.dart';

class ConfirmationModal extends HookWidget {
  const ConfirmationModal({
    Key? key,
    required this.title,
    this.body,
    this.confrimText,
    this.cancelText,
    this.onPressed,
  }) : super(key: key);
  final String title;
  final String? body;
  final String? confrimText;
  final String? cancelText;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final loading = useState(false);
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.displayMedium,
            ),
            if (body != null)
              Text(
                body!,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            Row(
              spacing: 14,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(cancelText ?? locale.no_button),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (onPressed != null) {
                        while (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        loading.value = true;
                        await onPressed!();
                        loading.value = false;
                      }
                    },
                    child: Text(confrimText ?? locale.yes_button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
