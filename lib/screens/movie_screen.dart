import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/saved_bloc.dart';
import 'package:telfaza/bloc/single_movie_bloc.dart';
import 'package:telfaza/components/bottom_sheet_dragger.dart';
import 'package:telfaza/components/custom_bottom_sheet.dart';
import 'package:telfaza/components/text_overflow_scroll.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/style.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieScreen extends StatefulWidget {
  final Movie movie;

  const MovieScreen({
    @required this.movie,
  });

  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with TickerProviderStateMixin {
  final SingleMovieBloc bloc = SingleMovieBloc();

  final double coverHeightRation = 0.9;
  final double textOffset = 150.0;
  BottomSheetDragger _bottomSheetDragger;

  SavedBloc _savedBloc;
  AnimationController _controller;
  Animation _textAnimation;
  Animation _colorAnimation;
  double textAnimationValue = 0.0;
  double colorAnimationValue = 0.0;

  @override
  void initState() {
    super.initState();

    bloc.inMovie.add(widget.movie);

    _bottomSheetDragger = BottomSheetDragger();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 900,
      ),
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _colorAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    );

    _textAnimation.addListener(() {
      setState(() {
        textAnimationValue = _textAnimation.value;
      });
    });

    _colorAnimation.addListener(() {
      setState(() {
        colorAnimationValue = _colorAnimation.value;
      });
    });

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _savedBloc = Provider.of<SavedBloc>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Material(
        color: Colors.transparent,
        child: StreamBuilder<Movie>(
            stream: bloc.outMovie,
            initialData: widget.movie,
            builder: (context, snapshot) {
              final bool complete = snapshot.data.state == MovieState.complete;
              final genresList = snapshot.data.genres.toString();
              final String genres = complete
                  ? genresList.substring(1, genresList.length - 1)
                  : '';
              return Stack(
                children: [
                  CachedNetworkImage(
                    height: size.height * coverHeightRation,
                    fit: BoxFit.cover,
                    imageUrl: api.getImageUrl(
                          snapshot.data.posterPath,
                          complete ? 5 : 5,
                        ) ??
                        '',
                  ),
                  Opacity(
                    opacity: (colorAnimationValue * 2).clamp(0.0, 1.0),
                    child: Container(
                      height: size.height * coverHeightRation,
                      width: size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black,
                            Colors.transparent,
                            Colors.black,
                          ],
                          stops: [0, 0.5, 0.9],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: size.height * (coverHeightRation - 0.1),
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Transform(
                        transform: Matrix4.translationValues(
                          0.0,
                          textOffset * (1 - textAnimationValue),
                          0.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextOverflowScroll(
                              snapshot.data.title,
                              style: TextStyle(
                                fontSize: 40.0,
                              ),
                            ),
                            TextOverflowScroll(
                              genres,
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      actions: [
                        StreamBuilder<List<Movie>>(
                          stream: _savedBloc.outFavorites,
                          builder: (context, snapshot) {
                            final faved = snapshot.hasData && snapshot.data.contains(widget.movie);
                            return IconButton(
                              onPressed: () {
                                _savedBloc.inAddFavorites.add({'movie': widget.movie, 'add': faved ? 0 : 1});
                              },
                              icon: Icon(
                                faved ? Icons.favorite : Icons.favorite_border,
                                color: faved ? kSecondaryColor : Colors.white,
                              ),
                            );
                          }
                        )
                      ],
                    ),
                    backgroundColor: Colors.transparent,
                    body: Stack(
                      children: [
                        SizedBox(
                          height: size.height * (coverHeightRation - 0.25),
                          child: Center(
                            child: Opacity(
                              opacity: colorAnimationValue,
                              child: IconButton(
                                onPressed: () {
                                  if (widget.movie.videoKey == null)
                                    _snackIt('Video not available');
                                  else
                                    _launch(
                                        'https://youtu.be/${widget.movie.videoKey}');
                                },
                                icon: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white70,
                                ),
                                iconSize: 100.0,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Container(
                              height: size.height * 0.75,
                              width: size.width,
                              child: Stack(
                                children: [
                                  StreamBuilder<double>(
                                    stream:
                                        _bottomSheetDragger.dragUpdateStream,
                                    initialData: 0.0,
                                    builder: (context, value) {
                                      return Transform(
                                        transform: Matrix4.translationValues(
                                          0.0,
                                          size.height * 0.55 * (1 - value.data),
                                          0.0,
                                        ),
                                        child: CustomBottomSheet(
                                          movie: snapshot.data,
                                          controller: _bottomSheetDragger,
                                          onTapLeft: () =>
                                              _snackIt('No media found'),
                                          onTapRight: () =>
                                              _launch(widget.movie.homepage),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void _snackIt(String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text(msg),
    ));
  }

  void _launch(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      _snackIt('Error');
    }
  }
}
