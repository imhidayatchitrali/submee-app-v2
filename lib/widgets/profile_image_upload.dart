import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import '../generated/l10n.dart';
import 'custom_svg_picture.dart';

class ProfileImageUpload extends HookWidget {
  const ProfileImageUpload({
    super.key,
    required this.onImageSelected,
    this.imageUrl,
  });
  final Function(File) onImageSelected;
  final String? imageUrl;

  Future<void> _selectImage(
    BuildContext context,
    Function(File) onImageSelected,
    File? imageFile,
  ) async {
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context, ImageSource.gallery),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    const Icon(
                      Icons.photo,
                      size: 23,
                    ),
                    Text(
                      locale.upload_a_photo,
                      style: textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              height: 30,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context, ImageSource.camera),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 23,
                    ),
                    Text(
                      locale.take_a_photo,
                      style: textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        final XFile? image = await ImagePicker().pickImage(
          source: result,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if (image != null) {
          final file = File(image.path);
          onImageSelected(file);
        }
      } catch (e) {
        // Handle error
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = useState<File?>(null);
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () {
        void handleImageSelected(File image) {
          imageFile.value = image;
          onImageSelected(image);
        }

        _selectImage(context, handleImageSelected, imageFile.value);
      },
      child: Container(
        width: 145,
        height: 145,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          image: imageFile.value != null
              ? DecorationImage(
                  image: FileImage(imageFile.value!),
                  fit: BoxFit.cover,
                )
              : imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
        ),
        child: Visibility(
          visible: imageFile.value == null && imageUrl == null,
          replacement: const SizedBox.shrink(),
          child: const Center(
            child: CustomSvgPicture(
              'assets/icons/upload-picture.svg',
              height: 50,
            ),
          ),
        ),
      ),
    );
  }
}
