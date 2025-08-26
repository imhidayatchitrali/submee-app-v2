import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/state_providers.dart';
import '../../services/user_service.dart';
import '../../widgets/language_tile.dart';

class LanguagePage extends HookConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<Locale?>(null);
    final locale = S.of(context);
    final loading = useState(false);
    final currentLocale = ref.watch(localeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 18,
            children: [
              const SizedBox(
                height: 18,
              ),
              LanguageTile(
                language: locale.english,
                flagAsset: 'assets/flags/usa.png',
                isSelected: (selected.value?.languageCode ?? currentLocale.languageCode) == 'en',
                onTap: () {
                  selected.value = const Locale('en');
                },
              ),
              LanguageTile(
                language: locale.hebrew,
                flagAsset: 'assets/flags/israel.png',
                isSelected: (selected.value?.languageCode ?? currentLocale.languageCode) == 'he',
                onTap: () {
                  selected.value = const Locale('he');
                },
              ),
              LanguageTile(
                language: locale.spanish,
                flagAsset: 'assets/flags/spanish.png',
                isSelected: (selected.value?.languageCode ?? currentLocale.languageCode) == 'es',
                onTap: () {
                  selected.value = const Locale('es');
                },
              ),
            ],
          ),
          FilledButton(
            onPressed: () async {
              if (selected.value != null) {
                try {
                  loading.value = true;
                  await ref.read(userService).updateLanguage(selected.value!.languageCode);
                  ref.read(localeProvider.notifier).state = selected.value!;
                } finally {
                  loading.value = false;
                }
              }
            },
            child: Text(locale.change_language),
          ),
        ],
      ),
    );
  }
}
