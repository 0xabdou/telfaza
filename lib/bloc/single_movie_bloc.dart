import 'package:rxdart/rxdart.dart';
import 'package:telfaza/bloc/bloc_base.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/tmdb_api.dart';

class SingleMovieBloc extends BaseBloc {
  // subjects
  BehaviorSubject<Movie> _movieReqController = BehaviorSubject<Movie>();

  Sink<Movie> get inMovie => _movieReqController.sink;

  BehaviorSubject<Movie> _movieResController = BehaviorSubject<Movie>();

  Stream<Movie> get outMovie => _movieResController.stream;

  // init
  SingleMovieBloc() {
    _movieReqController.stream
        .where((movie) => movie.state != MovieState.complete)
        .listen(_handleMovie);
  }

  // handling
  void _handleMovie(Movie movie) async {
    api.getMovieDetailsById(movie.id).then((details) {
      movie.addDetails(details);
      _movieResController.add(movie);
    }).catchError((error) => print('Can\t handle a single movie'));
  }

  @override
  void dispose() {
    _movieReqController.close();
    _movieResController.close();
  }
}
