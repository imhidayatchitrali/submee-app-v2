import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/widgets/banners/modal_wrapper.dart';

import '../../generated/l10n.dart';
import '../../providers/property_providers.dart';
import '../../widgets/banners/confirmation_modal.dart';
import '../../widgets/sublet_place_placeholder.dart';

class ManagePropertyPage extends ConsumerWidget {
  const ManagePropertyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    final items = ref.watch(hostPropertiesProvider);
    return Container(
      padding: const EdgeInsets.only(right: 27, left: 27, top: 26),
      child: SingleChildScrollView(
        child: Column(
          spacing: 26,
          children: [
            GestureDetector(
              onTap: () => context.push('/publish-page'),
              child: Container(
                height: size.height * 0.1,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  spacing: 9,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 4,
                          color: primaryColor,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                    Text(
                      locale.sublet_new_place,
                      style: textTheme.labelLarge!.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            items.when(
              data: (data) {
                return Column(
                  children: data
                      .map(
                        (i) => SubletPlacePlaceholder(
                          item: i,
                          onDelete: () {
                            showCustomModal(
                              context: context,
                              child: ConfirmationModal(
                                body: locale.delete_property_confirmation_body,
                                title: locale.delete_property_confirmation_title,
                                cancelText: locale.cancel,
                                confrimText: locale.delete,
                                onPressed: () async {
                                  await ref.read(deletePropertyProvider)(i.id);
                                },
                              ),
                            );
                          },
                          onEdit: () {
                            context.push('/publish-page', extra: i.id);
                          },
                        ),
                      )
                      .toList(),
                );
              },
              error: (error, stackTrace) => const SizedBox(),
              loading: () => Column(
                children: List.generate(
                  3,
                  (index) => const SubletPlacePlaceholder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
