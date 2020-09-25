import 'package:flutter/material.dart';
import 'package:otraku/providers/design.dart';

enum ScoreFormat {
  POINT_100,
  POINT_10_DECIMAL,
  POINT_10,
  POINT_5,
  POINT_3,
}

extension ScoreFormatExtension on ScoreFormat {
  static const _formats = {
    ScoreFormat.POINT_100: 'POINT_100',
    ScoreFormat.POINT_10_DECIMAL: 'POINT_10_DECIMAL',
    ScoreFormat.POINT_10: 'POINT_10',
    ScoreFormat.POINT_5: 'POINT_5',
    ScoreFormat.POINT_3: 'POINT_3',
  };

  String get string {
    return _formats[this];
  }
}

Widget getWidgetFormScoreFormat(
  BuildContext context,
  String format,
  double score,
) {
  if (score == 0) {
    return Text('');
  }

  switch (format) {
    case 'POINT_100':
    case 'POINT_10':
      return Text(
        score.toStringAsFixed(0),
        style: Theme.of(context).textTheme.subtitle1,
      );
    case 'POINT_10_DECIMAL':
      return Text(
        score.toStringAsFixed(score.truncate() == score ? 0 : 1),
        style: Theme.of(context).textTheme.subtitle1,
      );
    case 'POINT_5':
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            score.toStringAsFixed(0),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Icon(Icons.star, size: Design.ICON_SMALL),
        ],
      );
    case 'POINT_3':
      if (score == 3) {
        return Icon(Icons.sentiment_very_satisfied);
      }
      if (score == 2) {
        return Icon(Icons.sentiment_neutral);
      }
      return Icon(Icons.sentiment_very_dissatisfied);
    default:
      throw 'Unrecognised Score Format: $format';
  }
}
