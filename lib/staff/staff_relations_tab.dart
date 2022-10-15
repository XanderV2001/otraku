import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/filter/chip_selector.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/filter/filter_tools.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/staff/staff_providers.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class StaffCharactersTab extends StatelessWidget {
  const StaffCharactersTab(this.id, this.scrollCtrl);

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id, false)],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
            child: Consumer(
              builder: (context, ref, _) {
                ref.listen<AsyncValue>(
                  staffRelationProvider(id).select((s) => s.characters),
                  (_, s) {
                    if (s.hasError) {
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not load characters',
                          content: s.error.toString(),
                        ),
                      );
                    }
                  },
                );

                final refreshControl = SliverRefreshControl(
                  onRefresh: () => ref.invalidate(staffRelationProvider(id)),
                );

                final notifier = ref.watch(staffRelationProvider(id));

                return notifier.characters.when(
                  loading: () => const Center(child: Loader()),
                  error: (_, __) => CustomScrollView(
                    physics: Consts.physics,
                    slivers: [
                      refreshControl,
                      const SliverFillRemaining(child: Text('No characters')),
                    ],
                  ),
                  data: (data) {
                    return CustomScrollView(
                      controller: scrollCtrl,
                      physics: Consts.physics,
                      slivers: [
                        refreshControl,
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        RelationGrid(
                          items: data.items,
                          connections: notifier.characterMedia,
                          placeholder: 'No characters',
                        ),
                        SliverFooter(loading: data.hasNext),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StaffRolesTab extends StatelessWidget {
  const StaffRolesTab(this.id, this.scrollCtrl);

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id, true)],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Consumer(
              builder: (context, ref, _) {
                ref.listen<AsyncValue>(
                  staffRelationProvider(id).select((s) => s.roles),
                  (_, s) {
                    if (s.hasError) {
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not load roles',
                          content: s.error.toString(),
                        ),
                      );
                    }
                  },
                );

                final refreshControl = SliverRefreshControl(
                  onRefresh: () => ref.invalidate(staffRelationProvider(id)),
                );

                return ref.watch(staffRelationProvider(id)).roles.when(
                      loading: () => const Center(child: Loader()),
                      error: (_, __) => CustomScrollView(
                        physics: Consts.physics,
                        slivers: [
                          refreshControl,
                          const SliverFillRemaining(child: Text('No roles')),
                        ],
                      ),
                      data: (data) {
                        return CustomScrollView(
                          controller: scrollCtrl,
                          physics: Consts.physics,
                          slivers: [
                            refreshControl,
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 10),
                            ),
                            RelationGrid(
                              items: data.items,
                              placeholder: 'No roles',
                            ),
                            SliverFooter(loading: data.hasNext),
                          ],
                        );
                      },
                    );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton(this.id, this.full);

  final int id;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            var filter = ref.read(staffFilterProvider(id));

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
              sortItems[key] = i ~/ 2;
            }

            final onDone = (_) =>
                ref.read(staffFilterProvider(id).notifier).state = filter;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Consts.tapTargetSize * (full ? 5.5 : 4),
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Consts.physics,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Flexible(
                          child: SizedBox(
                            height: 70,
                            child: SortDropDown(
                              MediaSort.values,
                              () => filter.sort.index,
                              (MediaSort val) =>
                                  filter = filter.copyWith(sort: val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: SizedBox(
                            height: 70,
                            child: OrderDropDown(
                              MediaSort.values,
                              () => filter.sort.index,
                              (MediaSort val) =>
                                  filter = filter.copyWith(sort: val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    if (full) ...[
                      const SizedBox(height: 10),
                      ChipSelector(
                        title: 'Type',
                        options: const ['Anime', 'Manga'],
                        selected: filter.ofAnime == null
                            ? null
                            : filter.ofAnime!
                                ? 0
                                : 1,
                        onChanged: (val) =>
                            filter = filter.copyWith(ofAnime: () {
                          if (val == null) return null;
                          return val == 0 ? true : false;
                        }),
                      ),
                    ],
                    const SizedBox(height: 10),
                    ChipSelector(
                      title: 'List Presence',
                      options: const ['On List', 'Not on List'],
                      selected: filter.onList == null
                          ? null
                          : filter.onList!
                              ? 0
                              : 1,
                      onChanged: (val) => filter = filter.copyWith(onList: () {
                        if (val == null) return null;
                        return val == 0 ? true : false;
                      }),
                    ),
                  ],
                ),
              ),
            ).then(onDone);
          },
        );
      },
    );
  }
}
