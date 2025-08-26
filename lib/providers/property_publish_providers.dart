import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/location.dart';
import 'package:submee/models/property_publish.dart';
import 'package:submee/services/config_service.dart';

import '../models/property.dart';
import '../services/property_service.dart';
import '../utils/enum.dart';

final allowContinueProvider = StreamProvider.autoDispose.family<bool, int?>((ref, id) {
  final notifier = ref.watch(propertyDataProvider(id).notifier);
  return notifier.allowContinueStream;
});

final propertyDataProvider =
    AsyncNotifierProvider.autoDispose.family<PropertyDataNotifier, PropertyPublishData, int?>(
  PropertyDataNotifier.new,
);

class PropertyDataNotifier extends AutoDisposeFamilyAsyncNotifier<PropertyPublishData, int?> {
  @override
  Future<PropertyPublishData> build(int? arg) async {
    final data = await ref.read(configService).getPropertyCreationData();
    if (arg == null) {
      return PropertyPublishData(
        propertyPublishDetails: PropertyPublishDetails(),
        propertyData: data,
      );
    }
    final propertyDetail = await ref.read(propertyService).getPropertyDetail(arg);
    final state = PropertyPublishData(
      propertyData: data,
      propertyId: arg,
      propertyPublishDetails: PropertyPublishDetails.fromPropertyDetails(propertyDetail),
    );
    _updateAllowContinue(state);
    return state;
  }

  final StreamController<bool> _allowContinueController = StreamController<bool>.broadcast();

  Stream<bool> get allowContinueStream => _allowContinueController.stream;

  void _updateAllowContinue([PropertyPublishData? state]) {
    _allowContinueController.add(allowContinue(state));
  }

  bool allowContinue([PropertyPublishData? value]) {
    final stateValue = value ?? state.value;
    if (stateValue == null) return false;

    final currentStep = stateValue.step;
    bool canContinue = false;
    final propertyState = stateValue.propertyPublishDetails;
    switch (currentStep) {
      case PropertyPublishOnboardingStep.placeType:
        canContinue = propertyState.placeTypeId != null;
        break;
      case PropertyPublishOnboardingStep.placeLocation:
        canContinue = propertyState.location != null && propertyState.address != null;
        break;
      case PropertyPublishOnboardingStep.placeDetails:
        canContinue = propertyState.basics.isValid;
        break;
      case PropertyPublishOnboardingStep.placeAmenities:
        canContinue = propertyState.amenitiesId.isNotEmpty;
        break;
      case PropertyPublishOnboardingStep.placePhotos:
        canContinue = propertyState.photos.isNotEmpty || propertyState.currentPhotos.isNotEmpty;
        break;
      case PropertyPublishOnboardingStep.placeTitle:
        canContinue = propertyState.title != null &&
            propertyState.description != null &&
            propertyState.title!.isNotEmpty &&
            propertyState.description!.isNotEmpty;
        break;
      case PropertyPublishOnboardingStep.placeStyle:
        canContinue = propertyState.stylesId.isNotEmpty || propertyState.rulesId.isNotEmpty;
        break;
      case PropertyPublishOnboardingStep.placeDate:
        canContinue = propertyState.startDate != null && propertyState.endDate != null;
        break;
      case PropertyPublishOnboardingStep.preview:
        canContinue = true;
        break;
      default:
        canContinue = false;
    }
    return canContinue;
  }

  void nextStep() {
    if (state.value == null) return;
    final currentStep = state.value!.step;
    final canContinue = allowContinue();
    PropertyPublishOnboardingStep step = state.value!.step;

    if (!canContinue) return;
    switch (currentStep) {
      case PropertyPublishOnboardingStep.placeDate:
        step = PropertyPublishOnboardingStep.placeType;
        break;
      case PropertyPublishOnboardingStep.placeType:
        step = PropertyPublishOnboardingStep.placeLocation;
        break;
      case PropertyPublishOnboardingStep.placeLocation:
        step = PropertyPublishOnboardingStep.placeDetails;
        break;
      case PropertyPublishOnboardingStep.placeDetails:
        step = PropertyPublishOnboardingStep.placeAmenities;
        break;
      case PropertyPublishOnboardingStep.placeAmenities:
        step = PropertyPublishOnboardingStep.placePhotos;
        break;
      case PropertyPublishOnboardingStep.placePhotos:
        step = PropertyPublishOnboardingStep.placeTitle;
        break;
      case PropertyPublishOnboardingStep.placeTitle:
        step = PropertyPublishOnboardingStep.placeStyle;
        break;
      case PropertyPublishOnboardingStep.placeStyle:
        step = PropertyPublishOnboardingStep.preview;
        break;
      case PropertyPublishOnboardingStep.preview:
        step = PropertyPublishOnboardingStep.success;
        break;
      default:
    }
    state = AsyncValue.data(
      state.value!.copyWith(
        step: step,
      ),
    );
    _updateAllowContinue();
  }

  void previousStep() {
    if (state.value == null) return;
    final currentStep = state.value!.step;
    PropertyPublishOnboardingStep step = state.value!.step;
    switch (currentStep) {
      case PropertyPublishOnboardingStep.placeDate:
        break;
      case PropertyPublishOnboardingStep.placeType:
        step = PropertyPublishOnboardingStep.placeDate;
        break;
      case PropertyPublishOnboardingStep.placeLocation:
        step = PropertyPublishOnboardingStep.placeType;
        break;
      case PropertyPublishOnboardingStep.placeDetails:
        step = PropertyPublishOnboardingStep.placeLocation;
        break;
      case PropertyPublishOnboardingStep.placeAmenities:
        step = PropertyPublishOnboardingStep.placeDetails;
        break;
      case PropertyPublishOnboardingStep.placePhotos:
        step = PropertyPublishOnboardingStep.placeAmenities;
        break;
      case PropertyPublishOnboardingStep.placeTitle:
        step = PropertyPublishOnboardingStep.placePhotos;
        break;
      case PropertyPublishOnboardingStep.placeStyle:
        step = PropertyPublishOnboardingStep.placeTitle;
        break;
      case PropertyPublishOnboardingStep.preview:
        step = PropertyPublishOnboardingStep.placeStyle;
        break;
      default:
    }
    state = AsyncValue.data(
      state.value!.copyWith(
        step: step,
      ),
    );
    _updateAllowContinue();
  }

  void updatePropertyPublishDetails(
    PropertyPublishDetails propertyPublishDetails,
  ) {
    state = AsyncValue.data(
      state.value!.copyWith(
        propertyPublishDetails: propertyPublishDetails,
      ),
    );
    _updateAllowContinue();
  }

  void selectPropertyType(List<int> ids) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(placeTypeId: ids.first);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onChangeTitle(String? title, String? description) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(title: title, description: description);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onSelectedStyles(List<int> ids) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(stylesId: ids);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onLocationChanged(LocationItem item) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(location: item);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onAddressChanged(String address) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(address: address);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onPriceChanged(double value) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(price: value);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onLastMinuteOffer(bool value) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(lastMinuteEnabled: value);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onDateRangeChanged(DateTime? start, DateTime? end) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    if (start == null || end == null) {
      propertyState = propertyState.copyWith(removeDates: true);
    } else {
      propertyState = propertyState.copyWith(startDate: start, endDate: end);
    }
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void onSelectedRules(List<int> ids) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(rulesId: ids);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void selectPropertyBasics(PropertyBasics value) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    final basics = propertyState.basics.copyWith(
      guests: value.guests,
      bedrooms: value.bedrooms,
      bathrooms: value.bathrooms,
      beds: value.beds,
      roommates: value.roommates,
      size: value.size,
    );
    propertyState = propertyState.copyWith(basics: basics);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void selectAmenities(List<int> ids) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(amenitiesId: ids);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  void selectPhotos(List<File> photos) {
    PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
    propertyState = propertyState.copyWith(photos: photos);
    updatePropertyPublishDetails(propertyState);
    _updateAllowContinue();
  }

  PropertyInput get propertyReady => PropertyInput(
        title: state.value!.propertyPublishDetails.title!,
        description: state.value!.propertyPublishDetails.description!,
        placeTypeId: state.value!.propertyPublishDetails.placeTypeId!,
        location: state.value!.propertyPublishDetails.location!,
        amenitiesId: state.value!.propertyPublishDetails.amenitiesId,
        stylesId: state.value!.propertyPublishDetails.stylesId,
        rulesId: state.value!.propertyPublishDetails.rulesId,
        basics: state.value!.propertyPublishDetails.basics,
        photos: state.value!.propertyPublishDetails.photos,
        currentPhotos: state.value!.propertyPublishDetails.currentPhotos,
        address: state.value!.propertyPublishDetails.address!,
        price: state.value!.propertyPublishDetails.price,
        startDate: state.value!.propertyPublishDetails.startDate!,
        endDate: state.value!.propertyPublishDetails.endDate!,
        lastMinuteOffer: state.value!.propertyPublishDetails.lastMinuteEnabled,
      );

  Future<void> publishProperty() async {
    try {
      if (state.value == null) return;
      final service = ref.read(propertyService);
      state = AsyncValue.data(
        state.value!.copyWith(
          transactionStatus: TransactionStatus.loading,
        ),
      );
      if (state.value!.propertyId != null) {
        await service.updateProperty(state.value!.propertyId!, propertyReady);
      } else {
        await service.publishProperty(propertyReady);
      }
      state = AsyncValue.data(
        state.value!.copyWith(
          transactionStatus: TransactionStatus.success,
        ),
      );
      nextStep();
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(
          transactionStatus: TransactionStatus.error,
        ),
      );
      rethrow;
    }
  }

  Future<void> getPropertyToUpdate(int id) async {
    try {
      final service = ref.read(propertyService);
      state = AsyncValue.data(
        state.value!.copyWith(
          transactionStatus: TransactionStatus.loading,
        ),
      );
      final property = await service.getPropertyDetail(id);
      PropertyPublishDetails propertyState = state.value!.propertyPublishDetails;
      propertyState = propertyState.copyWith(
        title: property.title,
        description: property.description,
        placeTypeId: property.placeTypeId,
        address: property.location.address,
        price: double.tryParse(property.price),
        startDate: property.dates[0].startDate,
        endDate: property.dates[0].endDate,
        location: LocationItem.fromPropertyLocation(property.location),
        lastMinuteEnabled: property.lastMinuteEnabled,
        currentPhotos: property.photos,
        amenitiesId: property.ammenities,
        rulesId: property.rules,
        stylesId: property.styles,
        basics: PropertyBasics(
          guests: property.guests,
          bedrooms: property.bedrooms,
          beds: property.beds,
          bathrooms: property.bathrooms,
          roommates: property.roommates,
          size: double.parse(property.size),
          parkingSpot: property.parkingSpot,
        ),
      );
      updatePropertyPublishDetails(propertyState);
      _updateAllowContinue();
      state = AsyncValue.data(
        state.value!.copyWith(
          transactionStatus: TransactionStatus.success,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(
          transactionStatus: TransactionStatus.error,
        ),
      );
      rethrow;
    }
  }
}
