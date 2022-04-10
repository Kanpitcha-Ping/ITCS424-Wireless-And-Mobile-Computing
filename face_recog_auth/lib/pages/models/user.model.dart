import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String user;
  String password;
  List modelData;

  User({
    this.user,
    this.password,
    this.modelData,
  });

  /*static List<User> fromMap(QuerySnapshot querySnapshot) {
    List<User> users;
    querySnapshot.docs.forEach((u) {
      print(u["user"] + " "+ u["modeldata"].runtimeType);
      print(u["user"] + " "+ u["modeldata"]);
      users.add(new User(user: u["user"], password: u["password"], modelData: u["modeldata"]));
    });
    return users;
  }*/

  toMap() {
    return {
      'user': user,
      'password': password,
      'modeldata': modelData,
    };
  }
}
