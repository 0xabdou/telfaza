import 'package:flutter/material.dart';
import 'package:telfaza/bloc/discover_bloc.dart';
import 'package:telfaza/components/large_movie_card.dart';
import 'package:telfaza/models/movie.dart';
import 'package:telfaza/screens/fliters_sheet.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/style.dart';

class MoreScreen extends StatefulWidget {
  final PageType type;

  const MoreScreen({this.type});

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final DiscoverBloc bloc = DiscoverBloc();
  Filters initialFilters;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    initialFilters = Filters(
      mode: widget.type,
      years: Range(begin: 1900, end: 2019),
      genres: [],
    );
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc.inGenres.add(initialFilters.genres);
    bloc.inMode.add(initialFilters.mode);
    bloc.inYears.add(initialFilters.years);
    bloc.inApply.add(null);

    bloc.outApply.listen(
      (_) => _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      ),
    );
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final stream = bloc.outMovies;
    final sink = bloc.inIndex;

    final bar = AppBar();
    return Scaffold(
      appBar: EmptyAppBar(),
      key: _scaffoldKey,
      body: Stack(
        children: [
          StreamBuilder<List<Movie>>(
            stream: stream,
            builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
              final movies = snapshot.data;
              return ListView.builder(
                  controller: _scrollController,
                  itemCount: movies != null ? movies.length + 2 : 0,
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return SizedBox(
                        height: bar.preferredSize.height,
                      );
                    return _buildMovieCard(movies, index, sink);
                  });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MaterialButton(
              onPressed: () {
                _showBottomSheet();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: kSecondaryColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filters'),
                  Icon(Icons.tune),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.keyboard_arrow_down),
              ),
              title: Text('Discover more'),
            ),
          )
        ],
      ),
    );
  }

  void _showBottomSheet() {
    _scaffoldKey.currentState.showBottomSheet(
      (context) {
        return FiltersSheet(
          bloc: bloc,
          initialFilters: initialFilters,
        );
      },
    );
  }

  Widget _buildMovieCard(List<Movie> movies, int index, Sink<int> sink) {
    sink.add(index);

    if (movies == null || index >= movies.length) return Container();

    return LargeMovieCard(
      movie: movies[index],
    );
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}
