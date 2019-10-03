import 'package:collection/collection.dart';
import 'package:quiver/core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telfaza/bloc/bloc_base.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/parameters_names.dart';
import 'package:telfaza/services/tmdb_api.dart';

class DiscoverBloc extends BaseBloc {
  // filters
  Filters filters = Filters();

  //
  final Map<int, List<Movie>> _fetchedPages = {};
  final Set<int> _pagesBeingFetched = Set<int>();

  final PublishSubject<PageType> _modeSubject = PublishSubject<PageType>();

  Stream<PageType> get _outMode => _modeSubject.stream;

  Sink<PageType> get inMode => _modeSubject.sink;

  final PublishSubject<Range> _yearsSubject = PublishSubject<Range>();

  Stream<Range> get _outYears => _yearsSubject.stream;

  Sink<Range> get inYears => _yearsSubject.sink;

  final PublishSubject<List<int>> _genresSubject = PublishSubject<List<int>>();

  Stream<List<int>> get _outGenres => _genresSubject.stream;

  Sink<List<int>> get inGenres => _genresSubject.sink;

  final PublishSubject<Null> _applySubject = PublishSubject<Null>();

  Stream<Null> get outApply => _applySubject.stream;

  Sink<Null> get inApply => _applySubject.sink;

  final PublishSubject<int> _indexSubject = PublishSubject<int>();

  Stream<int> get _outIndex => _indexSubject.stream;

  Sink<int> get inIndex => _indexSubject.sink;

  final BehaviorSubject<List<Movie>> _moviesSubject =
      BehaviorSubject<List<Movie>>.seeded([]);

  Stream<List<Movie>> get outMovies => _moviesSubject.stream;

  Sink<List<Movie>> get _inMovies => _moviesSubject.sink;

  DiscoverBloc() {
    _outMode.listen((mode) => filters.mode = mode);
    _outYears.listen((years) => filters.years = years);
    _outGenres.listen((genres) => filters.genres = genres);
    outApply.listen((_) => _applyFilters());
    _outIndex.listen((index) => _handleIndex(index));
  }

  void _applyFilters() async {
    api
        .discover(
          params: _getParams(),
          page: 1,
        )
        .then((movies) => _handleFetchedPage(movies, 1))
        .catchError((e) => print('Can\'t discover page'));
  }

  Map<String, String> _getParams() {
    final Map<String, String> params = {};

    String yearGte = '${(filters.years.begin).toStringAsFixed(0)}-12-31';
    String yearLte = '${(filters.years.end).toStringAsFixed(0)}-12-31';
    String genres = _getGenres();
    params[kParamSortBy] = _getMode();
    params[kParamPrimaryReleaseDateGte] = yearGte;
    params[kParamPrimaryReleaseDateLte] = yearLte;
    if (genres != null) params[kParamWithGenres] = genres;

    return params;
  }

  String _getMode() {
    switch (filters.mode) {
      case PageType.popular:
        return 'popularity.desc';
      case PageType.nowPlaying:
        return 'release_date.desc';
      case PageType.topRated:
        return 'vote_average.desc';
    }
    return null;
  }

  String _getGenres() {
    final genresList = filters.genres;
    if (genresList == null || genresList.isEmpty) return null;

    String genres = '';
    for (var genre in genresList) {
      if (genres.isEmpty) genres = '$genre';
      genres = '$genres,$genre';
    }
    return genres;
  }

  Future<Null> _handleIndex(int index) async {
    int page = index ~/ TmdbApi.moviePerPage + 1;
    if (_shouldNotFetch(page)) return;

    _pagesBeingFetched.add(page);

    api
        .discover(
          params: _getParams(),
          page: page,
        )
        .then((movies) => _handleFetchedPage(movies, page))
        .catchError((e) {
      print('Can\'t handle index');
    });
  }

  void _handleFetchedPage(List<Movie> movies, int page) {
    if (movies == null) return;

    _fetchedPages[page] = movies;
    List<int> indexes = _fetchedPages.keys.toList();
    indexes.sort((a, b) => a.compareTo(b));
    int min = indexes[0];
    int max = indexes[indexes.length - 1];

    // do not notify unless at least the first page was fetched
    if (min != 1) return;

    List<Movie> pageMovies = [];
    for (int i = 1; i <= max; i++) {
      // stop as soon as there is a hole
      if (!_fetchedPages.containsKey(i)) break;
      pageMovies.addAll(_fetchedPages[i]);
    }

    // remove page from set
    // notify listeners
    _pagesBeingFetched.remove(page);
    _inMovies.add(pageMovies);
  }

  bool _shouldNotFetch(int page) {
    return _fetchedPages.containsKey(page) || _pagesBeingFetched.contains(page);
  }

  @override
  void dispose() {
    _modeSubject.close();
    _yearsSubject.close();
    _genresSubject.close();
    _moviesSubject.close();
    _applySubject.close();
    _indexSubject.close();
  }
}

class Range {
  final double begin;
  final double end;

  const Range({this.begin, this.end});

  @override
  bool operator ==(o) {
    return this.begin == o.begin && this.end == o.end;
  }

  @override
  int get hashCode {
    return hash2(begin, end);
  }

  @override
  String toString() {
    return '$begin $end';
  }
}

class Filters {
  PageType mode;
  List<int> genres;
  Range years;

  Filters({this.mode, this.genres = const [], this.years});

  Filters.copy(Filters f) {
    this.mode = f.mode;
    this.genres = f.genres;
    this.years = f.years;
  }

  @override
  bool operator ==(o) {
    if (o == null) {
      return false;
    }
    o.genres.sort();
    this.genres.sort();

    return o is Filters &&
        this.mode == o.mode &&
        ListEquality().equals(this.genres, o.genres) &&
        this.years == o.years;
  }

  @override
  int get hashCode {
    return hash3(mode.hashCode, genres.hashCode, years.hashCode);
  }

  @override
  String toString() {
    return '$mode $years $genres';
  }
}
