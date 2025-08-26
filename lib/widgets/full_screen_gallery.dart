import 'package:flutter/material.dart';
import 'package:submee/widgets/network_image.dart';

class FullscreenGalleryModal extends StatefulWidget {
  const FullscreenGalleryModal({
    Key? key,
    required this.photos,
    required this.initialIndex,
  }) : super(key: key);
  final List<String> photos;
  final int initialIndex;

  @override
  State<FullscreenGalleryModal> createState() => _FullscreenGalleryModalState();
}

class _FullscreenGalleryModalState extends State<FullscreenGalleryModal> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withAlpha(90),
        child: Stack(
          children: [
            // Gallery
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) => InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: NetworkImageWithFallback.full(
                      imageUrl: widget.photos[index],
                    ),
                  ),
                ),
              ),
            ),

            // Counter and close button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1}/${widget.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
