import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/users/friends.dart';
import 'package:otraku/users/user_grid.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/tab_switcher.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class FriendsView extends ConsumerStatefulWidget {
  const FriendsView(this.id, this.onFollowing);

  final int id;
  final bool onFollowing;

  @override
  ConsumerState<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends ConsumerState<FriendsView> {
  late final PaginationController _ctrl;
  late bool _onFollowing;

  @override
  void initState() {
    super.initState();
    _onFollowing = widget.onFollowing;
    _ctrl = PaginationController(
      loadMore: () => ref.read(friendsProvider(widget.id).notifier).fetch(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      friendsProvider(widget.id).select((s) => s.getCount(_onFollowing)),
    );

    final refreshControl = SliverRefreshControl(
      onRefresh: () {
        ref.invalidate(friendsProvider(widget.id));
        return Future.value();
      },
    );

    return PageLayout(
      topBar: TopBar(
        title: _onFollowing ? 'Following' : 'Followers',
        items: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
        ],
      ),
      bottomBar: BottomBarIconTabs(
        current: _onFollowing ? 0 : 1,
        onChanged: (page) {
          setState(() => _onFollowing = page == 0 ? true : false);
        },
        onSame: (_) => _ctrl.scrollUpTo(0),
        items: const {
          'Following': Ionicons.people_circle,
          'Followers': Ionicons.person_circle,
        },
      ),
      child: TabSwitcher(
        current: _onFollowing ? 0 : 1,
        onChanged: (page) {
          setState(() => _onFollowing = page == 0 ? true : false);
        },
        tabs: [
          _FriendTab(
            id: widget.id,
            onFollowing: true,
            refreshControl: refreshControl,
            paginationController: _ctrl,
          ),
          _FriendTab(
            id: widget.id,
            onFollowing: false,
            refreshControl: refreshControl,
            paginationController: _ctrl,
          ),
        ],
      ),
    );
  }
}

class _FriendTab extends StatelessWidget {
  const _FriendTab({
    required this.id,
    required this.onFollowing,
    required this.refreshControl,
    required this.paginationController,
  });

  final int id;
  final bool onFollowing;
  final Widget refreshControl;
  final PaginationController paginationController;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<FriendsNotifier>(
          friendsProvider(id),
          (_, s) {
            final users = onFollowing ? s.following : s.followers;
            users.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load users',
                  content: error.toString(),
                ),
              ),
            );
          },
        );

        const empty = Center(child: Text('No Users'));

        final notifier = ref.watch(friendsProvider(id));
        final users = onFollowing ? notifier.following : notifier.followers;
        return users.maybeWhen(
            loading: () => const Center(child: Loader()),
            orElse: () => empty,
            data: (data) {
              if (data.items.isEmpty) return empty;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
                  child: CustomScrollView(
                    physics: Consts.physics,
                    controller: paginationController,
                    slivers: [
                      refreshControl,
                      UserGrid(data.items),
                      SliverFooter(loading: data.hasNext),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
