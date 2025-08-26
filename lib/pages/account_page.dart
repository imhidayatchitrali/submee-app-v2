import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/providers/state_providers.dart';
import 'package:submee/utils/banners.dart';
import 'package:submee/utils/functions.dart';
import 'package:submee/widgets/custom_svg_picture.dart';
import 'package:submee/widgets/profile_progress_widget.dart';

import '../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/preferences.dart';
import '../widgets/profile_item.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final auth = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProfileProgressWidget(
                  progress:
                      auth.user?.profileProgress != null ? auth.user!.profileProgress / 100 : 0,
                ),
                const SizedBox(height: 20.0),
                ProfileItem(
                  title: locale.your_profile,
                  imageUrl: auth.user?.photoUrl,
                  addVerify: true,
                  onTap: () => context.push('/profile'),
                ),
                if (Preferences.isHost)
                  ProfileItem(
                    title: locale.sublet_property,
                    asset: 'add',
                    onTap: () => context.push('/manage-property'),
                  ),
                ProfileItem(
                  title: locale.addresses,
                  asset: 'address',
                ),
                if (!Preferences.isHost)
                  ProfileItem(
                    title: locale.booking_history,
                    asset: 'notification',
                  ),
                ProfileItem(
                  title:
                      '${locale.language} ${getNameFromLocale(currentLocale.languageCode)} (${getAcronimFromLocale(currentLocale.languageCode)})',
                  asset: 'language',
                  onTap: () => context.push('/language'),
                ),
                ProfileItem(
                  title: locale.privacy_policy,
                  asset: 'privacy',
                ),
                ProfileItem(
                  title: locale.help_center,
                  asset: 'info',
                ),
                ProfileItem(
                  title: locale.logout,
                  asset: 'logout',
                  onTap: () {
                    showConfirmationBanner(
                      context,
                      title: locale.logout,
                      body: locale.logout_confirmation,
                      buttonText: locale.logout,
                      onPressed: () {
                        ref.read(authProvider).signOut();
                      },
                    );
                  },
                  textColor: const Color(0xFFF75555),
                  useArrow: false,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await ref.read(themeProvider.notifier).toggleTheme();
              if (Preferences.isHost) {
                context.go('/host-home');
              } else {
                context.go('/');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: primaryColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomSvgPicture('assets/icons/host.svg'),
                  Text(
                    Preferences.isHost ? locale.switch_to_sublet : locale.switch_to_host,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
