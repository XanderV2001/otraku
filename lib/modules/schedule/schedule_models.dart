import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

class ScheduleMediaItem {
  ScheduleMediaItem._({
    required this.id,
    required this.title,
    required this.season,
    required this.format,
    required this.genres,
    required this.duration,
    required this.episodes,
    required this.imageUrl,
    required this.listStatus,
    required this.popularity,
    required this.isAdult,
  });

  factory ScheduleMediaItem(Map<String, dynamic> map) => ScheduleMediaItem._(
        id: map['id'],
        title: map['title']['userPreferred'],
        season: Convert.clarifyEnum(map['season'])!,
        format: Convert.clarifyEnum(map['format']),
        genres: List.from(map['genres'] ?? [], growable: false),
        duration: map['duration'],
        episodes: map['episodes'],
        imageUrl: map['coverImage'][Options().imageQuality.value],
        listStatus: Convert.clarifyEnum(map['mediaListEntry']?['status']),
        popularity: map['popularity'] ?? 0,
        isAdult: map['isAdult'] ?? false,
      );

  final int id;
  final String title;
  final String season;
  final String? format;
  final List<String> genres;
  final int? duration;
  final int? episodes;
  final String imageUrl;
  final String? listStatus;
  final int popularity;
  final bool isAdult;
}
