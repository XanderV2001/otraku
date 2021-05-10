import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/notifications.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/pages/activity_page.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class NotificationsPage extends StatelessWidget {
  static const ROUTE = '/notifications';

  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<Notifications>();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        trailing: [
          ActionIcon(
            dimmed: false,
            tooltip: 'Filter',
            icon: Ionicons.funnel_outline,
            onTap: () => Sheet.show(
              ctx: context,
              sheet: OptionSheet(
                title: 'Category',
                options: ['All', 'Activities', 'Forum', 'Media', 'Follows'],
                index: notifications.filter,
                onTap: (val) => notifications.filter = val,
              ),
              isScrollControlled: true,
            ),
          ),
        ],
      ),
      body: GetBuilder<Notifications>(builder: (notifications) {
        final entries = notifications.entries;
        return ListView.builder(
          padding: Config.PADDING,
          physics: Config.PHYSICS,
          controller: notifications.scrollCtrl,
          itemBuilder: (_, index) => _NotificationWidget(
            entries[index],
            index < notifications.unreadCount,
          ),
          itemCount: entries.length,
          itemExtent: 100,
        );
      }),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  final bool unread;

  _NotificationWidget(this.notification, this.unread);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => BrowseIndexer.openPage(
                id: notification.headId!,
                imageUrl: notification.imageUrl,
                browsable: notification.browsable ?? Browsable.user,
              ),
              onLongPress: () {
                if (notification.browsable == Browsable.anime ||
                    notification.browsable == Browsable.manga)
                  BrowseIndexer.openEditPage(notification.headId!);
              },
              child: ClipRRect(
                child: FadeImage(notification.imageUrl, width: 70),
                borderRadius: BorderRadius.horizontal(left: Config.RADIUS),
              ),
            ),
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  switch (notification.type) {
                    case NotificationType.AIRING:
                    case NotificationType.RELATED_MEDIA_ADDITION:
                      BrowseIndexer.openPage(
                        id: notification.bodyId!,
                        imageUrl: notification.imageUrl,
                        browsable: notification.browsable!,
                      );
                      return;
                    case NotificationType.ACTIVITY_LIKE:
                    case NotificationType.ACTIVITY_MENTION:
                    case NotificationType.ACTIVITY_MESSAGE:
                    case NotificationType.ACTIVITY_REPLY:
                    case NotificationType.ACTIVITY_REPLY_LIKE:
                    case NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
                      Get.toNamed(
                        ActivityPage.ROUTE,
                        arguments: [notification.bodyId, null, null],
                        parameters: {'id': notification.bodyId.toString()},
                      );
                      return;
                    case NotificationType.FOLLOWING:
                      BrowseIndexer.openPage(
                        id: notification.headId!,
                        imageUrl: notification.imageUrl,
                        browsable: Browsable.user,
                      );
                      return;
                    default:
                      Toast.show(context, 'Forum is not supported yet');
                      return;
                  }
                },
                onLongPress: () {
                  if (notification.browsable == Browsable.anime ||
                      notification.browsable == Browsable.manga)
                    BrowseIndexer.openEditPage(notification.headId!);
                },
                child: Padding(
                  padding: Config.PADDING,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        overflow: TextOverflow.fade,
                        text: TextSpan(
                          children: [
                            for (int i = 0; i < notification.texts.length; i++)
                              TextSpan(
                                text: notification.texts[i],
                                style: (i % 2 == 0) ==
                                        notification.markTextOnEvenIndex
                                    ? Theme.of(context).textTheme.bodyText1
                                    : Theme.of(context).textTheme.bodyText2,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        notification.timestamp,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.horizontal(right: Config.RADIUS),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
