
class Movie {
  MovieState state;

  // essential
  int id;
  String title;
  String posterPath;
  String backdropPath;
  String releaseDate;
  double voteAverage;

  // details
  String overview;
  String homepage;
  int runtime;
  List<String> genres;
  String videoKey;

  Movie.essentialFromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    posterPath = json['poster_path'];
    backdropPath = json['backdrop_path'];
    releaseDate = json['release_date'];
    voteAverage = json['vote_average']?.toDouble();

    state = MovieState.essential;
  }

  Movie.detailsFromJson(Map<String, dynamic> json) {
    // overview
    overview = json['overview'];
    homepage = json['homepage'];
    runtime = json['runtime'];
    genres = [];
    for (var genre in json['genres']) {
      genres.add(genre['name']);
    }
    for (var video in json['videos']['results']) {
      if (video['site'] == 'YouTube') {
        videoKey = video['key'];
        break;
      }
    }

    state = MovieState.details;
  }

  factory Movie.fromJSON(Map<String, dynamic> json) {
    final movie = Movie.essentialFromJson(json);
    final details = Movie.detailsFromJson(json);
    movie.addDetails(details);
    return movie;
  }

  void addDetails(Movie details) {
    if (this.state != MovieState.essential ||
        details.state != MovieState.details) throw 'Incompatible states';

    this.overview = details.overview;
    this.homepage = details.homepage;
    this.runtime = details.runtime;
    this.genres = details.genres;
    this.videoKey = details.videoKey;

    this.state = MovieState.complete;
  }

  @override
  String toString() {
    switch (state) {
      case MovieState.essential:
        return 'state: $state, title: $title, poster_path: $posterPath, release_date: $releaseDate';
      case MovieState.details:
        return 'state: $state, overviw: ${overview.substring(0, 6)}, runtime: $runtime, vote: $voteAverage';
      case MovieState.complete:
        return 'state: $state, title: $title, poster_path: $posterPath, release_date: $releaseDate'
            ', overviw: $overview}, runtime: $runtime, vote: $voteAverage, homePage: $homepage';
      default:
        return 'Something\'s wrong with the type';
    }
  }

  bool operator ==(o) => o is Movie && id == o.id;
  int get hashCode => id.hashCode;
}

enum MovieState {
  essential,
  details,
  complete,
}
