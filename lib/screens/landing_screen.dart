import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/bloc/saved_bloc.dart';
import 'package:telfaza/screens/login_screen.dart';
import 'package:telfaza/screens/main_screen.dart';
import 'package:telfaza/services/auth_service.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<AuthService>(context);
    return StreamBuilder<AuthUser>(
      stream: _auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<AuthUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            Provider.of<SavedBloc>(context).inRestart.add(true);
            return MainScreen();
          }
          Provider.of<SavedBloc>(context).inRestart.add(false);
          return LoginScreen();
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
