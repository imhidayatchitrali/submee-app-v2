import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/widgets/custom_back_button.dart';

import '../../theme/app_theme.dart';
import '../../widgets/photo_placeholder.dart';

class AddYourPhotosPage extends HookWidget {
  const AddYourPhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mainGradient),
        padding: AppTheme.screenPadding,
        child: Column(
          spacing: 18,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.05),
            const CustomBackButton(),
            Text(
              'Add your photos',
              style: textTheme.displayMedium!,
            ),
            Row(
              spacing: 11,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhotoPlaceholder(
                  size: size.width * 0.25,
                ),
                PhotoPlaceholder(
                  size: size.width * 0.25,
                ),
                PhotoPlaceholder(
                  size: size.width * 0.25,
                ),
              ],
            ),
            Row(
              spacing: 11,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhotoPlaceholder(
                  size: size.width * 0.25,
                ),
                PhotoPlaceholder(
                  size: size.width * 0.25,
                ),
                PhotoPlaceholder(
                  size: size.width * 0.25,
                ),
              ],
            ),
            Row(
              spacing: 12,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: const Color(0xFFB0B0B0),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('0/6'),
                ),
                Expanded(
                  child: Text(
                    'Hey! Add 2 photos of yourself to start',
                    style: textTheme.bodyLarge!.copyWith(
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {},
              child: isLoading.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
