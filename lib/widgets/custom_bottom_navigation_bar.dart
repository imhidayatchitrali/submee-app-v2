import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/providers/router_providers.dart';
import 'package:submee/utils/preferences.dart';

import 'custom_svg_picture.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final goRouter = ref.read(routerProvider).router;
    return Container(
      color: const Color(0xFFF1F1F1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: getIndexFromPath(goRouter.state?.matchedLocation),
            onTap: (index) {
              switch (index) {
                case 0:
                  if (Preferences.isHost) {
                    goRouter.go('/host-home');
                  } else {
                    goRouter.go('/');
                  }
                  break;
                case 1:
                  if (Preferences.isHost) {
                    goRouter.go('/host-favorite');
                  } else {
                    goRouter.go('/favorite');
                  }
                  break;
                case 2:
                  goRouter.go('/chat');
                  break;
                case 3:
                  goRouter.go('/account');
                  break;
              }
            },
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: [
              _buildNavItem(0, 'home', 'Home', goRouter.state?.matchedLocation, primaryColor),
              _buildNavItem(
                1,
                'heart',
                'Favorites',
                goRouter.state?.matchedLocation,
                primaryColor,
              ),
              _buildNavItem(2, 'chat', 'Chat', goRouter.state?.matchedLocation, primaryColor),
              _buildNavItem(
                3,
                'profile',
                'Profile',
                goRouter.state?.matchedLocation,
                primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getIndexFromPath(String? path) {
    switch (path) {
      case '/':
        return 0;
      case '/favorite':
      case '/host-favorite':
        return 1;
      case '/chat':
        return 2;
      case '/account':
        return 3;
      default:
        return 0;
    }
  }

  BottomNavigationBarItem _buildNavItem(
    int index,
    String icon,
    String label,
    String? currentPath,
    Color primaryColor,
  ) {
    final isSelected = getIndexFromPath(currentPath) == index;

    return BottomNavigationBarItem(
      icon: Column(
        children: [
          CustomSvgPicture(
            'assets/icons/$icon.svg',
            color: isSelected ? primaryColor : Colors.grey,
            height: 24,
          ),
          const SizedBox(height: 2),
          // Underline indicator
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
