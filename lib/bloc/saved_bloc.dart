import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telfaza/bloc/bloc_base.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/db_service.dart';
import 'package:telfaza/services/tmdb_api.dart';

class SavedBloc extends BaseBloc {
  final DBService _dbService;

  StreamSubscription _sub1;
  StreamSubscription _sub2;
  bool _shouldRes = true;
  List<Movie> _favorites = [];
  List<Movie> _laters = [];

  BehaviorSubject<List<Movie>> _favoritesSubject =
      BehaviorSubject<List<Movie>>.seeded([]);
  Stream<List<Movie>> get outFavorites => _favoritesSubject.stream;
  Sink<List<Movie>> get _inFavorites => _favoritesSubject.sink;

  BehaviorSubject<List<Movie>> _latersSubject =
      BehaviorSubject<List<Movie>>.seeded([]);
  Stream<List<Movie>> get outLaters => _latersSubject.stream;
  Sink<List<Movie>> get _inLaters => _latersSubject.sink;

  BehaviorSubject<Map<String, dynamic>> _addFavoriteSubject =
      BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get _outAddFavorites =>
      _addFavoriteSubject.stream;
  Sink<Map<String, dynamic>> get inAddFavorites => _addFavoriteSubject.sink;

  BehaviorSubject<Map<String, dynamic>> _addLatersSubject =
      BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get _outAddLaters => _addLatersSubject.stream;
  Sink<Map<String, dynamic>> get inAddLaters => _addLatersSubject.sink;

  BehaviorSubject<bool> _restartSubject = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get _outRestart => _restartSubject.stream;
  Sink<bool> get inRestart => _restartSubject.sink;

  SavedBloc(this._dbService) {
    _outRestart.listen((b) {
      if (!b) {
        _shouldRes = true;
      } else {
        if (_shouldRes) subscribe();
        _shouldRes = false;
      }
    });
    _outAddFavorites.listen((event) {
      final Movie movie = event['movie'];
      if (event['add'] == 0) {
        _favorites.remove(movie);
        _dbService.removeFavorite(movie.id);
      } else {
        _favorites.add(movie);
        _dbService.addFavorite(movie.id);
      }
      _inFavorites.add(_favorites);
    });
    _outAddLaters.listen((event) {
      final Movie movie = event['movie'];
      if (event['add'] == 0) {
        _laters.remove(movie);
        _dbService.removeLater(movie.id);
      } else {
        _laters.add(movie);
        _dbService.addLater(movie.id);
      }
      _inLaters.add(_laters);
    });
  }

  void subscribe() {
    _sub1?.cancel();
    _sub2?.cancel();
    _dbService.outFavorites.then((stream) {
      _sub1 = stream.listen(convert1);
    });
    _dbService.outLaters.then((stream) {
      _sub2 = stream.listen(convert2);
    });
  }

  Future<List<Movie>> convert(QuerySnapshot snapshot) async {
    final List<Future<Movie>> futures = [];
    for (var doc in snapshot.documents)
      futures.add(api.getMovieById(doc['movie']));
    // if I directly assign the result to _favorites, I get the following error
    // when I try to add a movie to _favorites, I have no clue what's the reason
    //Unhandled Exception: type 'Movie' is not a subtype of type 'Null' of 'value'
    return await Future.wait(futures);
  }

  void convert1(QuerySnapshot snapshot) async {
    final res = await convert(snapshot);
    _favorites.clear();
    _favorites.addAll(res);
    _inFavorites.add(_favorites);
  }

  void convert2(QuerySnapshot snapshot) async {
    final res = await convert(snapshot);
    _laters.clear();
    _laters.addAll(res);
    _inLaters.add(_laters);
  }

  @override
  void dispose() {
    _favoritesSubject.close();
    _latersSubject.close();
    _addFavoriteSubject.close();
    _addLatersSubject.close();
    _restartSubject.close();
    _sub1.cancel();
    _sub2.cancel();
  }
}
