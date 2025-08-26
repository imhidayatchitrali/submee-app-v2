import 'package:flutter/material.dart';
import 'package:submee/models/property.dart';

import 'property_content_grid_widget.dart';

class PublishPlaceOnboardingContent extends StatelessWidget {
  const PublishPlaceOnboardingContent({
    super.key,
    required this.data,
    required this.onSelected,
    required this.selectedId,
    this.title,
    this.multiple = false,
  });
  final List<PropertyItem> data;
  final Function(List<int>) onSelected;
  final String? title;
  final bool multiple;
  final List<int> selectedId;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: textTheme.bodyLarge,
          ),
        Expanded(
          child: PropertyContentGridWidget(
            selectedId: selectedId,
            data: data,
            multiple: multiple,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}
