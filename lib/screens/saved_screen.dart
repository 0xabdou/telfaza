import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/saved_bloc.dart';
import 'package:telfaza/components/movie_card.dart';
import 'package:telfaza/models/movie.dart';

class SavedScreen extends StatelessWidget {
  final SavedType type;

  const SavedScreen({@required this.type});

  @override
  Widget build(BuildContext context) {
    final stream = type == SavedType.fav
        ? Provider.of<SavedBloc>(context).outFavorites
        : Provider.of<SavedBloc>(context).outLaters;
    return Scaffold(
      appBar: AppBar(
        title: Text(type == SavedType.fav ? 'Favorites' : 'Watch later'),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
          if (snapshot.hasData)
            return GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 0.6,
              children: [
                for (var movie in snapshot.data)
                  MovieCard(
                    movie: movie,
                  )
              ],
            );
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }
}

enum SavedType {
  fav,
  later,
}
