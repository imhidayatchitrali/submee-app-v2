import 'package:go_router/go_router.dart';
import 'package:submee/pages/account_page.dart';
import 'package:submee/pages/chat/conversation_chat_page.dart';
import 'package:submee/pages/host/manage_property_page.dart';
import 'package:submee/pages/notifications/notification_page.dart';
import 'package:submee/pages/onboarding/completion_page.dart';
import 'package:submee/pages/onboarding/photo_upload_page.dart';
import 'package:submee/pages/profile/add_your_photos_page.dart';
import 'package:submee/pages/verify_otp_page.dart';
import 'package:submee/utils/functions.dart';
import 'package:submee/widgets/layouts/only_appbar_layout.dart';

import '../generated/l10n.dart';
import '../pages/chat/conversation_detail_page.dart';
import '../pages/error_page.dart';
import '../pages/favorite/favorite_page.dart';
import '../pages/favorite/host_favorite_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/get_started_page.dart';
import '../pages/home_page.dart';
import '../pages/host/publish_place_onboarding_page.dart';
import '../pages/host_home_page.dart';
import '../pages/login_page.dart';
import '../pages/notifications/host_notification_page.dart';
import '../pages/onboarding/onboarding_shell.dart';
import '../pages/onboarding/personal_details_page.dart';
import '../pages/onboarding/phone_verification_page.dart';
import '../pages/profile/complete_profile_page.dart';
import '../pages/profile/language_page.dart';
import '../pages/set_new_password_page.dart';
import '../pages/splash_page.dart';
import '../pages/starter_page.dart';
import '../providers/auth_provider.dart';
import '../utils/enum.dart';
import '../utils/preferences.dart';
import '../widgets/layouts/main_layout.dart';
import '../widgets/layouts/main_layout_title.dart';
import '../widgets/layouts/single_title_layout.dart';
import '../widgets/layouts/unauth_layout.dart';

class AppRouter {
  AppRouter({
    required this.authProvider,
  });
  final AuthProvider authProvider;

  GoRouter get router => _router;

  late final _router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => SingleTitleLayout(
          title:
              getDatabaseItemNameTranslation(state.matchedLocation.split('/').last, S.of(context)),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountPage(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ConversationChatPage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/host-home',
            name: 'host-home',
            builder: (context, state) => const HostHomePage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayoutTitle(
          title:
              getDatabaseItemNameTranslation(state.matchedLocation.split('/').last, S.of(context)),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/favorite',
            name: 'favorite',
            builder: (context, state) => const FavoritePage(),
          ),
          GoRoute(
            path: '/host-favorite',
            name: 'host-favorite',
            builder: (context, state) => const HostFavoritePage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => OnlyAppbarLayout(
          title: getDatabaseItemNameTranslation(state.topRoute?.name, S.of(context)),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/language',
            name: 'change-language',
            builder: (context, state) => const LanguagePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'complete-profile',
            builder: (context, state) => const CompleteProfilePage(),
          ),
          GoRoute(
            path: '/notification',
            name: 'notification',
            builder: (context, state) => const NotificationPage(),
          ),
          GoRoute(
            path: '/host-notification',
            name: 'host-notification',
            builder: (context, state) => const HostNotificationPage(),
          ),
          GoRoute(
            path: '/chat/:conversationId',
            name: 'message',
            builder: (context, state) {
              final conversationId = int.parse(state.pathParameters['conversationId']!);
              return ConversationDetailPage(
                conversationId: conversationId,
              );
            },
          ),
          GoRoute(
            path: '/chat/new/:propertyId',
            name: 'new_message',
            builder: (context, state) {
              final propertyId = int.parse(state.pathParameters['propertyId']!);
              return ConversationDetailPage(
                propertyId: propertyId,
              );
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/manage-property',
            name: 'manage-property',
            builder: (context, state) => const ManagePropertyPage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(
          showBottomBar: false,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/publish-page',
            name: 'publish-page',
            builder: (context, state) {
              final id = state.extra as int?;
              return PublishPlaceOnboardingPage(id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) => const ErrorPage(),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => UnauthLayout(
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
          GoRoute(
            path: '/verify-otp',
            name: 'verify-otp',
            builder: (context, state) {
              final extras = state.extra as Map<String, dynamic>;
              final email = extras['email'] as String;
              return VerifyOTPPage(email);
            },
          ),
          GoRoute(
            path: '/reset-password',
            name: 'reset-password',
            builder: (context, state) {
              final extras = state.extra as Map<String, dynamic>;
              final token = extras['token'] as String;
              return SetNewPasswordPage(token);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/starter',
        name: 'starter',
        builder: (context, state) => const StarterPage(),
      ),
      GoRoute(
        path: '/get-started',
        name: 'get-started',
        builder: (context, state) => const GetStartedPage(),
      ),
      GoRoute(
        path: '/add-your-photos',
        name: 'add-your-photos',
        builder: (context, state) => const AddYourPhotosPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => OnboardingShell(
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/onboarding/details',
            name: 'onboarding-details',
            builder: (context, state) => PersonalDetailsPage(),
          ),
          GoRoute(
            path: '/onboarding/phone',
            name: 'onboarding-phone',
            builder: (context, state) => const PhoneVerificationPage(),
          ),
          GoRoute(
            path: '/onboarding/photo',
            name: 'onboarding-photo',
            builder: (context, state) => const PhotoUploadPage(),
          ),
          GoRoute(
            path: '/onboarding/completed',
            name: 'onboarding-completed',
            builder: (context, state) => const CompletionPage(),
          ),
        ],
      ),
    ],
    // Your other routes...
    redirect: (context, state) async {
      final authStatus = authProvider.authStatus;
      final userIsHost = authProvider.user?.isHost ?? false;
      switch (authStatus) {
        case AuthStatus.initial:
          authProvider.checkAuthentication();
          return '/splash';
        case AuthStatus.authenticating:
          return '/splash';
        case AuthStatus.authenticated:
          // Block host home page for users who are not hosts (no properties)
          if (Preferences.isHost && !userIsHost && state.matchedLocation == '/host-home') {
            return '/publish-page';
          }
          if (authenticatedRoutes.contains(state.matchedLocation.split('/')[1])) {
            return null;
          }
          if (Preferences.isHost) {
            return '/host-home';
          }
          return '/';
        case AuthStatus.unauthenticated:
          if (unauthenticatedRoutes.contains(state.matchedLocation)) {
            return null;
          }
          return '/starter';
        case AuthStatus.getStarted:
          return '/get-started';
        case AuthStatus.onboardingPersonalInfo:
          return '/onboarding/details';
        case AuthStatus.onboardingPhoneVerification:
          return '/onboarding/phone';
        case AuthStatus.onboardingPhotoUpload:
          return '/onboarding/photo';
        case AuthStatus.onboardingComplete:
          return '/onboarding/completed';
      }
    },
  );

  final unauthenticatedRoutes = {
    '/login',
    '/starter',
    '/forgot-password',
    '/verify-otp',
    '/reset-password',
  };

  final authenticatedRoutes = {
    'account',
    'notification',
    'host-notification',
    'language',
    'profile',
    'publish-page',
    'manage-property',
    'add-new-place',
    'host-home',
    'chat',
    'favorite',
    'host-favorite',
  };
}
