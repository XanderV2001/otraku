import 'package:flutter/material.dart';
import 'package:otraku/models/connection.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/layouts/sliver_grid_delegates.dart';

class ConnectionsGrid extends StatefulWidget {
  final List<Connection> connections;
  final Function loadMore;
  final String preferredSubtitle;

  ConnectionsGrid({
    @required this.connections,
    @required this.loadMore,
    this.preferredSubtitle,
  });

  @override
  _ConnectionsGridState createState() => _ConnectionsGridState();
}

class _ConnectionsGridState extends State<ConnectionsGrid> {
  @override
  Widget build(BuildContext context) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == widget.connections.length - 5) widget.loadMore();
            return _MediaConnectionTile(
                widget.connections[index], widget.preferredSubtitle);
          },
          childCount: widget.connections.length,
        ),
        gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 350,
          height: 110,
        ),
      );
}

class _MediaConnectionTile extends StatelessWidget {
  final Connection item;
  final String preferredSubtitle;

  _MediaConnectionTile(this.item, this.preferredSubtitle);

  @override
  Widget build(BuildContext context) {
    int index;
    if (preferredSubtitle == null)
      index = 0;
    else
      for (int i = 0; i < item.others.length; i++)
        if (item.others[i].subtitle == preferredSubtitle) {
          index = i;
          break;
        }

    return Align(
      alignment: Alignment.topCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: BrowseIndexer(
                id: item.id,
                browsable: item.browsable,
                imageUrl: item.imageUrl,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        child: FadeImage(item.imageUrl, width: 75),
                        borderRadius:
                            BorderRadius.horizontal(left: Config.RADIUS),
                      ),
                      Expanded(
                        child: Padding(
                          padding: Config.PADDING,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index != null && item.others.length > index)
              Expanded(
                child: BrowseIndexer(
                  id: item.others[index].id,
                  browsable: item.others[index].browsable,
                  imageUrl: item.others[index].imageUrl,
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: Config.PADDING,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.others[index].title,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Text(
                                  item.others[index].subtitle,
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          child: FadeImage(
                            item.others[index].imageUrl,
                            width: 75,
                          ),
                          borderRadius:
                              BorderRadius.horizontal(right: Config.RADIUS),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
