import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/utils/api_exception.dart';
import 'package:submee/utils/enum.dart';

import '../services/onboarding_service.dart';
import '../utils/validators.dart';

final onboardingProvider = StateNotifierProvider<OnboardingProvider, OnboardingState>(
  (ref) {
    final onboarding = ref.read(onboardingService);
    return OnboardingProvider(onboarding);
  },
);

class OnboardingProvider extends StateNotifier<OnboardingState> {
  OnboardingProvider(
    this.service,
  ) : super(OnboardingState());
  final OnboardingService service;

  Future<void> submitPersonalDetails() async {
    try {
      state = state.copyWith(isLoading: true);

      // Validate all required fields
      if (!_validatePersonalDetails()) {
        state = state.copyWith(
          isLoading: false,
        );
      }

      await service.submitPersonalDetails(
        firstName: state.firstName,
        lastName: state.lastName,
        email: state.email,
        dateOfBirth: state.dob,
        password: state.password,
      );

      // Move to next step
      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.phoneVerification,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
      );
      throw e.code;
    }
  }

  bool _validatePersonalDetails() {
    return state.firstName.isNotEmpty &&
        state.lastName.isNotEmpty &&
        state.email.isNotEmpty &&
        state.dob.isNotEmpty &&
        state.password.isNotEmpty;
  }

  void setCountry(String code, String dialCode) {
    state = state.copyWith(countryCode: code, dialCode: dialCode);
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  Future<void> sendCode(String phoneNumber) async {
    if (state.dialCode.isEmpty) {
      return;
    }
    state = state.copyWith(
      phoneNumber: phoneNumber,
      onboardingTransactionStatus: OnboardingTransactionStatus.waitingForOTP,
    );
    await service.sendValidationCode(state.dialCode, phoneNumber);
  }

  Future<void> sendEmailCode() async {
    if (!state.emailValid) {
      return;
    }
    try {
      state = state.copyWith(
        isLoading: true,
      );
      await service.sendEmailValidationCode(state.email);
    } finally {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> submitUserPhotos(List<File> images) async {
    try {
      state = state.copyWith(isLoading: true);
      await service.submitUserPhotos(images);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> verifyCode(String otpCode) async {
    try {
      state = state.copyWith(
        onboardingTransactionStatus: OnboardingTransactionStatus.verifyingOTP,
        isLoading: true,
      );
      await service.verifyCode(state.dialCode, state.phoneNumber, otpCode);
    } on ApiException catch (e) {
      throw e.code;
    } finally {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

// TODO(krupikivan): Remove this when Twilio is implemented
  Future<void> mockCodeVerification(String phoneNumber) async {
    try {
      const String mockCode = '000222444666';
      if (state.dialCode.isEmpty) {
        return;
      }
      state = state.copyWith(
        phoneNumber: phoneNumber,
        isLoading: true,
      );
      await service.sendValidationCode(state.dialCode, phoneNumber);
      await service.verifyCode(state.dialCode, phoneNumber, mockCode);
    } on ApiException catch (e) {
      throw e.code;
    } finally {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> verifyEmailCode(String otpCode) async {
    try {
      await service.verifyEmailCode(state.email, otpCode);
      state = state.copyWith(
        emailVerified: true,
      );
    } on ApiException catch (_) {
      rethrow;
    }
  }

  void setFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void setLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setDob(String value) {
    state = state.copyWith(dob: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void reset() {
    state = OnboardingState();
  }
}

class OnboardingState {
  OnboardingState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.dob = '',
    this.password = '',
    this.phoneNumber = '',
    this.countryCode = '',
    this.dialCode = '',
    this.currentStep = OnboardingStep.personalInfo,
    this.isLoading = false,
    this.onboardingTransactionStatus = OnboardingTransactionStatus.started,
    this.emailVerified = false,
    this.error,
  });
  final String firstName;
  final String lastName;
  final String email;
  final String dob;
  final String password;
  final String phoneNumber;
  final String countryCode;
  final String dialCode;
  final OnboardingStep currentStep;
  final bool isLoading;
  final OnboardingTransactionStatus onboardingTransactionStatus;
  final String? error;
  final bool emailVerified;

  OnboardingState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? dob,
    String? password,
    String? phoneNumber,
    String? countryCode,
    String? dialCode,
    OnboardingStep? currentStep,
    bool? isLoading,
    bool? emailVerified,
    OnboardingTransactionStatus? onboardingTransactionStatus,
  }) {
    return OnboardingState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      emailVerified: emailVerified ?? this.emailVerified,
      onboardingTransactionStatus: onboardingTransactionStatus ?? this.onboardingTransactionStatus,
    );
  }

  bool get personalDetailsFilled =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      dob.isNotEmpty &&
      password.isNotEmpty;

  bool get emailValid => validateEmail(email) == null;

  bool get showOTP =>
      onboardingTransactionStatus == OnboardingTransactionStatus.waitingForOTP ||
      onboardingTransactionStatus == OnboardingTransactionStatus.verifyingOTP;
}
