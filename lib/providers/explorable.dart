import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/providers/media_group_provider.dart';

//Manages all browsable media, genres, tags and all the filters
class Explorable with ChangeNotifier implements MediaGroupProvider {
  static const KEY_STATUS_IN = 'status_in';
  static const KEY_STATUS_NOT_IN = 'status_not_in';
  static const KEY_FORMAT_IN = 'format_in';
  static const KEY_FORMAT_NOT_IN = 'format_not_in';
  static const KEY_ID_NOT_IN = 'id_not_in';
  static const KEY_GENRE_IN = 'genre_in';
  static const KEY_GENRE_NOT_IN = 'genre_not_in';
  static const KEY_TAG_IN = 'tag_in';
  static const KEY_TAG_NOT_IN = 'tag_not_in';

  static const String _url = 'https://graphql.anilist.co';
  Map<String, String> _headers;

  void init(Map<String, String> headers) {
    _headers = headers;
  }

  Browsable _type = Browsable.anime;
  bool _isLoading = false;
  List<BrowseResult> _results;
  List<String> _genres;
  Tuple<List<String>, List<String>> _tags;
  Map<String, dynamic> _filters = {
    'page': 1,
    'perPage': 30,
    'type': 'ANIME',
    'sort': describeEnum(MediaSort.TRENDING_DESC),
    KEY_ID_NOT_IN: [],
  };

  Browsable get type {
    return _type;
  }

  set type(Browsable value) {
    if (value == null) return;
    _type = value;

    if (value == Browsable.anime) _filters['type'] = 'ANIME';
    if (value == Browsable.manga) _filters['type'] = 'MANGA';

    _filters.remove(KEY_FORMAT_IN);
    _filters.remove(KEY_FORMAT_NOT_IN);
    fetchData();
  }

  @override
  String get search {
    return _filters['search'];
  }

  @override
  set search(String searchValue) {
    if (searchValue == null || searchValue.trim() == '') {
      _filters.remove('search');
    } else {
      searchValue = searchValue.trim();
      if (searchValue == _filters['search']) return;
      _filters['search'] = searchValue;
    }

    fetchData();
  }

  String get sort {
    return _filters['sort'];
  }

  set sort(String mediaSort) {
    _filters['sort'] = mediaSort;
    fetchData();
  }

  @override
  bool get isLoading {
    return _isLoading;
  }

  List<BrowseResult> get results {
    return [..._results];
  }

  List<String> get genres {
    return [..._genres];
  }

  Tuple<List<String>, List<String>> get tags {
    return _tags;
  }

  List<String> getFilterWithKey(String key) {
    if (_filters.containsKey(key)) {
      return [..._filters[key]];
    }
    return [];
  }

  void setGenreTagFilters({
    List<String> newStatusIn,
    List<String> newStatusNotIn,
    List<String> newFormatIn,
    List<String> newFormatNotIn,
    List<String> newGenreIn,
    List<String> newGenreNotIn,
    List<String> newTagIn,
    List<String> newTagNotIn,
  }) {
    if (newStatusIn != null && newStatusIn.length == 0) {
      _filters.remove(KEY_STATUS_IN);
    } else {
      _filters[KEY_STATUS_IN] = newStatusIn;
    }

    if (newStatusNotIn != null && newStatusNotIn.length == 0) {
      _filters.remove(KEY_STATUS_NOT_IN);
    } else {
      _filters[KEY_STATUS_NOT_IN] = newStatusNotIn;
    }

    if (newFormatIn != null && newFormatIn.length == 0) {
      _filters.remove(KEY_FORMAT_IN);
    } else {
      _filters[KEY_FORMAT_IN] = newFormatIn;
    }

    if (newFormatNotIn != null && newFormatNotIn.length == 0) {
      _filters.remove(KEY_FORMAT_NOT_IN);
    } else {
      _filters[KEY_FORMAT_NOT_IN] = newFormatNotIn;
    }

    if (newGenreIn != null && newGenreIn.length == 0) {
      _filters.remove(KEY_GENRE_IN);
    } else {
      _filters[KEY_GENRE_IN] = newGenreIn;
    }

    if (newGenreNotIn != null && newGenreNotIn.length == 0) {
      _filters.remove(KEY_GENRE_NOT_IN);
    } else {
      _filters[KEY_GENRE_NOT_IN] = newGenreNotIn;
    }

    if (newTagIn != null && newTagIn.length == 0) {
      _filters.remove(KEY_TAG_IN);
    } else {
      _filters[KEY_TAG_IN] = newTagIn;
    }

    if (newTagNotIn != null && newTagNotIn.length == 0) {
      _filters.remove(KEY_TAG_NOT_IN);
    } else {
      _filters[KEY_TAG_NOT_IN] = newTagNotIn;
    }
    fetchData();
  }

  bool areFiltersActive() {
    return _filters.containsKey(KEY_STATUS_IN) ||
        _filters.containsKey(KEY_STATUS_NOT_IN) ||
        _filters.containsKey(KEY_FORMAT_IN) ||
        _filters.containsKey(KEY_FORMAT_NOT_IN) ||
        _filters.containsKey(KEY_GENRE_IN) ||
        _filters.containsKey(KEY_GENRE_NOT_IN) ||
        _filters.containsKey(KEY_TAG_IN) ||
        _filters.containsKey(KEY_TAG_NOT_IN);
  }

  void clearGenreTagFilters({bool fetch = true}) {
    _filters.remove(KEY_STATUS_IN);
    _filters.remove(KEY_STATUS_NOT_IN);
    _filters.remove(KEY_FORMAT_IN);
    _filters.remove(KEY_FORMAT_NOT_IN);
    _filters.remove(KEY_GENRE_IN);
    _filters.remove(KEY_GENRE_NOT_IN);
    _filters.remove(KEY_TAG_IN);
    _filters.remove(KEY_TAG_NOT_IN);
    if (fetch) fetchData();
  }

  @override
  void clear() {
    clearGenreTagFilters(fetch: false);
    _filters.remove('search');
    fetchData();
  }

  void addPage() {
    _filters['page']++;
    fetchData(clean: false);
  }

  //Fetches meida based on the set filters
  @override
  Future<void> fetchData({bool clean = true}) async {
    _isLoading = true;
    if (_results != null) notifyListeners();

    if (clean) {
      _filters[KEY_ID_NOT_IN] = [];
      _filters['page'] = 1;
    }

    final currentType = _type;
    String request;
    if (currentType == Browsable.anime || currentType == Browsable.manga) {
      final query = '''
      query Browse(\$page: Int, \$perPage: Int, \$id_not_in: [Int], 
          \$sort: [MediaSort], \$type: MediaType, \$search: String,
          ${_filters.containsKey(KEY_STATUS_IN) ? '\$status_in: [MediaStatus],' : ''}
          ${_filters.containsKey(KEY_STATUS_NOT_IN) ? '\$status_not_in: [MediaStatus],' : ''}
          ${_filters.containsKey(KEY_FORMAT_IN) ? '\$format_in: [MediaFormat],' : ''}
          ${_filters.containsKey(KEY_FORMAT_NOT_IN) ? '\$format_not_in: [MediaFormat],' : ''}
          \$genre_in: [String], \$genre_not_in: [String], \$tag_in: [String], 
          \$tag_not_in: [String]) {
        Page(page: \$page, perPage: \$perPage) {
          media(id_not_in: \$id_not_in, sort: \$sort, type: \$type, 
          search: \$search,
          ${_filters.containsKey(KEY_STATUS_IN) ? 'status_in: \$status_in,' : ''}
          ${_filters.containsKey(KEY_STATUS_NOT_IN) ? 'status_not_in: \$status_not_in,' : ''}
          ${_filters.containsKey(KEY_FORMAT_IN) ? 'format_in: \$format_in,' : ''}
          ${_filters.containsKey(KEY_FORMAT_NOT_IN) ? 'format_not_in: \$format_not_in,' : ''}
          genre_in: \$genre_in, genre_not_in: \$genre_not_in, 
          tag_in: \$tag_in, tag_not_in: \$tag_not_in) {
            id
            title {userPreferred}
            coverImage {large}
          }
        }
      }
    ''';

      request = json.encode({
        'query': query,
        'variables': _filters,
      });
    } else if (currentType == Browsable.characters ||
        currentType == Browsable.staff) {
      final bool char = currentType == Browsable.characters;
      final query = '''
          query Browse(\$page: Int, \$perPage: Int, \$id_not_in: [Int], 
            \$sort: [${char ? 'CharacterSort' : 'StaffSort'}], 
            \$search: String) {
              Page(page: \$page, perPage: \$perPage) {
                ${char ? 'characters' : 'staff'}(id_not_in: \$id_not_in, 
                sort: \$sort, search: \$search) {
                  id
                  name {full}
                  image {large}
                }
              }
            }
        ''';

      request = json.encode({
        'query': query,
        'variables': {
          'page': _filters['page'],
          'perPage': _filters['perPage'],
          'id_not_in': _filters[KEY_ID_NOT_IN],
          'search': _filters['search'],
          'sort': 'FAVOURITES_DESC',
        },
      });
    }

    final response = await post(_url, body: request, headers: _headers);

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (clean) _results = [];

    if (currentType == Browsable.anime || _type == Browsable.manga) {
      for (final m in body['data']['Page']['media'] as List<dynamic>) {
        _results.add(BrowseResult(
          id: m['id'],
          title: m['title']['userPreferred'],
          imageUrl: m['coverImage']['large'],
        ));
        (_filters[KEY_ID_NOT_IN] as List<dynamic>).add(m['id']);
      }
    } else if (currentType == Browsable.characters ||
        currentType == Browsable.staff) {
      for (final c in body['data']['Page']
              [currentType == Browsable.characters ? 'characters' : 'staff']
          as List<dynamic>) {
        _results.add(BrowseResult(
          id: c['id'],
          title: c['name']['full'],
          imageUrl: c['image']['large'],
        ));
        (_filters[KEY_ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  //Fetches genres and tags
  Future<void> fetchInitial() async {
    _isLoading = true;

    final request = json.encode({
      'query': r'''
        query Filters {
          GenreCollection
          MediaTagCollection {
            name
            description
          }
          Page(page: 1, perPage: 30) {
            media(sort: TRENDING_DESC, type: ANIME) {
              id
              title {
                userPreferred
              }
              coverImage {
                large
              }
            }
          }
        }
      ''',
    });

    final response = await post(_url, body: request, headers: _headers);
    final body = json.decode(response.body)['data'];

    _genres = (body['GenreCollection'] as List<dynamic>)
        .map((g) => g.toString())
        .toList();

    _tags = Tuple([], []);
    for (final tag in body['MediaTagCollection']) {
      _tags.item1.add(tag['name']);
      _tags.item2.add(tag['description']);
    }

    _results = [];

    for (final m in body['Page']['media'] as List<dynamic>) {
      _results.add(BrowseResult(
        id: m['id'],
        title: m['title']['userPreferred'],
        imageUrl: m['coverImage']['large'],
      ));
      (_filters[KEY_ID_NOT_IN] as List<dynamic>).add(m['id']);
    }

    _isLoading = false;
  }
}