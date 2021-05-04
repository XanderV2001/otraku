import 'package:flutter/material.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class MediaHeader extends StatefulWidget {
  final Media media;
  final String? imageUrl;
  final double coverWidth;
  final double coverHeight;
  final double bannerHeight;
  final double height;

  MediaHeader({
    required this.media,
    required this.imageUrl,
    required this.coverWidth,
    required this.coverHeight,
    required this.bannerHeight,
    required this.height,
  });

  @override
  _MediaHeaderState createState() => _MediaHeaderState();
}

class _MediaHeaderState extends State<MediaHeader> {
  @override
  Widget build(BuildContext context) {
    final overview = widget.media.model?.overview;
    return CustomSliverHeader(
      height: widget.height,
      title: overview?.preferredTitle,
      actions: overview != null
          ? [
              ActionIcon(
                dimmed: false,
                tooltip: 'Edit',
                onTap: _edit,
                icon: overview.entryStatus == null ? Icons.add : Icons.edit,
              ),
              ActionIcon(
                dimmed: false,
                tooltip: 'Favourite',
                onTap: _toggleFavourite,
                icon: overview.isFavourite!
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ]
          : const [],
      background: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          if (overview?.banner != null)
            Column(
              children: [
                Expanded(child: FadeImage(overview!.banner)),
                SizedBox(height: widget.height - widget.bannerHeight),
              ],
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: widget.height - widget.bannerHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 25,
                    color: Theme.of(context).backgroundColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Hero(
              tag: widget.media.id,
              child: Container(
                height: widget.coverHeight,
                width: widget.coverWidth,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(widget.imageUrl!, fit: BoxFit.cover),
                      if (overview != null)
                        GestureDetector(
                          child: Image.network(
                            overview.cover!,
                            fit: BoxFit.cover,
                          ),
                          onTap: () =>
                              showPopUp(context, ImageDialog(overview.cover!)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (overview != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        overview.preferredTitle!,
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                          shadows: [
                            Shadow(
                              color: Theme.of(context).backgroundColor,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    if (overview.nextEpisode != null)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Ep ${overview.nextEpisode} in ${overview.timeUntilAiring}',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              clipBehavior: Clip.hardEdge,
                              onPressed: _edit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Icon(
                                  overview.entryStatus == null
                                      ? Icons.add
                                      : Icons.edit,
                                ),
                              ),
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              clipBehavior: Clip.hardEdge,
                              onPressed: _toggleFavourite,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Icon(
                                  overview.isFavourite!
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).errorColor,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _edit() => BrowseIndexer.openEditPage(
        widget.media.model!.overview.id,
        widget.media.model!.entry,
        (ListStatus? status) =>
            setState(() => widget.media.model!.overview.entryStatus = status),
      );

  void _toggleFavourite() => widget.media.toggleFavourite().then((ok) => ok
      ? setState(
          () => widget.media.model!.overview.isFavourite =
              !widget.media.model!.overview.isFavourite!,
        )
      : null);
}
