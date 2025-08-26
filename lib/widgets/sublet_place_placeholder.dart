import 'package:flutter/material.dart';
import 'package:submee/models/property.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

import '../generated/l10n.dart';
import 'network_image.dart';

class SubletPlacePlaceholder extends StatefulWidget {
  const SubletPlacePlaceholder({
    super.key,
    this.item,
    this.onEdit,
    this.onDelete,
  });

  final PropertyDisplay? item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<SubletPlacePlaceholder> createState() => _SubletPlacePlaceholderState();
}

class _SubletPlacePlaceholderState extends State<SubletPlacePlaceholder> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showOptionsMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOptionsMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent background to detect taps outside
          GestureDetector(
            onTap: _hideOptionsMenu,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Options menu
          Positioned(
            width: 120,
            child: CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(-5, 5),
              child: Material(
                elevation: 8,
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOption(
                      icon: 'edit',
                      text: S.current.edit,
                      onTap: () {
                        _hideOptionsMenu();
                        widget.onEdit?.call();
                      },
                    ),
                    _buildOption(
                      icon: 'delete',
                      text: S.current.delete,
                      onTap: () {
                        _hideOptionsMenu();
                        widget.onDelete?.call();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        child: Row(
          spacing: 10,
          children: [
            CustomSvgPicture(
              'assets/icons/$icon.svg',
              height: 20,
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideOptionsMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.item == null,
      replacement: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 20),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Property image container to maintain consistent size
            Container(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetworkImageWithFallback.property(
                  imageUrl: widget.item?.photos.isNotEmpty == true ? widget.item?.photos[0] : null,
                  isCircle: false,
                  size: double.infinity,
                ),
              ),
            ),
            // Dark overlay for title and location
            Container(
              width: double.infinity,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.black54, // Dark gray with opacity
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Property title
                  Text(
                    widget.item?.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Property location
                  Text(
                    widget.item?.location ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.item != null)
              Positioned(
                top: 10,
                right: 10,
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    onTap: _showOptionsMenu,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      child: Container(
        height: 150,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E9EA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const CustomSvgPicture(
          'assets/icons/sublet_placeholder.svg',
        ),
      ),
    );
  }
}
