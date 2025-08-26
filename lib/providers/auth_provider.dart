import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/user.dart';
import 'package:submee/providers/onboarding_provider.dart';
import 'package:submee/providers/property_providers.dart';
import 'package:submee/providers/state_providers.dart';
import 'package:submee/providers/theme_provider.dart';
import 'package:submee/services/notification_service.dart';
import 'package:submee/utils/enum.dart';
import 'package:submee/utils/preferences.dart';

import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import '../utils/api_exception.dart';

final authProvider = Provider<AuthProvider>((ref) {
  final auth = ref.watch(authService);
  final user = ref.watch(userService);
  final notification = ref.watch(notificationServiceProvider);
  final service = AuthProvider(
    authService: auth,
    userService: user,
    notificationService: notification,
    ref: ref,
  );
  service.checkAuthentication();
  return service;
});

class AuthProvider implements Listenable {
  AuthProvider({
    required this.authService,
    required this.userService,
    required this.notificationService,
    required this.ref,
  }) : authStatus = AuthStatus.initial;
  final AuthService authService;
  final UserService userService;
  final NotificationService notificationService;
  final Ref ref;

  VoidCallback? _routerListener;

  late AuthStatus authStatus;
  User? user;
  void _updateState(AuthStatus newState) {
    authStatus = newState;
    _routerListener?.call();
  }

  Future<void> checkAuthentication() async {
    try {
      _updateState(AuthStatus.authenticating);
      final hasOnboarding = Preferences.hasGetStarted();
      if (!hasOnboarding) {
        _updateState(AuthStatus.getStarted);
        return;
      }
      final token = Preferences.getToken();
      if (token == null) {
        _updateState(AuthStatus.unauthenticated);
        return;
      }
      authService.saveAuthToken(token);
      await retrieveUser();
      checkOnboardingStep(user!);
      if (authStatus == AuthStatus.authenticated) {
        ref.invalidate(propertiesProvider);
        await notificationService.setupNotifications();
        final location = await ref.read(locationService).getLocation();
        if (location != null) {
          userService.updateUser(
            location: location,
          );
        }
      }
    } catch (e) {
      _updateState(AuthStatus.unauthenticated);
      await signOut();
    }
  }

  Future<void> retrieveUser() async {
    try {
      final response = await userService.getUser();
      user = response;
      Preferences.setUserId(user!.id);
      ref.read(localeProvider.notifier).state = Locale(user!.language);
    } catch (e) {
      _updateState(AuthStatus.unauthenticated);
      await signOut();
    }
  }

  void checkOnboardingStep(User user) {
    switch (user.onboardingStep) {
      case OnboardingStep.personalInfo:
        _updateState(AuthStatus.onboardingPersonalInfo);
        break;
      case OnboardingStep.phoneVerification:
        _updateState(AuthStatus.onboardingPhoneVerification);
        break;
      case OnboardingStep.photoUpload:
        _updateState(AuthStatus.onboardingPhotoUpload);
        break;
      case OnboardingStep.showCompleted:
      case OnboardingStep.completed:
        _updateState(AuthStatus.authenticated);
        break;
    }
  }

  void moveOnboardingNextStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.personalInfo:
        _updateState(AuthStatus.onboardingPersonalInfo);
        break;
      case OnboardingStep.phoneVerification:
        _updateState(AuthStatus.onboardingPhoneVerification);
        break;
      case OnboardingStep.photoUpload:
        _updateState(AuthStatus.onboardingPhotoUpload);
        break;
      case OnboardingStep.showCompleted:
        _updateState(AuthStatus.onboardingComplete);
        break;
      case OnboardingStep.completed:
        _updateState(AuthStatus.authenticated);
        break;
    }
  }

  void startOnboarding() {
    ref.invalidate(onboardingProvider);
    _updateState(AuthStatus.onboardingPersonalInfo);
  }

  void exitOnboarding() {
    signOut();
  }

  void setUserUnauthenticated() {
    _updateState(AuthStatus.unauthenticated);
  }

  void setUserAuthenticated() {
    _updateState(AuthStatus.authenticated);
  }

  Future<void> signInWithGoogle() async {
    try {
      final response = await authService.signInWithGoogle();
      user = response.user;
      checkAuthentication();
    } catch (e) {
      _updateState(AuthStatus.unauthenticated);
      await signOut();
    }
  }

  Future<void> signInWithApple() async {
    try {
      final response = await authService.signInWithApple();
      user = response.user;
      checkAuthentication();
    } catch (e) {
      _updateState(AuthStatus.unauthenticated);
      await signOut();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authService.signinWithEmail(
        email,
        password,
      );
      user = response.user;
      await checkAuthentication();
    } on ApiException catch (e) {
      throw e.code;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await authService.forgotPassword(
        email,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String password,
    required String token,
  }) async {
    try {
      await authService.resetPassword(
        password: password,
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> verifyCodeOnResetPassword({
    required String email,
    required String code,
  }) async {
    try {
      final token = await authService.verifyCodeOnResetPassword(
        code: code,
        email: email,
      );
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await ref.read(themeProvider.notifier).toggleUserTheme();
    _updateState(AuthStatus.authenticating);
    await authService.signOut();
    await Preferences.signout();
    user = null;
    _updateState(AuthStatus.unauthenticated);
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _routerListener = null;
  }
}
