import 'movie.dart';

class MoviePage {
  int page;
  int totalResults;
  int totalPages;
  List<Movie> results;

  MoviePage._();

  factory MoviePage.fromJson(Map<String, dynamic> json) {
    MoviePage mp = MoviePage._();
    mp.page = json['page'];
    mp.totalResults = json['total_results'];
    mp.totalPages = json['total_pages'];
    mp.results = _moviesListFromJson(json);

    return mp;
  }

  static List<Movie> _moviesListFromJson(Map<String, dynamic> json) {
    List<Movie> movies = [];
    for (var result in json['results']) {
      movies.add(Movie.essentialFromJson(result));
    }
    return movies;
  }
}
