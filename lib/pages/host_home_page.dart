import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/widgets/main_swiper.dart';
import 'package:submee/widgets/sublet_detail_modal.dart';

import '../generated/l10n.dart';
import '../models/sublet.dart';
import '../providers/subletters_providers.dart';
import '../services/user_service.dart';
import '../utils/functions.dart';
import '../widgets/banners/modal_wrapper.dart';
import '../widgets/custom_svg_picture.dart';
import '../widgets/input_dropdown.dart';
import '../widgets/location_list_modal.dart';
import '../widgets/sublet_card.dart';

class HostHomePage extends HookConsumerWidget {
  const HostHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subletters = ref.watch(sublettersProvider);
    final locale = S.of(context);
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;
    final locationIds = ref.watch(subletFiltersProvider.select((value) => value.locationList));
    return Stack(
      children: [
        Container(
          color: primaryColor,
        ),
        Positioned(
          top: size.height * 0.35,
          child: Container(
            height: size.height,
            width: size.width,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InputDropdown(
                    onTap: () async {
                      showCustomModal(
                        context: context,
                        child: SizedBox(
                          height: size.height * 0.5,
                          width: double.infinity,
                          child: LocationListModal(
                            initialSelectedCityIds: locationIds,
                            onSelectedCities: (locationList) {
                              ref.read(subletFiltersProvider.notifier).updateFilters(
                                    locationList: locationList,
                                  );
                            },
                          ),
                        ),
                      );
                    },
                    label: locale.choose_location,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: size.width * 0.8,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(sublettersProvider);
                    },
                    child: subletters.when(
                      data: (data) {
                        if (data.sublets.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  getEmptyUsersTranslation(data.code, locale),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                // Refresh
                                GestureDetector(
                                  onTap: () {
                                    ref.invalidate(sublettersProvider);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: const Color(0xFFF4B73D), width: 2),
                                    ),
                                    child: const CustomSvgPicture(
                                      'assets/icons/swipe_refresh.svg',
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return MainSwiper<Sublet>(
                          items: data.sublets,
                          onRefresh: () {
                            ref.read(sublettersProvider.notifier).refresh();
                          },
                          onItemTap: (value) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, // Makes modal full-height scrollable
                              barrierColor: primaryColor,
                              builder: (context) => SubletDetailsModal(
                                id: value.id,
                                onClose: () => Navigator.pop(context),
                              ),
                            );
                          },
                          childBuilder: (next) => SubletCard(item: next),
                          onItemLike: (value) async {
                            await ref.read(userService).likeSublet(value.id);
                          },
                          onItemDislike: (value) async {
                            ref.read(userService).unlikeSublet(value.id);
                          },
                        );
                      },
                      error: (e, __) => Text(e.toString()),
                      loading: () => const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// If you need error handling for the profile imag
