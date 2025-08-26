import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/preferences.dart';
import '../custom_bottom_navigation_bar.dart';
import '../profile_header.dart';

class MainLayoutTitle extends ConsumerWidget {
  const MainLayoutTitle({
    super.key,
    required this.child,
    required this.title,
  });
  final Widget child;
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: primaryColor,
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: Container(
        color: primaryColor,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          color: const Color(0xFFF1F1F1),
          child: Column(
            children: [
              Container(
                color: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: ProfileHeader(
                  image: auth.user?.photoUrl,
                  location: auth.user?.userLocation,
                  name: auth.user?.firstName ?? auth.user?.email.split('@').first,
                  title: title,
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
    );
  }
}
