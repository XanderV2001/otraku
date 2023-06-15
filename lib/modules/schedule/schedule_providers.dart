import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/filter/filter_providers.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';

void scheduleLoadMore(WidgetRef ref) {}

final _searchSelector = (String? s) => s == null || s.isEmpty ? null : s;

final scheduleAnimeProvider = StateNotifierProvider.autoDispose<ScheduleMediaNotifier, AsyncValue<Paged<ScheduleMediaItem>>>(
  (ref) {
    final scheduleFilter = ref.watch(scheduleFilterProvider);
    return ScheduleMediaNotifier(scheduleFilter.filter, ref.watch(searchProvider(null).select(_searchSelector)),
        scheduleFilter.type == DiscoverType.anime && ref.watch(homeProvider.select((value) => value.didLoadSchedule)));
  },
);

class ScheduleMediaNotifier extends StateNotifier<AsyncValue<Paged<ScheduleMediaItem>>> {
  ScheduleMediaNotifier(this.filter, this.search, bool shouldLoad) : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final ScheduleMediaFilter filter;
  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final currentDate = DateTime.now();

      final data = await Api.get(GqlQuery.schedule, {
        'page': value.next,
        'type': filter.ofAnime ? 'ANIME' : 'MANGA',
        'status': 'NOT_YET_RELEASED',
        'seasonYear': filter.seasonYear ?? currentDate.year,
        if (search != null && search!.isNotEmpty) ...{
          'search': search,
          ...filter.toMap()..['sort'] = 'SEARCH_MATCH',
        } else
          ...filter.toMap(),
      });

      final items = <ScheduleMediaItem>[];
      for (final m in data['Page']['media']) {
        items.add(ScheduleMediaItem(m));
      }

      return value.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false);
    });
  }
}
