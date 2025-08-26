import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/generated/l10n.dart';
import 'package:submee/utils/enum.dart';

import '../../providers/property_publish_providers.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/publish_place_onboarding_content.dart';
import '../../widgets/publish_place_onboarding_date.dart';
import '../../widgets/publish_place_onboarding_details.dart';
import '../../widgets/publish_place_onboarding_location.dart';
import '../../widgets/publish_place_onboarding_photos.dart';
import '../../widgets/publish_place_onboarding_preview.dart';
import '../../widgets/publish_place_onboarding_style.dart';
import '../../widgets/publish_place_onboarding_success.dart';
import '../../widgets/publish_place_onboarding_title.dart';

class PublishPlaceOnboardingPage extends HookConsumerWidget {
  const PublishPlaceOnboardingPage(this.propertyId, {super.key});
  final int? propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    final buttonStyle = Theme.of(context).textButtonTheme.style;
    final buttonStyleElevated = Theme.of(context).elevatedButtonTheme.style;
    final primaryColor = Theme.of(context).primaryColor;
    final outlinedButtonStyle = Theme.of(context).outlinedButtonTheme.style;
    final allowContinue = ref.watch(allowContinueProvider(propertyId)).asData?.value ?? false;
    final propertyDataAsync = ref.watch(propertyDataProvider(propertyId));
    final transaction =
        propertyDataAsync.asData?.value.transactionStatus ?? TransactionStatus.idle;
    final notifier = ref.watch(propertyDataProvider(propertyId).notifier);
    final step = ref.watch(propertyDataProvider(propertyId)).asData?.value.step;

    return Container(
      color: primaryColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        padding: const EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: step == PropertyPublishOnboardingStep.placeType,
                  replacement: const SizedBox.shrink(),
                  child: InkWell(
                    child: const Icon(
                      Icons.chevron_left,
                      size: 22,
                      color: Colors.black,
                    ),
                    onTap: context.pop,
                  ),
                ),
                Text(
                  getTitle(step, locale),
                  style: textTheme.displayMedium,
                ),
                const SizedBox.shrink(),
              ],
            ),
            if (step != PropertyPublishOnboardingStep.success)
              const Divider(
                color: Color(0xFFE5E5E5),
                thickness: 1,
              ),
            Expanded(
              child: propertyDataAsync.when(
                data: (data) {
                  switch (data.step) {
                    case PropertyPublishOnboardingStep.placeType:
                      return PublishPlaceOnboardingContent(
                        data: data.propertyData.type,
                        selectedId: data.propertyPublishDetails.placeTypeId != null
                            ? [data.propertyPublishDetails.placeTypeId!]
                            : [],
                        title: locale.place_type_step,
                        onSelected: notifier.selectPropertyType,
                      );
                    case PropertyPublishOnboardingStep.placeLocation:
                      return PublishPlaceOnboardingLocation(
                        onLocationChange: notifier.onLocationChanged,
                        onAddressChange: notifier.onAddressChanged,
                        locationSelected: data.propertyPublishDetails.location,
                        addressSelected: data.propertyPublishDetails.address,
                        locations: data.propertyData.locations,
                      );
                    case PropertyPublishOnboardingStep.placeDetails:
                      return PublishPlaceOnboardingDetails(
                        onChange: notifier.selectPropertyBasics,
                        basicsSelected: data.propertyPublishDetails.basics,
                      );
                    case PropertyPublishOnboardingStep.placeAmenities:
                      return PublishPlaceOnboardingContent(
                        data: data.propertyData.amenities,
                        multiple: true,
                        selectedId: data.propertyPublishDetails.amenitiesId,
                        onSelected: notifier.selectAmenities,
                      );
                    case PropertyPublishOnboardingStep.placePhotos:
                      return PublishPlaceOnboardingPhotos(
                        onSelected: notifier.selectPhotos,
                        selected: data.propertyPublishDetails.photos,
                        currentPhotos: data.propertyPublishDetails.currentPhotos,
                      );
                    case PropertyPublishOnboardingStep.placeTitle:
                      return PublishPlaceOnboardingTitle(
                        onChange: notifier.onChangeTitle,
                        existingTitle: data.propertyPublishDetails.title,
                        existingDescription: data.propertyPublishDetails.description,
                      );
                    case PropertyPublishOnboardingStep.placeStyle:
                      return PublishPlaceOnboardingStyle(
                        onChangeExtras: notifier.onSelectedRules,
                        onChangeItems: notifier.onSelectedStyles,
                        itemsSelected: data.propertyPublishDetails.stylesId,
                        extraItemsSelected: data.propertyPublishDetails.rulesId,
                        extraTitle: locale.choose_what_is_allowed,
                        items: data.propertyData.styles,
                        extras: data.propertyData.rules,
                      );
                    case PropertyPublishOnboardingStep.placeDate:
                      return PublishPlaceOnboardingDate(
                        onDateRangeChanged: notifier.onDateRangeChanged,
                        onLastMinuteOffer: notifier.onLastMinuteOffer,
                        onPriceChanged: notifier.onPriceChanged,
                        lastMinuteOffer: data.propertyPublishDetails.lastMinuteEnabled,
                        price: data.propertyPublishDetails.price,
                        startDate: data.propertyPublishDetails.startDate,
                        endDate: data.propertyPublishDetails.endDate,
                      );
                    case PropertyPublishOnboardingStep.preview:
                      return PublishPlaceOnboardingPreview(
                        property: notifier.propertyReady,
                      );
                    case PropertyPublishOnboardingStep.success:
                      return PublishPlaceOnboardingSuccess(
                        property: notifier.propertyReady,
                      );
                  }
                },
                error: (e, __) => Text(e.toString()),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            SizedBox(
              height: 20,
              child: ProgressBars(
                currentProgress: step?.index ?? 0,
              ),
            ),
            if (step != PropertyPublishOnboardingStep.success)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IntrinsicWidth(
                      child: TextButton(
                        style: buttonStyle!.copyWith(
                          foregroundColor: WidgetStateProperty.all(
                            Colors.black,
                          ),
                        ),
                        onPressed: () {
                          if (step == PropertyPublishOnboardingStep.placeDate) {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          } else {
                            notifier.previousStep();
                          }
                        },
                        child: Text(locale.back_button),
                      ),
                    ),
                    IntrinsicWidth(
                      child: ElevatedButton(
                        style: buttonStyleElevated!.copyWith(
                          side: WidgetStateProperty.all(
                            const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            allowContinue
                                ? primaryColor
                                : const Color(0xFF828282).withValues(alpha: 0.5),
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          if (step == PropertyPublishOnboardingStep.preview) {
                            await notifier.publishProperty();
                          } else {
                            notifier.nextStep();
                          }
                        },
                        child: transaction == TransactionStatus.loading
                            ? const CircularProgressIndicator()
                            : Text(
                                step == PropertyPublishOnboardingStep.preview
                                    ? locale.publish_button
                                    : locale.next_button,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            if (step == PropertyPublishOnboardingStep.success)
              OutlinedButton(
                style: outlinedButtonStyle!.copyWith(
                  foregroundColor: WidgetStateProperty.all(
                    Colors.white,
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    primaryColor,
                  ),
                ),
                onPressed: () async {
                  context.go('/');
                },
                child: Text(
                  locale.continue_label,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String getTitle(PropertyPublishOnboardingStep? step, S locale) {
    switch (step) {
      case PropertyPublishOnboardingStep.placeType:
        return locale.place_type_step;
      case PropertyPublishOnboardingStep.placeLocation:
        return locale.place_location_step;
      case PropertyPublishOnboardingStep.placeDetails:
        return locale.place_basics_step;
      case PropertyPublishOnboardingStep.placeAmenities:
        return locale.place_amenities_step;
      case PropertyPublishOnboardingStep.placePhotos:
        return locale.place_photos_step;
      case PropertyPublishOnboardingStep.placeTitle:
        return locale.place_title_step;
      case PropertyPublishOnboardingStep.placeStyle:
        return locale.place_style_step;
      case PropertyPublishOnboardingStep.placeDate:
        return locale.place_dates_price_step;
      case PropertyPublishOnboardingStep.preview:
        return locale.place_publish_step;
      default:
        return '';
    }
  }
}
