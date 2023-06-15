import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/filter/filter_search_field.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';
import 'package:otraku/modules/schedule/schedule_providers.dart';
import 'package:otraku/modules/filter/filter_providers.dart';
import 'package:otraku/modules/filter/filter_view.dart';

import 'schedule_media_grid.dart';

class ScheduleView extends ConsumerWidget {
  const ScheduleView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onRefresh = () {
      ref.invalidate(scheduleAnimeProvider);
    };

    return TabScaffold(
      topBar: const TopBar(canPop: false, trailing: [_TopBarContent()]),
      child: _Grid(scrollCtrl, onRefresh),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Expanded(
        child: Row(
          children: [
            const SearchFilterField(title: "Calendar", enabled: true),
            TopBarIcon(
              tooltip: 'Filter',
              icon: Ionicons.funnel_outline,
              onTap: () => showSheet(
                context,
                ScheduleFilterView(
                  filter: ref.read(scheduleFilterProvider).filter,
                  onChanged: (filter) => ref.read(scheduleFilterProvider).filter = filter,
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

class _Grid extends StatelessWidget {
  const _Grid(this.scrollCtrl, this.onRefresh);

  final ScrollController scrollCtrl;
  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return PagedView<ScheduleMediaItem>(
        provider: scheduleAnimeProvider,
        scrollCtrl: scrollCtrl,
        onRefresh: onRefresh,
        onData: (data) {
          return ScheduleMediaGrid(data.items);
        },
      );
    });
  }
}
