import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class User {
  final String uid;
  final String email;
  final String username;
  final String name;
  final String photoUrl;

  const User({
    @required this.uid,
    @required this.email,
    @required this.username,
    @required this.name,
    @required this.photoUrl,
  });

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }
}

abstract class DBService {
  Future<User> currentUser();

  Future<void> updateProfile(Map<String, String> profile);

  Future<String> updatePhoto(File image);

  Future<void> addFavorite(int id);

  Future<void> removeFavorite(int id);

  Future<void> addLater(int id);

  Future<void> removeLater(int id);

  Future<Stream<QuerySnapshot>> get outFavorites;

  Future<Stream<QuerySnapshot>> get outLaters;

  void dispose();
}
