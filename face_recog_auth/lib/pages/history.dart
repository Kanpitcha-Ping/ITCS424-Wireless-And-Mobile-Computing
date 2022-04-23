import 'package:face_recog_auth/pages/db/db_firebase.dart';
import 'package:face_recog_auth/pages/models/attendance.model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


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
    dynamic attendanceList = await StudentsRepository().getHistory(widget.course, widget._user);
    if (attendanceList == null) {
      print("Cannot fetch db");
    } else {
      attendances = attendanceList;
      print("attendance: " + attendances.isNotEmpty.toString());
      print("attendance length: " +attendances.length.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getAttendances();
  }

  _onBackPressed() {
    Navigator.of(context).pop();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _onBackPressed,
                      child: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.black,),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Attendance',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFFF0099).withOpacity(0.28),
                            const Color(0xFF0085FF).withOpacity(0.28),
                          ]
                      )
                  ),
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
                  //),
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
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
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
                ],
              ),
              SizedBox(height: 4,),
              atd.status == 'present'
                ? Row(
                    children: [
                      Text('You are marked ', style: TextStyle(fontSize: 12, color: Colors.black),),
                      Text(atd.status, style: TextStyle(fontSize: 12, color: Color(0xFF56C6C2), fontWeight: FontWeight.w600),)
                    ],
                  )
                : Row(
                  children: [
                    Text('You are marked ', style: TextStyle(fontSize: 12, color: Colors.black),),
                    Text(atd.status, style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),)
                  ],
                ),
              SizedBox(height: 4,),
              Text(
                atd.timestamp.toString(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF8A8CC0)),
              ),
            ],
          ),
        ],
      ),
    );

  }

}
