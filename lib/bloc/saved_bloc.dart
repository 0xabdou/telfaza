import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telfaza/bloc/bloc_base.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/db_service.dart';
import 'package:telfaza/services/tmdb_api.dart';

class SavedBloc extends BaseBloc {
  final DBService _dbService;

  List<Movie> _favorites;

  SavedBloc(this._dbService);

  BehaviorSubject<List<Movie>> _addFavorite = BehaviorSubject<List<Movie>>.seeded([]);
  Sink<List<Movie>> get inFavorites => _addFavorite.sink;
  Stream<List<Movie>> get outFavorites => _dbService.outFavorites.asyncMap(convert);

  Future<List<Movie>> convert(QuerySnapshot snapshot) async {
    final List<Future<Movie>> futures = [];
    for (var doc in snapshot.documents)
      futures.add(api.getMovieById(doc['movie']));
    _favorites = await Future.wait(futures);
    return _favorites;
  }

  @override
  void dispose() {
    _addFavorite.close();
  }

}