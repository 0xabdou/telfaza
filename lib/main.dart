import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/movie_search_bloc.dart';
import 'package:telfaza/bloc/movies_bloc.dart';
import 'package:telfaza/bloc/saved_bloc.dart';
import 'package:telfaza/screens/landing_screen.dart';
import 'package:telfaza/services/auth_service.dart';
import 'package:telfaza/services/db_service.dart';
import 'package:telfaza/services/firebase_auth_service.dart';
import 'package:telfaza/services/firestore_db_service.dart';
import 'package:telfaza/style.dart';

void main() => runApp(Telfaza());

class Telfaza extends StatefulWidget {
  @override
  _TelfazaState createState() => _TelfazaState();
}

class _TelfazaState extends State<Telfaza> {
  AuthService _authService;
  DBService _dbService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          builder: (_) {
            _authService = FirebaseAuthService();
            return _authService;
          },
          dispose: (_, value) => value.dispose(),
        ),
        Provider<DBService>(
          builder: (_) {
            _dbService = FirestoreDBService(_authService);
            return _dbService;
          },
          dispose: (_, value) => value.dispose(),
        ),
        Provider<MoviesBloc>(
          builder: (_) => MoviesBloc(),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<MovieSearchBloc>(
          builder: (_) => MovieSearchBloc(),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<SavedBloc>(
          builder: (_) => SavedBloc(_dbService),
          dispose: (_, value) => value.dispose(),
        )
      ],
      child: MaterialApp(
        title: 'Tlfaza',
        theme: appTheme,
        home: LandingScreen(),
      ),
    );
  }
}
