import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/widgets/banners/modal_wrapper.dart';
import 'package:submee/widgets/tab_section.dart';

import '../../generated/l10n.dart';
import '../../providers/user_notification_provider.dart';
import '../../widgets/banners/confirmation_modal.dart';
import '../../widgets/user_notification_profile_card.dart';

class HostNotificationPage extends HookConsumerWidget {
  const HostNotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final users = ref.watch(userNotificationsProvider);
    final primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: TabSection(
              tabs: [locale.filter_all, locale.filter_approved, locale.filter_pending],
              onTabSelected: (index) {
                ref.read(userNotificationsProvider.notifier).filterByTab(index);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                await ref.read(userNotificationsProvider.notifier).refresh();
              },
              child: users.when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: UserNotificationProfileCard(
                          value: item,
                          context: context,
                          onApprove: () {
                            ref.read(userNotificationsProvider.notifier).approveUserRequest(
                                  item.id,
                                  item.propertyId,
                                );
                          },
                          onDecline: () {
                            showCustomModal(
                              context: context,
                              child: ConfirmationModal(
                                title: locale.decline_confirmation,
                                onPressed: () async {
                                  await ref
                                      .read(userNotificationsProvider.notifier)
                                      .declineUserRequest(
                                        item.id,
                                        item.propertyId,
                                      );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                error: (error, stack) {
                  return Center(child: Text('Error: $error'));
                },
                loading: () {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
