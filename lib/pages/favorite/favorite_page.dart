import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/generated/l10n.dart';
import 'package:submee/providers/favorite_providers.dart';
import 'package:submee/widgets/input_search.dart';

import '../../models/property.dart';
import '../../widgets/favorite_item..dart';

class FavoritePage extends HookConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final properties = ref.watch(approvedPropertyRequestedProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final isSearchActive = useState<bool>(false);
    final filterProperties = useState<List<PropertyRequested>>([]);
    final locale = S.of(context);
    return Column(
      children: [
        InputSearch(
          onChanged: (value) {
            if (value.isEmpty) {
              isSearchActive.value = false;
              return;
            }

            isSearchActive.value = true;
            final filtered = properties.asData?.value
                    .where(
                      (element) => element.location.toLowerCase().contains(value.toLowerCase()),
                    )
                    .toList() ??
                [];
            filterProperties.value = filtered;
          },
        ),
        Expanded(
          child: RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              ref.invalidate(approvedPropertyRequestedProvider);
            },
            child: properties.when(
              data: (data) {
                // Show all properties when search is not active, otherwise show filtered properties
                final displayList = isSearchActive.value ? filterProperties.value : data;

                if (displayList.isEmpty) {
                  return Center(
                    child: Text(
                      locale.no_property_match_found,
                      style: TextStyle(color: primaryColor),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    itemCount: displayList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return FavoriteItem(
                        onTap: () {
                          if (item.conversationId != null) {
                            context.push('/chat/${item.conversationId}');
                            return;
                          }
                          context.push('/chat/new/${item.id}');
                        },
                        imageUrl: item.photos[0],
                        profileUrl: item.hostPhoto,
                        location: item.location,
                        name: item.hostFirstName + ' ' + item.hostLastName,
                      );
                    },
                  ),
                );
              },
              error: (error, stack) {
                return Center(child: Text('Error: $error'));
              },
              loading: () {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
