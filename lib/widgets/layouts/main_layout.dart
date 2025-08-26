import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/preferences.dart';
import '../custom_bottom_navigation_bar.dart';
import '../profile_header.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({
    super.key,
    required this.child,
    this.showBottomBar = true,
  });
  final Widget child;
  final bool showBottomBar;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: primaryColor,
      bottomNavigationBar: showBottomBar ? const CustomBottomNavigationBar() : null,
      body: SafeArea(
        child: Container(
          color: primaryColor,
          child: Container(
            color: const Color(0xFFF1F1F1),
            child: Column(
              children: [
                Container(
                  color: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ProfileHeader(
                    image: auth.user?.photoUrl,
                    location: auth.user?.userLocation,
                    name: auth.user?.firstName ?? auth.user?.email.split('@').first,
                    onProfileTap: () {
                      context.go('/account');
                    },
                    notificationTap: () {
                      if (Preferences.isHost) {
                        context.push('/host-notification');
                      } else {
                        context.push('/notification');
                      }
                    },
                  ),
                ),
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
