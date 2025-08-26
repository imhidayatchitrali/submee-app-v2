import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class MainSwiper<T> extends HookConsumerWidget {
  const MainSwiper({
    required this.items,
    required this.onItemTap,
    required this.childBuilder,
    required this.onItemLike,
    required this.onItemDislike,
    required this.onRefresh,
    super.key,
  });
  final List<T> items;
  final Function(T) onItemTap;
  final Widget Function(T next) childBuilder;
  final Function(T) onItemLike;
  final Function(T) onItemDislike;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final currentIndex = useState(0);
    final dragOffset = useState(0.0);
    final totalDrag = useState(0.0);
    final animationController =
        useAnimationController(duration: const Duration(milliseconds: 300));

    final T? next = currentIndex.value < items.length - 1 ? items[currentIndex.value + 1] : null;

    Future<void> _handleSwipe(bool isLike) async {
      // Cancel any ongoing drag animation
      animationController.reset();

      // Set the final position for the animation
      final endPosition =
          isLike ? MediaQuery.of(context).size.width : -MediaQuery.of(context).size.width;

      // Start the animation
      animationController.forward().then((_) {
        // After animation completes, move to next card
        currentIndex.value++;
        // Reset position for the next card
        dragOffset.value = 0;
        totalDrag.value = 0;
      });

      // Update the dragOffset during the animation
      animationController.addListener(() {
        dragOffset.value = endPosition * animationController.value;
        totalDrag.value = dragOffset.value;
      });
      if (isLike) {
        onItemLike(items[currentIndex.value]);
      } else {
        onItemDislike(items[currentIndex.value]);
      }
    }

    return Column(
      spacing: 20,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Next card (positioned behind current card)
            if (next != null)
              Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, 20.0, -10.0) // Slightly down and behind
                  ..scale(0.95), // Slightly smaller
                child: childBuilder(next),
              ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                totalDrag.value += details.delta.dx;
                dragOffset.value = totalDrag.value;
              },
              onTap: () => onItemTap(items[currentIndex.value]),
              onHorizontalDragEnd: (details) {
                if (dragOffset.value.abs() > 100) {
                  if (dragOffset.value > 0) {
                    onItemLike(items[currentIndex.value]);
                  } else {
                    onItemDislike(items[currentIndex.value]);
                  }
                  currentIndex.value++;
                }
                dragOffset.value = 0;
                totalDrag.value = 0;
              },
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(dragOffset.value)
                      ..rotateZ(dragOffset.value / 1000),
                    child: Stack(
                      children: [
                        if (currentIndex.value < items.length)
                          childBuilder(items[currentIndex.value]),
                        if (dragOffset.value != 0)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: dragOffset.value > 0
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  end: dragOffset.value > 0
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  colors: [
                                    if (dragOffset.value > 0)
                                      primaryColor.withValues(alpha: 0.3)
                                    else
                                      Colors.red.withValues(alpha: 0.3),
                                    if (dragOffset.value > 0)
                                      primaryColor.withValues(alpha: 0.3)
                                    else
                                      Colors.red.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (dragOffset.value > 0)
              Positioned(
                top: 200,
                child: CustomSvgPicture(
                  'assets/icons/swipe_like.svg',
                  color: primaryColor,
                  height: 150,
                ),
              ),
            if (dragOffset.value < 0)
              const Positioned(
                top: 200,
                child: CustomSvgPicture('assets/icons/swipe_dislike.svg', height: 150),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment:
                items.isNotEmpty ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: [
              if (items.isNotEmpty)
                GestureDetector(
                  onTap: () => _handleSwipe(false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const CustomSvgPicture(
                      'assets/icons/swipe_dislike.svg',
                      height: 25,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFF4B73D), width: 2),
                  ),
                  child: const CustomSvgPicture(
                    'assets/icons/swipe_refresh.svg',
                    height: 15,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                GestureDetector(
                  onTap: () => _handleSwipe(true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: CustomSvgPicture(
                      'assets/icons/swipe_like.svg',
                      color: primaryColor,
                      height: 25,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
