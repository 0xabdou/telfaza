import 'dart:async';

import 'package:telfaza/models/movie.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telfaza/services/tmdb_api.dart';

import 'bloc_base.dart';

class MoviesBloc extends BaseBloc {
  // data collections
  final _topRatedFetchedPages = <int, List<Movie>>{};
  Set<int> _topRatedPagesBeingFetched = Set<int>();

  final _popularFetchedPages = <int, List<Movie>>{};
  Set<int> _popularPagesBeingFetched = Set<int>();

  final _nowPlayingFetchedPages = <int, List<Movie>>{};
  Set<int> _nowPlayingPagesBeingFetched = Set<int>();

  // subjects
  PublishSubject<int> _topRatedIndexController = PublishSubject<int>();
  Sink<int> get inTopRatedIndex => _topRatedIndexController.sink;
  Stream<int> get _outTopRatedIndex => _topRatedIndexController.stream;

  BehaviorSubject<List<Movie>> _topRatedController =
      BehaviorSubject<List<Movie>>.seeded([]);
  Stream<List<Movie>> get outTopRated => _topRatedController.stream;
  Sink<List<Movie>> get _inTopRated => _topRatedController.sink;

  PublishSubject<int> _popularIndexController = PublishSubject<int>();
  Sink<int> get inPopularIndex => _popularIndexController.sink;
  Stream<int> get _outPopularIndex => _popularIndexController.stream;

  BehaviorSubject<List<Movie>> _popularController =
      BehaviorSubject<List<Movie>>.seeded([]);
  Stream<List<Movie>> get outPopular => _popularController.stream;
  Sink<List<Movie>> get _inPopular => _popularController.sink;

  PublishSubject<int> _nowPlayingIndexController = PublishSubject<int>();
  Sink<int> get inNowPlayingIndex => _nowPlayingIndexController.sink;
  Stream<int> get _outNowPlayingIndex => _nowPlayingIndexController.stream;

  BehaviorSubject<List<Movie>> _nowPlayingController =
      BehaviorSubject<List<Movie>>.seeded([]);
  Stream<List<Movie>> get outNowPlaying => _nowPlayingController.stream;
  Sink<List<Movie>> get _inNowPlaying => _nowPlayingController.sink;

  StreamController<Null> _refreshController = StreamController<Null>();
  Sink<bool> get inRefresh => _refreshController.sink;

  // init
  MoviesBloc() {
    _outTopRatedIndex.listen((index) => _handleIndex(index, PageType.topRated));
    _outPopularIndex.listen((index) => _handleIndex(index, PageType.popular));
    _outNowPlayingIndex
        .listen((index) => _handleIndex(index, PageType.nowPlaying));
    _refreshController.stream.listen((_) {
      _refresh();
    });
  }

  // handling
  Future<Null> _handleIndex(int index, PageType type) async {
    int page = index ~/ TmdbApi.moviePerPage + 1;
    if (_shouldNotFetch(page, type)) return;
    switch (type) {
      case PageType.topRated:
        _topRatedPagesBeingFetched.add(page);
        break;
      case PageType.popular:
        _popularPagesBeingFetched.add(page);
        break;
      case PageType.nowPlaying:
        _nowPlayingPagesBeingFetched.add(page);
        break;
    }
    api
        .getMoviePageByType(page, type)
        .then((movies) => _handleFetchedPage(movies, page, type))
        .catchError((e) {
      print('Can\'t handle index');
    });
  }

  void _refresh() {
    var bf;
    bf = _topRatedPagesBeingFetched.toList();
    for (int i in bf) {
      _topRatedPagesBeingFetched.remove(i);
      inTopRatedIndex.add(i);
    }
    bf = _popularPagesBeingFetched.toList();
    for (int i in bf) {
      _popularPagesBeingFetched.remove(i);
      inPopularIndex.add(i);
    }
    bf = _nowPlayingPagesBeingFetched.toList();
    for (int i in bf) {
      _nowPlayingPagesBeingFetched.remove(i);
      inNowPlayingIndex.add(i);
    }
  }

  void _handleFetchedPage(List<Movie> movies, int page, PageType type) {
    if (movies == null) return;
    Map<int, List<Movie>> fetchedPages;
    switch (type) {
      case PageType.topRated:
        fetchedPages = _topRatedFetchedPages;
        break;
      case PageType.popular:
        fetchedPages = _popularFetchedPages;
        break;
      case PageType.nowPlaying:
        fetchedPages = _nowPlayingFetchedPages;
        break;
    }
    fetchedPages[page] = movies;
    List<int> indexes = fetchedPages.keys.toList();
    indexes.sort((a, b) => a.compareTo(b));
    int min = indexes[0];
    int max = indexes[indexes.length - 1];

    // do not notify unless at least the first page was fetched
    if (min != 1) return;

    List<Movie> pageMovies = [];
    for (int i = 1; i <= max; i++) {
      // stop as soon as there is a hole
      if (!fetchedPages.containsKey(i)) break;
      pageMovies.addAll(fetchedPages[i]);
    }

    // remove page from set
    // notify listeners
    switch (type) {
      case PageType.topRated:
        _topRatedPagesBeingFetched.remove(page);
        _inTopRated.add(pageMovies);
        break;
      case PageType.popular:
        _popularPagesBeingFetched.remove(page);
        _inPopular.add(pageMovies);
        break;
      case PageType.nowPlaying:
        _nowPlayingPagesBeingFetched.remove(page);
        _inNowPlaying.add(pageMovies);
        break;
    }
  }

  bool _shouldNotFetch(int page, PageType type) {
    switch (type) {
      case PageType.topRated:
        return _topRatedFetchedPages.containsKey(page) ||
            _topRatedPagesBeingFetched.contains(page);
      case PageType.popular:
        return _popularFetchedPages.containsKey(page) ||
            _popularPagesBeingFetched.contains(page);
      case PageType.nowPlaying:
        return _nowPlayingFetchedPages.containsKey(page) ||
            _nowPlayingPagesBeingFetched.contains(page);
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _topRatedController.close();
    _topRatedIndexController.close();
    _popularController.close();
    _popularIndexController.close();
    _nowPlayingController.close();
    _nowPlayingIndexController.close();
    _refreshController.close();
  }
}
