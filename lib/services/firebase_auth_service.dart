import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:telfaza/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FirebaseAuthService extends AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  @override
  Future<AuthUser> currentUser() async {
    final firebaseUser = await _auth.currentUser();
    return _userFromFirebase(firebaseUser);
  }

  @override
  void dispose() {}

  @override
  Stream<AuthUser> get onAuthStateChanged =>
      _auth.onAuthStateChanged.map(_userFromFirebase);

  @override
  Future<AuthUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final firebaseUser = await _auth.signInWithCredential(credential);
        return _userFromFirebase(firebaseUser);
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_TOKENS',
          message: 'google user has a missing token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'google sign in aborted by user',
      );
    }
  }

  @override
  Future<AuthUser> signInWithFacebook() async {
    final FacebookLogin facebookLogin = FacebookLogin();
    facebookLogin.logOut();
    final FacebookLoginResult result =
        await facebookLogin.logInWithReadPermissions(
      ['email', 'public_profile'],
    );
    if (result.accessToken != null) {
      final credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      final FirebaseUser firebaseUser =
          await _auth.signInWithCredential(credential);
      print('user $firebaseUser');
      return _userFromFirebase(firebaseUser);
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  @override
  Future<void> signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
    return null;
  }

  AuthUser _userFromFirebase(FirebaseUser user) {
    return user != null
        ? AuthUser(
            uid: user.uid,
            email: user.email,
            name: user.displayName,
            photoUrl: user.photoUrl,
          )
        : null;
  }
}
