import 'package:meta/meta.dart';

@immutable
class AuthUser {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;

  AuthUser({
    this.uid,
    this.email,
    this.name,
    this.photoUrl,
  });
}

abstract class AuthService {
  Future<AuthUser> currentUser();

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithFacebook();

  Future<void> signOut();

  Stream<AuthUser> get onAuthStateChanged;

  void dispose();
}
