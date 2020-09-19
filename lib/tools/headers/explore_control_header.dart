import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/header_refresh_button.dart';
import 'package:otraku/tools/headers/header_search_bar.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:otraku/tools/overlays/explore_sort_sheet.dart';
import 'package:provider/provider.dart';

class ExploreControlHeader extends StatelessWidget {
  final ScrollController scrollCtrl;

  const ExploreControlHeader(this.scrollCtrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: _ExploreControlHeaderDelegate(context, scrollCtrl),
    );
  }
}

class _ExploreControlHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 95.0;

  Palette _palette;
  ScrollController _scrollCtrl;

  _ExploreControlHeaderDelegate(
      BuildContext context, ScrollController scrollController) {
    _palette = Provider.of<Theming>(context, listen: false).palette;
    _scrollCtrl = scrollController;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          color: _palette.background.withAlpha(200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TitleSegmentedControl(
                  value: Provider.of<ExplorableMedia>(context).type,
                  pairs: const {'Anime': 'ANIME', 'Manga': 'MANGA'},
                  onNewValue: (value) {
                    Provider.of<ExplorableMedia>(
                      context,
                      listen: false,
                    ).type = value;
                    _scrollCtrl.jumpTo(0);
                  },
                  onSameValue: (_) => _scrollCtrl.jumpTo(0),
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HeaderSearchBar(
                      Provider.of<ExplorableMedia>(context),
                      _palette,
                    ),
                    _FilterButton(_palette),
                    IconButton(
                      icon: const Icon(LineAwesomeIcons.sort),
                      color: _palette.faded,
                      iconSize: Palette.ICON_MEDIUM,
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (ctx) => ExploreSortSheet(),
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                      ),
                    ),
                    HeaderRefreshButton(
                      listenable: Provider.of<ExplorableMedia>(context),
                      readable:
                          Provider.of<ExplorableMedia>(context, listen: false),
                      palette: _palette,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}

class _FilterButton extends StatelessWidget {
  final Palette palette;

  _FilterButton(this.palette);

  @override
  Widget build(BuildContext context) {
    return Provider.of<ExplorableMedia>(context).areFiltersActive()
        ? GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FilterPage()),
            ),
            onLongPress: Provider.of<ExplorableMedia>(context, listen: false)
                .clearGenreTagFilters,
            child: Container(
              width: 48,
              height: ViewConfig.CONTROL_HEADER_ICON_HEIGHT,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: palette.accent,
              ),
              child: const Icon(
                LineAwesomeIcons.filter,
                size: Palette.ICON_MEDIUM,
                color: Colors.white,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(LineAwesomeIcons.filter),
            color: palette.faded,
            iconSize: Palette.ICON_MEDIUM,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FilterPage()),
            ),
          );
  }
}
