import 'dart:io';

import 'package:flutter/material.dart';

import 'network_image.dart';

class PhotoGallery extends StatelessWidget {
  const PhotoGallery({
    super.key,
    required this.images,
    this.currentImages = const [],
    this.onDeleteCurrentImage,
    this.onDeleteFileImage,
  });

  /// List of File objects (for new images)
  final List<File> images;

  /// List of String URLs (for existing images)
  final List<String> currentImages;

  /// Callback when deleting a current image (URL)
  final void Function(int index)? onDeleteCurrentImage;

  /// Callback when deleting a file image
  final void Function(int index)? onDeleteFileImage;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Combine all images (both File and String)
    final allImages = [...currentImages, ...images.map((file) => file.path)];

    if (allImages.isEmpty) {
      return const Center(child: Text('No images available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: size.height * 0.25,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildCoverPhoto(allImages[0]),
          ),
          if (allImages.length > 1)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: allImages.length - 1,
              itemBuilder: (context, index) {
                // Adjust index to account for cover photo
                final actualIndex = index + 1;
                return _buildPhotoCard(allImages[actualIndex], actualIndex);
              },
            ),
        ],
      ),
    );
  }

  /// Builds the cover photo widget that can handle both File and String
  Widget _buildCoverPhoto(String imageSource, {int originalIndex = 0}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImage(
              imageSource,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Cover photo',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _handleDelete(originalIndex),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a photo card that can handle both File and String
  Widget _buildPhotoCard(String imageSource, int originalIndex) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImage(
              imageSource,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _handleDelete(originalIndex),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the delete action
  void _handleDelete(int combinedIndex) {
    // If the index is within currentImages, it's a URL image
    if (combinedIndex < currentImages.length) {
      onDeleteCurrentImage?.call(combinedIndex);
    }
    // Otherwise, it's a File image
    else {
      final fileIndex = combinedIndex - currentImages.length;
      onDeleteFileImage?.call(fileIndex);
    }
  }

  /// Helper method to build the appropriate image widget based on the source
  Widget _buildImage(
    String imageSource, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    // Check if it's a URL (starts with http/https)
    if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
      return NetworkImageWithFallback.full(
        imageUrl: imageSource,
      );
    }
    // Otherwise, it's a local file path
    else {
      final file = File(imageSource);
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.grey),
        ),
      );
    }
  }
}
