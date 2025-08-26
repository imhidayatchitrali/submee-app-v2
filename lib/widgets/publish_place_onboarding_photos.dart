import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import 'custom_svg_picture.dart';
import 'photo_gallery.dart';

class PublishPlaceOnboardingPhotos extends HookWidget {
  const PublishPlaceOnboardingPhotos({
    super.key,
    required this.onSelected,
    required this.selected,
    required this.currentPhotos,
  });
  final Function(List<File>) onSelected;
  final List<File> selected;
  final List<String> currentPhotos;
  @override
  Widget build(BuildContext context) {
    final filesSelected = useState<List<File>>(selected);
    return Container(
      padding: const EdgeInsets.only(top: 24),
      child: SingleChildScrollView(
        child: Column(
          spacing: 22,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await ImagePicker().pickMultiImage(
                  imageQuality: 50,
                  limit: 7 - filesSelected.value.length,
                );
                if (result.isNotEmpty) {
                  final files = result.map((e) => File(e.path)).toList();
                  filesSelected.value = [...filesSelected.value, ...files];
                  onSelected([...files]);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF323232).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomSvgPicture('assets/icons/add.svg'),
                    SizedBox(height: 8),
                    Text(
                      'Add photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filesSelected.value.isNotEmpty || currentPhotos.isNotEmpty)
              PhotoGallery(
                images: filesSelected.value,
                currentImages: currentPhotos,
                onDeleteFileImage: (index) {
                  filesSelected.value.removeAt(index);
                  onSelected([...filesSelected.value]);
                },
                onDeleteCurrentImage: (index) {
                  currentPhotos.removeAt(index);
                  onSelected([...filesSelected.value]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
