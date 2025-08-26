import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PublishPlaceOnboardingTitle extends HookWidget {
  const PublishPlaceOnboardingTitle({
    super.key,
    required this.onChange,
    required this.existingTitle,
    required this.existingDescription,
  });
  final Function(String?, String?) onChange;
  final String? existingTitle;
  final String? existingDescription;
  @override
  Widget build(BuildContext context) {
    final title = useState(existingTitle);
    final description = useState(existingDescription);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: SingleChildScrollView(
        child: Column(
          spacing: 26,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sublet caption title',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    maxLines: 3,
                    maxLength: 35,
                    initialValue: title.value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      counterText: '${title.value?.length ?? 0}/35',
                    ),
                    onChanged: (value) {
                      title.value = value;
                      onChange(title.value, description.value);
                    },
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sublet description',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    maxLength: 500,
                    maxLines: 5,
                    initialValue: description.value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      counterText: '${description.value?.length ?? 0}/500',
                    ),
                    onChanged: (value) {
                      description.value = value;
                      onChange(title.value, description.value);
                    },
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
