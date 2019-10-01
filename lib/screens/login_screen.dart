import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/services/auth_service.dart';
import 'package:telfaza/style.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  AuthService _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_auth == null) _auth = Provider.of<AuthService>(context);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          progressIndicator: SpinKitDoubleBounce(
            color: kPrimaryColor,
            size: 60,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/b_login.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Opacity(
                    opacity: 1.0,
                    child: Image.asset(
                      'assets/images/TLFZ.png',
                      width: 250.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          onTap: () => _signInWithGoogle(),
                          label: 'Sign in with Google',
                          color: Color(0xFFCF4332),
                          image: 'assets/images/l_google.png',
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        _SocialButton(
                          onTap: () => _signInWithFacebook(),
                          label: 'Sign in with Facebook',
                          color: Color(0xFF4267B2),
                          image: 'assets/images/l_facebook.png',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle() async {
    setState(() {
      _loading = true;
    });
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      setState(() {
        _loading = false;
        print(_loading);
      });
    }
  }

  void _signInWithFacebook() async {
    setState(() {
      _loading = true;
    });
    try {
      await _auth.signInWithFacebook();
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _snackException(e);
    }
  }

  void _snackException(Exception e) {
    print(e);
    if (e is PlatformException) {
      if (e.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'An account with this email already exists but with different social media',
            ),
          ),
        );
        return;
      } else if (e.code == 'ERROR_ABORTED_BY_USER') return;
    }
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('Something went wrong')),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String image;
  final Color color;
  final Function onTap;

  const _SocialButton({
    this.label,
    this.image,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onTap,
      color: color.withAlpha(0xDD),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset(
              image,
              color: Colors.white,
              height: 40.0,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
