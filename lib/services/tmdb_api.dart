import 'dart:io';
import 'package:telfaza/bloc/connectivity_bloc.dart';
import 'package:telfaza/models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:telfaza/services/parameters_names.dart';

class TmdbApi {
  static const moviePerPage = 20;
  static final _exception = Exception('JSON is null');

  static const _kApiKey = 'a3090b365abe8b3e30f6901dd90a9143';
  static const _kBaseUrl = 'api.themoviedb.org';
  static const _kDefaultLang = 'en-US';

  String _imagesBaseUrl;
  List<String> _posterSizes;

  ConnectivityBloc bloc;

  Future<List<Movie>> discover({
    Map<String, String> params,
    int page,
  }) async {
    await _requestImagesBaseUrl();

    params.addAll({
      kParamPage: '$page',
      kParamApiKey: _kApiKey,
      kParamVoteCountGte: '50',
    });

    final uri = Uri.https(
      _kBaseUrl,
      '/3/discover/movie',
      params,
    );
    final jsonRes = await _get(uri);
    if (jsonRes == null) throw _exception;
    return _moviesListFromJson(jsonRes);
  }

  Future<List<Movie>> searchMovie(String query, int index) async {
    await _requestImagesBaseUrl();

    final uri = Uri.https(
      _kBaseUrl,
      '/3/search/movie',
      <String, String>{
        kParamApiKey: _kApiKey,
        kParamLang: _kDefaultLang,
        kParamPage: '$index',
        kParamIncAdult: 'false',
        kParamQuery: Uri.encodeQueryComponent(query)
      },
    );

    final jsonRes = await _get(uri);
    if (jsonRes == null) throw _exception;
    return _moviesListFromJson(jsonRes);
  }

  Future<List<Movie>> getMoviePageByType(int page, PageType type) async {
    await _requestImagesBaseUrl();

    String typeStr;
    switch (type) {
      case PageType.topRated:
        typeStr = 'top_rated';
        break;
      case PageType.popular:
        typeStr = 'popular';
        break;
      case PageType.nowPlaying:
        typeStr = 'now_playing';
        break;
      default:
        return null;
    }

    var uri = Uri.https(
      _kBaseUrl,
      '/3/movie/$typeStr',
      <String, String>{
        kParamApiKey: _kApiKey,
        kParamPage: '$page',
        kParamLang: 'en-US'
      },
    );

    var resJson = await _get(uri);

    if (resJson == null) throw _exception;
    return _moviesListFromJson(resJson);
  }

  Future<Map<String, dynamic>> getMovieJsonById(int id) async {
    await _requestImagesBaseUrl();

    final Uri uri = Uri.https(
      _kBaseUrl,
      '/3/movie/$id',
      <String, String>{
        kParamApiKey: _kApiKey,
        kParamLang: _kDefaultLang,
        kParamAppToRes: 'videos',
      },
    );
    final resJson = _get(uri);
    if (resJson == null) throw _exception;
    return resJson;
  }

  Future<Movie> getMovieById(int id) async {
    final json = await getMovieJsonById(id);
    return Movie.fromJSON(json);
  }
  Future<Movie> getMovieDetailsById(int id) async {
    final json = await getMovieJsonById(id);
    return Movie.detailsFromJson(json);
  }


  List<Movie> _moviesListFromJson(Map<String, dynamic> json) {
    List<Movie> movies = [];
    for (var result in json['results']) {
      movies.add(Movie.essentialFromJson(result));
    }
    return movies;
  }

  String getImageUrl(String path, int size) {
    return _imagesBaseUrl != null
        ? '$_imagesBaseUrl${_posterSizes[size]}$path'
        : null;
  }

  Future<void> _requestImagesBaseUrl() async {
    if (_imagesBaseUrl != null) return;

    var uri = Uri.https(
      _kBaseUrl,
      '/3/configuration',
      <String, String>{kParamApiKey: _kApiKey},
    );

    var response = await _get(uri);
    if (response != null) {
      final images = response['images'];
      _imagesBaseUrl = images['base_url'];
      _posterSizes = images['poster_sizes'].cast<String>();
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      http.Response response = await http.get(uri).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Timed out');
          return null;
        },
      );
      if (response == null) {
        bloc.inConnectivity.add(false);
        return null;
      } else if (response.statusCode == 200) {
        var json = convert.jsonDecode(response.body);
        return json;
      } else {
        bloc.inConnectivity.add(false);
        print('_get Error ${response.statusCode}');
        return null;
      }
    } on SocketException catch (_) {
      bloc.inConnectivity.add(false);
      print('No intenret');
      return null;
    }
  }

  Future<String> getVideo(int id) async {
    String ip = await _getIPAddressUsingAwait();
    final uri = Uri.https(
      'videospider.in',
      '/getticket.php',
      <String, String>{
        'key': 'o4035o9fX7KjMYHB',
        'secret_key': 'cf4pyutxqhlt0rny1uhz3ypx4g3cv8',
        'video_id': '$id',
        'ip': ip,
      },
    );
    final ticket = await http.get(uri);
    final uri2 = Uri.https(
      'videospider.in',
      '/getvideo',
      <String, String>{
        'key': 'o4035o9fX7KjMYHB',
        'video_id': '$id',
        'tmdb': '1',
        'ticket': ticket.body,
      },
    );
    //final video = await http.get(uri2);

    return uri2.toString();
  }

  Future<String> _getIPAddressUsingAwait() async {
    var response = await http.read('https://httpbin.org/ip');
    var ip = convert.jsonDecode(response)['origin'];
    return ip;
  }
}

TmdbApi api = TmdbApi();

enum PageType {
  topRated,
  popular,
  nowPlaying,
}
