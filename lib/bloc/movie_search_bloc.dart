import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:telfaza/bloc/bloc_base.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/tmdb_api.dart';

class MovieSearchBloc extends BaseBloc {
  String currentQuery = '';

  // data
  Map<int, List<Movie>> _fetchedPages = {};
  Set<int> _pagesBeingFetched = Set<int>();

  // subjects
  final StreamController<String> _queryController = StreamController<String>();

  Sink<String> get inQuery => _queryController.sink;

  Stream<String> get _outQuery => _queryController.stream;

  final StreamController<int> _indexController = StreamController<int>();

  Sink<int> get inIndex => _indexController.sink;

  Stream<int> get _outIndex => _indexController.stream;

  final BehaviorSubject<List<Movie>> _moviesController =
      BehaviorSubject<List<Movie>>.seeded([]);

  Sink<List<Movie>> get _inMovies => _moviesController.sink;

  Stream<List<Movie>> get outMovies => _moviesController.stream;

  // init
  MovieSearchBloc() {
    _outQuery.listen(_handleQuery);
    _outIndex.listen(_handleIndex);
  }

  // handling
  void _handleQuery(String query) async {
    _reset();
    currentQuery = query;
    _pagesBeingFetched.add(1);
    api
        .searchMovie(query, 1)
        .then((movies) => _handleFetchedPage(movies, 1))
        .catchError((e) => print('Can\'t handle query'));
  }

  void _handleIndex(int index) async {
    if (currentQuery.isEmpty) return;

    final int pageIndex = index ~/ TmdbApi.moviePerPage + 1;
    if (_shouldNotFetch(pageIndex)) return;

    api
        .searchMovie(currentQuery, pageIndex)
        .then((movies) => _handleFetchedPage(movies, pageIndex))
        .catchError((e) => print('Can\'t handle index'));
  }

  void _handleFetchedPage(List<Movie> movies, int index) {
    _fetchedPages[index] = movies;
    _pagesBeingFetched.remove(index);

    final fetchedIndexes = _fetchedPages.keys.toList();
    final min = fetchedIndexes[0];
    final max = fetchedIndexes[fetchedIndexes.length - 1];
    if (min != 1) return;

    final List<Movie> allMovies = [];
    for (int i = 1; i <= max; i++) {
      if (!fetchedIndexes.contains(i)) break;
      allMovies.addAll(_fetchedPages[i]);
    }
    _inMovies.add(allMovies);
  }

  bool _shouldNotFetch(int index) {
    return _fetchedPages.containsKey(index) ||
        _pagesBeingFetched.contains(index);
  }

  // reset data
  void _reset() {
    _fetchedPages = {};
    _pagesBeingFetched = Set<int>();
  }

  @override
  void dispose() {
    print('closeed');
    _queryController.close();
    _moviesController.close();
    _indexController.close();
  }
}
