import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../generated/l10n.dart';
import '../providers/sublet_providers.dart';
import '../utils/functions.dart';
import 'network_image.dart';

class SubletDetailsModal extends HookConsumerWidget {
  const SubletDetailsModal({
    required this.id,
    required this.onClose,
    super.key,
  });

  final int id;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final details = ref.watch(subletDetailProvider(id));
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final size = MediaQuery.sizeOf(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),

          // Content
          Expanded(
            child: details.when(
              data: (details) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main image container
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: size.height * 0.55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Photo carousel
                            PageView.builder(
                              itemCount: details.photos.length,
                              onPageChanged: (index) {
                                currentIndex.value = index;
                              },
                              itemBuilder: (context, index) => NetworkImageWithFallback.sublet(
                                imageUrl: details.photos[index],
                                width: double.infinity,
                              ),
                            ),

                            // Page indicators
                            if (details.photos.length > 1)
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    details.photos.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == currentIndex.value
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Profile section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Profile avatar
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: NetworkImageWithFallback.sublet(
                                imageUrl: details.photos.isNotEmpty ? details.photos[0] : '',
                                width: 60,
                                height: 60,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Profile info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${details.firstName} ${details.lastName}, ${getAgeFromDob(details.dob)}',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bio/Description
                    if (details.bio != null && details.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          details.bio!,
                          style: textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
