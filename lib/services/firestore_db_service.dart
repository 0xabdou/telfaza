import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:telfaza/services/auth_service.dart';
import 'package:telfaza/services/db_service.dart';

class FirestoreDBService extends DBService {
  final Firestore _firestore = Firestore.instance;
  final StorageReference _storage = FirebaseStorage.instance.ref();
  AuthService _auth;
  User _user;

  FirestoreDBService(AuthService auth) {
    _auth = auth;
  }

  Stream<QuerySnapshot> get outFavorites {
    return _firestore.collection('favorites').where('user', isEqualTo: _user.uid).snapshots();
  }

  Future<User> _newUser(AuthUser authUser) async {
    await _firestore.collection('users').document(authUser.uid).setData({
      'email': authUser.email,
      'username': authUser.email.split('@')[0],
      'name': authUser.name,
      'photoUrl': authUser.photoUrl,
    });
    return User(
      uid: authUser.uid,
      email: authUser.email,
      username: authUser.email.split('@')[0],
      name: authUser.name,
      photoUrl: authUser.photoUrl,
    );
  }

  @override
  Future<User> currentUser() async {
    final authUser = await _auth.currentUser();

    if (authUser == null) return null;

    final documentSnapshot =
        await _firestore.collection('users').document(authUser.uid).get();

    final data = documentSnapshot.data;
    if (data == null) {
      return _newUser(authUser);
    }
    data['uid'] = documentSnapshot.documentID;
    _user = User.fromJSON(documentSnapshot.data);
    return _user;
  }

  Future<User> _getUserOrThrow() async {
    final user = await currentUser();

    if (user == null) {
      throw PlatformException(
        code: 'ERROR_MISSING_USER',
        message: 'Can\t retrieve current user',
      );
    }

    final uid = user.uid;

    if (uid == null) {
      throw PlatformException(
        code: 'ERROR_MISSING_UID',
        message: 'Can\t retrieve current user\'s uid',
      );
    }

    return user;
  }

  @override
  Future<void> updateProfile(Map<String, String> profile) async {
    final user = await _getUserOrThrow();
    final uid = user.uid;

    String username;
    if (profile.containsKey('username'))
      username = profile['username'].toLowerCase();

    if (await usernameExists(username)) {
      throw PlatformException(
        code: 'ERROR_USERNAME_EXISTS',
        message: 'username already exists',
      );
    }
    // username inside profile may still be upper case
    // so we do this
    profile['username'] = username;

    final allowedFields = ['username', 'name'];
    for (var key in profile.keys) {
      if (!allowedFields.contains(key)) {
        throw PlatformException(
          code: 'ERROR_FIELD_NOT_ALLOWED',
          message: 'tried to update profile with a non allowed field',
        );
      }
    }

    return _firestore
        .collection('users')
        .document(uid)
        .setData(profile, merge: true);
  }

  Future<bool> usernameExists(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .getDocuments();
    return result.documents.isNotEmpty;
  }

  @override
  Future<String> updatePhoto(File image) async {
    final user = await _getUserOrThrow();

    final ref = _storage.child(user.uid).child("profilePhoto");
    final uploadTask = ref.putFile(image);
    final url = await (await uploadTask.onComplete).ref.getDownloadURL();
    await _firestore
        .collection('users')
        .document(user.uid)
        .setData({'photoUrl': url}, merge: true);
    return url;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
