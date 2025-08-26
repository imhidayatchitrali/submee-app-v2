import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/generated/l10n.dart';
import 'package:submee/widgets/custom_svg_picture.dart';
import 'package:submee/widgets/input_dropdown.dart';
import 'package:submee/widgets/price_range_slider.dart';

import '../models/property.dart';
import '../providers/property_providers.dart';
import '../services/property_service.dart';
import '../widgets/banners/modal_wrapper.dart';
import '../widgets/filter_calendar_widget.dart';
import '../widgets/filter_option_button.dart';
import '../widgets/location_list_modal.dart';
import '../widgets/main_swiper.dart';
import '../widgets/property_card_widget.dart';
import '../widgets/property_detail_modal.dart';
import '../widgets/property_filters_modal.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final properties = ref.watch(propertiesProvider);
    final filters = ref.watch(propertyFiltersProvider);
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;
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
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(propertiesProvider);
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: InputDropdown(
                    onTap: () async {
                      showCustomModal(
                        context: context,
                        child: SizedBox(
                          height: size.height * 0.5,
                          width: double.infinity,
                          child: LocationListModal(
                            initialSelectedCityIds: filters.locationList,
                            onSelectedCities: (locationList) {
                              ref.read(propertyFiltersProvider.notifier).updateFilters(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                  child: Row(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FilterOptionButton(
                          asset: 'calendar',
                          text: locale.date_label,
                          onRemovePressed: () {
                            ref.read(propertyFiltersProvider.notifier).updateFilters(
                                  startDate: null,
                                  endDate: null,
                                  deleteDates: true,
                                );
                          },
                          activeLabel: filters.dateLabel,
                          onPressed: () {
                            showCustomModal(
                              context: context,
                              title: locale.date_label,
                              child: SizedBox(
                                height: size.height * 0.5,
                                width: double.infinity,
                                child: FilterCalendarWidget(
                                  onReset: () {
                                    ref.read(propertyFiltersProvider.notifier).updateFilters(
                                          startDate: null,
                                          endDate: null,
                                          deleteDates: true,
                                        );
                                  },
                                  onDateSelected: (start, end) {
                                    ref.read(propertyFiltersProvider.notifier).updateFilters(
                                          startDate: start,
                                          endDate: end,
                                        );
                                  },
                                  initialStartDate: filters.startDate,
                                  initialEndDate: filters.endDate,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: FilterOptionButton(
                          text: locale.price_label,
                          asset: 'prime_dollar',
                          onRemovePressed: () {
                            ref.read(propertyFiltersProvider.notifier).updateFilters(
                                  minPrice: null,
                                  maxPrice: null,
                                  deletePrices: true,
                                );
                          },
                          activeLabel: filters.priceLabel,
                          onPressed: () {
                            showCustomModal(
                              context: context,
                              child: SizedBox(
                                width: double.infinity,
                                child: PriceRangeSliderWidget(
                                  onChanged: (p0, p1) {
                                    ref.read(propertyFiltersProvider.notifier).updateFilters(
                                          minPrice: p0,
                                          maxPrice: p1,
                                        );
                                  },
                                  start: filters.minPrice,
                                  end: filters.maxPrice,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showCustomModal(
                            title: locale.filter_button,
                            context: context,
                            child: PropertyFilterModal(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: filters.isEmpty ? null : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white),
                          ),
                          child: CustomSvgPicture(
                            'assets/icons/sliders.svg',
                            color: filters.isEmpty ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.8,
                  child: properties.when(
                    data: (data) {
                      return MainSwiper<Property>(
                        items: data,
                        onRefresh: () async {
                          ref.invalidate(propertiesProvider);
                        },
                        onItemTap: (value) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Makes modal full-height scrollable
                            barrierColor: primaryColor,
                            builder: (context) => PropertyDetailsModal(
                              id: value.id,
                              onClose: () => Navigator.pop(context),
                            ),
                          );
                        },
                        childBuilder: (next) => PropertyCard(property: next),
                        onItemLike: (value) async {
                          await ref.read(propertyService).likeProperty(value.id);
                        },
                        onItemDislike: (value) async {
                          ref.read(propertyService).unlikeProperty(value.id);
                        },
                      );
                    },
                    error: (e, __) => Text(e.toString()),
                    loading: () => const Center(child: CircularProgressIndicator()),
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
