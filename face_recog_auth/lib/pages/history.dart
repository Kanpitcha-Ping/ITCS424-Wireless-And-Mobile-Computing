import 'dart:io';
import 'package:face_recog_auth/pages/db/db_firebase.dart';
import 'package:face_recog_auth/pages/models/attendance.model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home.dart';
import 'models/course.model.dart';
import 'models/user.model.dart';


class History extends StatefulWidget {

  final String _user;
  final String course;
  const History(this._user, this.course, {Key key}) : super(key: key);

  @override
  _MyHistory createState() => _MyHistory();
}

class _MyHistory extends State<History> {

  List<Attendance> attendances = [];

  Future getAttendances() async {
    print("attendance: " + DateTime.now().weekday.toString());
    dynamic coursesList = await StudentsRepository().getHistory(widget.course, widget._user);
    if (coursesList == null) {
      print("Cannot fetch db");
    } else {
      attendances = coursesList;
      print("attendance: " + attendances.isNotEmpty.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getAttendances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(FontAwesomeIcons.home, color: const Color(0xFF8A8CC0),),
        title: Center(child: Image.asset('assets/facecheckchic.png', width: 200, fit: BoxFit.fitWidth)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height*1,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                //Today class
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Attendance',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.5,
                      child: ListView.builder(
                        itemCount: attendances.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            child: builtAttendance(attendances[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget builtAttendance(Attendance atd) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: 6,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.course,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A8CC0)),
                  ),
                  SizedBox(width: 24,),
                  Text(
                    atd.timestamp.toUtc().toString(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF8A8CC0)),
                  ),
                ],
              ),
              SizedBox(height: 4,),
              Row(
                children: [
                  Text('You are marked ', style: TextStyle(fontSize: 12, color: Colors.black),),
                  Text(atd.status, style: TextStyle(fontSize: 12, color: Color(0xFF56C6C2), fontWeight: FontWeight.w600),)
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

}
