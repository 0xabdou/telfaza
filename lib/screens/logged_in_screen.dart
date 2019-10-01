import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/movies_bloc.dart';
import 'package:telfaza/screens/main_screen.dart';

class LoggedInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<MoviesBloc>(
      builder: (_) => MoviesBloc(),
      dispose: (_, value) => value.dispose(),
      child: MainScreen(),
    );
  }
}
