import 'package:flutter/material.dart';
import 'package:otraku/pages/loading_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';
import 'enums/auth_enum.dart';
import 'pages/auth_page.dart';
import 'providers/media_item.dart';
import 'providers/auth.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ProxyProvider<Auth, MediaItem>(
          update: (_, auth, __) => MediaItem(auth.headers),
        ),
        ChangeNotifierProxyProvider<Auth, ExplorableMedia>(
          create: (_) => ExplorableMedia(),
          update: (_, auth, explorable) => explorable..init(auth.headers),
        ),
        ChangeNotifierProxyProvider<Auth, AnimeCollection>(
          create: (_) => AnimeCollection(),
          update: (_, auth, collection) => collection
            ..init(
              headers: auth.headers,
              userId: auth.userId,
              mediaListSort: auth.getSort(ofAnime: true),
              hasSplitCompletedList: auth.hasSplitCompletedList(ofAnime: true),
              scoreFormat: auth.scoreFormat,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, MangaCollection>(
          create: (_) => MangaCollection(),
          update: (_, auth, collection) => collection
            ..init(
              headers: auth.headers,
              userId: auth.userId,
              mediaListSort: auth.getSort(ofAnime: false),
              hasSplitCompletedList: auth.hasSplitCompletedList(ofAnime: false),
              scoreFormat: auth.scoreFormat,
            ),
        ),
        ChangeNotifierProvider<ViewConfig>(
          create: (_) => ViewConfig(),
        ),
        ChangeNotifierProvider<Design>(
          create: (_) => Design(),
        ),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otraku',
      theme: Provider.of<Design>(context).theme,
      home: Consumer<Design>(
        builder: (_, palette, themeChild) => FutureBuilder(
          future: palette.theme == null
              ? palette.init()
              : Future.delayed(const Duration(seconds: 0)),
          builder: (_, snapshotTheme) {
            if (snapshotTheme.connectionState == ConnectionState.waiting) {
              return themeChild;
            }

            return Consumer<Auth>(
              builder: (_, auth, childAuth) => FutureBuilder(
                future: auth.status == null
                    ? auth.validateAccessToken()
                    : Future.delayed(const Duration(seconds: 0)),
                builder: (_, snapshotAuth) {
                  if (snapshotAuth.connectionState == ConnectionState.waiting) {
                    return childAuth;
                  }

                  if (auth.status != AuthStatus.authorised) {
                    return const AuthPage();
                  }

                  return LoadingPage();
                },
              ),
              child: Scaffold(
                body: const Center(child: BlossomLoader()),
              ),
            );
          },
        ),
        child: const Scaffold(
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
