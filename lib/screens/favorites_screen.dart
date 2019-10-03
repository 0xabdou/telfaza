import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/saved_bloc.dart';
import 'package:telfaza/components/movie_card.dart';
import 'package:telfaza/models/movie.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: Provider.of<SavedBloc>(context).outFavorites,
        builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
          if (snapshot.hasData)
            return GridView.count(
              crossAxisCount: 3,
              children: [for(var movie in snapshot.data) MovieCard(movie: movie,)],
            );
          else
            return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }
}
