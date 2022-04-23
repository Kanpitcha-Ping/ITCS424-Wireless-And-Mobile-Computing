import 'dart:convert';

import 'package:face_recog_auth/pages/models/course.model.dart';
import 'package:face_recog_auth/pages/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../models/attendance.model.dart';

class StudentsRepository {

  final CollectionReference collectionUser = FirebaseFirestore.instance.collection('students');
  final CollectionReference collectionAttendance = FirebaseFirestore.instance.collection('attendances');
  final CollectionReference collectionCourse = FirebaseFirestore.instance.collection('courses');
  //final List<User> Repo = [];

  Future queryAllUsers() async {
    List<User> users = [];
    //potential unmount problem
    try {
      await collectionUser.get().then((querySnapshot) =>
      {
        querySnapshot.docs.forEach((u) {
          users.add(User(user: u["user"], password: u["password"], modelData: u["modeldata"], email: u["email"] ));
        })
      });
      print("db qAll: " + users.isNotEmpty.toString());
      return users;
    } catch (e) {
      print("db qAll: " + e.toString());
      return null;
    }
  }

  Future<void> insert(User user) async {
    return await collectionUser.add(user.toMap());
  }

  Future<void> deleteAll() async {
    return await collectionUser.get().then((QuerySnapshot snapshot) => {
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      })
    });
  }

  Future<void> checkAttendance(Attendance attendance) async {
    return await collectionAttendance.add(attendance.toMap());
  }

  Future<void> insertCourse(Course course) async {
    return await collectionCourse.add(course.toMap());
  }

  Future getCourseByDay(int day) async {
    Course course;
    try {
      await collectionCourse.get().then((QuerySnapshot snapshot) =>
      {
        snapshot.docs.forEach((c) {
          if (c["dayofweek"] == day) {
            print("day: " + day.toString());
            course = Course(courseName: c["course"], day: c["dayofweek"],
                openTime: TimeOfDay(hour: c["openHour"], minute: c["openMin"]),
                closeTime: TimeOfDay(hour: c["closeHour"], minute: c["closeMin"]));
          }
        })
      });
      return course;
    } catch (e) {
      print("cannot retrieve course today");
      print(e.toString());
    }
  }

  Future getAllCourses(int day) async {
    List<Course> courses = [];
    try {
      await collectionCourse.get().then((QuerySnapshot snapshot) =>
      {
        snapshot.docs.forEach((c) {
          if (c["dayofweek"] == day) {
            courses.add(Course(courseName: c["course"], day: c["dayofweek"],
                openTime: TimeOfDay(hour: c["openHour"], minute: c["openMin"]),
                closeTime: TimeOfDay(
                    hour: c["closeHour"], minute: c["closeMin"])));
          }
        })
      });
      return courses;
    } catch (e) {
      print("cannot retrieve all courses");
      print(e.toString());
      return [];
    }
  }

  Future getHistory(String course, String user) async {
    List<Attendance> atd = [];
    try {
      await collectionAttendance.get().then((QuerySnapshot snapshot) =>
      {
        snapshot.docs.forEach((a) {
          atd.add(Attendance(
              username: a["user"],
              course: a["course"],
              timestamp: a["checkedTime"],
              status: a["status"]));
        })
      });
      return atd;
    } catch (e) {
      print("cannot retrieve attendance");
      print(e.toString());
    }
  }

}











