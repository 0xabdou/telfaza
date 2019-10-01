import 'package:rxdart/rxdart.dart';
import 'package:telfaza/services/auth_service.dart';

import 'db_service.dart';

class MockAuthService extends AuthService {
  static AuthUser _user;

  final BehaviorSubject<AuthUser> _authStateSubject =
      BehaviorSubject<AuthUser>.seeded(_user);

  @override
  Future<AuthUser> currentUser() async {
    await Future<User>.delayed(Duration(seconds: 1));
    return _user;
  }

  @override
  Stream<AuthUser> get onAuthStateChanged => _authStateSubject.stream;

  @override
  Future<AuthUser> signInWithGoogle() async {
    await Future<User>.delayed(Duration(seconds: 2));
    _user = AuthUser(
      uid: 'FAKE UID',
      email: 'fake@email.com',
      photoUrl: 'https://i.pravatar.cc/150?img=64',
    );
    _notify();
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _notify();
  }

  void _notify() {
    _authStateSubject.add(_user);
  }

  @override
  void dispose() {
    _authStateSubject.close();
    print('Mock disposed');
  }

  @override
  Future<AuthUser> signInWithFacebook() async {
    await Future<User>.delayed(Duration(seconds: 2));
    _user = AuthUser(
      uid: 'FAKE UID',
      email: 'fake@email.com',
      photoUrl: 'https://i.pravatar.cc/150?img=64',
    );
    _notify();
    return _user;
  }
}
