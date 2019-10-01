import 'package:flutter/material.dart';
import 'package:telfaza/bloc/discover_bloc.dart';
import 'package:telfaza/components/tappable_surface.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/style.dart';

class FiltersSheet extends StatefulWidget {
  final DiscoverBloc bloc;
  final Filters initialFilters;

  const FiltersSheet({this.bloc, this.initialFilters});

  @override
  _FiltersSheetState createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  PageType _getMode(int index) {
    switch (index) {
      case 0:
        return PageType.popular;
      case 1:
        return PageType.topRated;
      case 2:
        return PageType.nowPlaying;
    }
    return null;
  }

  void _reset() {
    final bloc = widget.bloc;
    final filters = widget.initialFilters;
    bloc.inGenres.add(filters.genres);
    bloc.inMode.add(filters.mode);
    bloc.inYears.add(filters.years);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorTran,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.keyboard_arrow_down),
        ),
        title: Text('Filters'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _ModeRow(bloc: widget.bloc),
          ),
          Divider(
            color: Colors.white70,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _YearSlider(bloc: widget.bloc),
          ),
          Divider(
            color: Colors.white70,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Genre',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(
                  height: 8.0,
                ),
                _GenresGrid(bloc: widget.bloc),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(
            color: Colors.white70,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: OutlineButton(
                      onPressed: () {
                        setState(() {
                          _reset();
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      borderSide: BorderSide(color: Colors.white),
                      disabledBorderColor: Colors.white10,
                      highlightedBorderColor: Colors.white,
                      splashColor: kSecondaryColor.withAlpha(0x55),
                      textColor: Colors.white,
                      disabledTextColor: Colors.white10,
                      child: Text('RESET'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: FlatButton(
                      onPressed: () {
                        widget.bloc.inApply.add(null);
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text('APPLY'),
                      color: kSecondaryColor,
                      disabledColor: kSecondaryColor.withAlpha(0x55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearSlider extends StatefulWidget {
  final DiscoverBloc bloc;

  const _YearSlider({this.bloc});

  @override
  __YearSliderState createState() => __YearSliderState();
}

class __YearSliderState extends State<_YearSlider> {
  @override
  Widget build(BuildContext context) {
    final years = widget.bloc.filters.years;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Year',
          style: TextStyle(fontSize: 20.0),
        ),
        RangeSlider(
          onChanged: (values) {
            widget.bloc.inYears.add(Range(
              begin: values.start,
              end: values.end,
            ));
            setState(() {});
          },
          activeColor: kSecondaryColor,
          inactiveColor: Colors.white70,
          values: RangeValues(
            years.begin,
            years.end,
          ),
          min: 1900.0,
          max: 2019.0,
        ),
        Text(
          '${years.begin.toStringAsFixed(0)} - ${years.end.toStringAsFixed(0)}',
          style: TextStyle(),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

class _ModeRow extends StatefulWidget {
  final DiscoverBloc bloc;

  const _ModeRow({this.bloc});

  @override
  __ModeRowState createState() => __ModeRowState();
}

class __ModeRowState extends State<_ModeRow> {
  int _index;

  int _getIndex(PageType mode) {
    switch (mode) {
      case PageType.topRated:
        return 1;
      case PageType.popular:
        return 0;
      case PageType.nowPlaying:
        return 2;
      default:
        return null;
    }
  }

  PageType _getMode(int index) {
    switch (index) {
      case 0:
        return PageType.popular;
      case 1:
        return PageType.topRated;
      case 2:
        return PageType.nowPlaying;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _index = _getIndex(widget.bloc.filters.mode);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort by',
            style: TextStyle(fontSize: 20.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildChips(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    List<String> labels = ['Popular', 'Top rated', 'Newest'];
    List<Widget> chips = [];
    for (int i = 0; i < 3; i++) {
      chips.add(
        ChoiceChip(
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _index = i;
              });
              widget.bloc.inMode.add(_getMode(i));
            }
          },
          selected: i == _index,
          label: Text(labels[i]),
          selectedColor: kSecondaryColor,
          labelStyle: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return chips;
  }
}

class _GenresGrid extends StatefulWidget {
  final DiscoverBloc bloc;

  const _GenresGrid({this.bloc});

  @override
  _GenresGridState createState() => _GenresGridState();
}

class _GenresGridState extends State<_GenresGrid> {
  var selected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selected = List<int>.of(widget.bloc.filters.genres);
    return SizedBox(
      height: 200,
      child: GridView(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          childAspectRatio: 2 / 3,
        ),
        children: _buildGenreCards(),
      ),
    );
  }

  List<Widget> _buildGenreCards() {
    List<Widget> genreCards = [];
    for (int i = 0; i < genres.length; i++) {
      final id = genres[i]['id'];
      genreCards.add(
        _GenreCard(
          id: id,
          name: genres[i]['name'],
          bloc: widget.bloc,
          selected: selected,
        ),
      );
    }
    return genreCards;
  }

  final genres = [
    {"id": 28, "name": "Action"},
    {"id": 12, "name": "Adventure"},
    {"id": 16, "name": "Animation"},
    {"id": 35, "name": "Comedy"},
    {"id": 80, "name": "Crime"},
    {"id": 99, "name": "Documentary"},
    {"id": 18, "name": "Drama"},
    {"id": 10751, "name": "Family"},
    {"id": 14, "name": "Fantasy"},
    {"id": 36, "name": "History"},
    {"id": 27, "name": "Horror"},
    {"id": 10402, "name": "Music"},
    {"id": 9648, "name": "Mystery"},
    {"id": 10749, "name": "Romance"},
    {"id": 878, "name": "Science Fiction"},
    {"id": 53, "name": "Thriller"},
    {"id": 10752, "name": "War"},
    {"id": 37, "name": "Western"},
  ];
}

class _GenreCard extends StatefulWidget {
  final int id;
  final String name;
  final List<int> selected;
  final DiscoverBloc bloc;

  const _GenreCard({this.id, this.name, this.bloc, this.selected});

  @override
  _GenreCardState createState() => _GenreCardState();
}

class _GenreCardState extends State<_GenreCard> {
  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final selected = widget.selected;
    final active = widget.selected.contains(id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/g_${widget.name.toLowerCase()}.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Visibility(
            visible: active,
            child: Container(
              color: kSecondaryColor,
            ),
          ),
          Center(
            child: Text(
              widget.name,
              style: TextStyle(
                color: active ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TappableSurface(
            onPressed: () {
              setState(() {
                if (active) {
                  selected.remove(id);
                } else {
                  selected.add(id);
                }
              });
              widget.bloc.inGenres.add(selected);
            },
          ),
        ],
      ),
    );
  }
}
