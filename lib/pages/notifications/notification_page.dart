import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/widgets/banners/modal_wrapper.dart';
import 'package:submee/widgets/tab_section.dart';

import '../../generated/l10n.dart';
import '../../providers/property_notification_provider.dart';
import '../../widgets/banners/confirmation_modal.dart';
import '../../widgets/host_notification_profile_card.dart';

class NotificationPage extends HookConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final properties = ref.watch(propertyNotificationsProvider);
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
                ref.read(propertyNotificationsProvider.notifier).filterByTab(index);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                await ref.read(propertyNotificationsProvider.notifier).refresh();
              },
              child: properties.when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final property = data[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: HostNotificationProfileCard(
                          value: property,
                          onChat: () {
                            if (property.conversationId != null) {
                              context.push('/chat/${property.conversationId}');
                              return;
                            }
                            context.push('/chat/new/${property.id}');
                          },
                          onWithdraw: () {
                            showCustomModal(
                              context: context,
                              child: ConfirmationModal(
                                title: locale.withdraw_confirmation,
                                onPressed: () async {
                                  await ref
                                      .read(propertyNotificationsProvider.notifier)
                                      .withdrawPropertyRequest(
                                        property.id,
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
