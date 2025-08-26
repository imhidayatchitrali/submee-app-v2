import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:submee/generated/l10n.dart';
import 'package:submee/utils/preferences.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/functions.dart';

class GetStartedPage extends ConsumerStatefulWidget {
  const GetStartedPage({super.key});

  @override
  ConsumerState<GetStartedPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<GetStartedPage> {
  final PageController _controller = PageController(viewportFraction: 0.8);

  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0.0; // Track current page position
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    final onboardingData = getOnboardingData(locale);
    return Scaffold(
      body: Container(
        padding: AppTheme.screenPadding,
        decoration: BoxDecoration(gradient: AppTheme.mainGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: size.height * 0.05), // 10% of screen height
            SizedBox(
              height: size.height * 0.6,
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  // Calculate scale based on current page
                  double scale = 1.0 - (0.1 * (_currentPage - index).abs());
                  scale = scale.clamp(0.9, 1.0);

                  final item = onboardingData[index];
                  return Center(
                    child: Transform.scale(
                      scale: scale, // Dynamically scale the height
                      child: _OnboardingSection(
                        title: item['title']!,
                        description: item['description']!,
                        image: item['image']!,
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: onboardingData.length,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  dotColor: const Color(0xFFD9D9D9),
                  activeDotColor: primaryColor,
                ),
              ),
            ),
            Center(
              child: FilledButton(
                onPressed: () {
                  if (_controller.page! < onboardingData.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Preferences.saveGetStarted();
                    ref.read(authProvider).setUserUnauthenticated();
                  }
                },
                child: Text(
                  _currentPage < onboardingData.length - 1
                      ? locale.next_button
                      : locale.get_started_button,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  locale.already_have_account + '?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Preferences.saveGetStarted();
                    ref.read(authProvider).setUserUnauthenticated();
                  },
                  child: Text(
                    locale.log_in,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSection extends StatelessWidget {
  const _OnboardingSection({
    required this.title,
    required this.description,
    required this.image,
  });
  final String title;
  final String description;
  final String image;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image with rounded corners and shadow
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Title
        IntrinsicWidth(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
