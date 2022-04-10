import 'dart:convert';

import 'package:face_recog_auth/pages/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class StudentsRepository {

  final CollectionReference collection = FirebaseFirestore.instance.collection('students');

  Future<List<User>> queryAllUsers() async {
    QuerySnapshot querySnapshot = await collection.get();
    List<User> users;
    print("db_firebase:  queryAllusers");
    querySnapshot.docs.forEach((u) {
      if (u["modeldata"] != null) {
        print("user: " + u["user"]);
        //print("pure" + u["modeldata"]);
        User _user = User(user: u["user"], password: u["password"], modelData: u["modeldata"]);
        print(_user.modelData);
        users.add(_user);
      }
    });
    return users;
  }

  Future<void> insert(User user) async {
    return await collection.add(user.toMap());
  }

  Future<void> deleteAll() async {
    return await collection.get().then((QuerySnapshot snapshot) => {
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      })
    });
  }
}