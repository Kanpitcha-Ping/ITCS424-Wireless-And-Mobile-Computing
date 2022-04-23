import 'dart:io';
import 'package:face_recog_auth/pages/db/db_firebase.dart';
import 'package:face_recog_auth/pages/models/attendance.model.dart';
import 'package:flutter/material.dart';
import 'package:face_recog_auth/pages/history.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home.dart';
import 'models/course.model.dart';
import 'models/user.model.dart';


class Profile extends StatefulWidget {

  final User _user;
  final String imagePath;
  const Profile(this._user, {Key key, @required this.imagePath}) : super(key: key);

  @override
  _MyProfile createState() => _MyProfile();
}

class _MyProfile extends State<Profile> {

  List<Course> todayCourses = [];
  String _c;
  bool isChecked = false;
  bool isAbsent = false;
  bool dropdown = false;

  Future getCoursesToday() async {
    print("today: " + DateTime.now().weekday.toString());
    dynamic coursesList = await StudentsRepository().getAllCourses(DateTime.now().weekday);
    if (coursesList == null) {
      print("Cannot fetch db");
    } else {
      todayCourses = coursesList;
      print("Course today: " + todayCourses.isNotEmpty.toString());
    }
  }

  // Future addCourse() async {
  //   TimeOfDay open = const TimeOfDay(hour: 1, minute: 30);
  //   TimeOfDay close = const TimeOfDay(hour: 4, minute: 0);
  //   print("open:" + open.hour.toString());
  //   print("close: " + close.hour.toString());
  //   Course course = Course(courseName: "Wireless And Mobile Computing", day: DateTime.now().weekday, openTime: open, closeTime: close);
  //   print(course.courseName);
  //   try {
  //     await StudentsRepository().insertCourse(course);
  //   } catch (e) {
  //     print("cannot add course" + e.toString());
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //addCourse();
    getCoursesToday();
  }

  Future markPresent() async {
    print(DateTime.now());
    Attendance a = Attendance(username: widget._user.user, course: _c, timestamp: DateTime.now().toString(), status: "present");
    await StudentsRepository().checkAttendance(a);
    setState(() {
      isChecked = !isChecked;
    });
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('Sucessfully Check!'),
        );
      },
    );
  }

  Future markAbsent() async {
    print(DateTime.now());
    Attendance a = Attendance(username: widget._user.user, course: _c, timestamp: DateTime.now().toString(), status: "absent");
    await StudentsRepository().checkAttendance(a);
    setState(() {
      isAbsent = !isAbsent;
    });

    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('Absent!'),
        );
      },
    );
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          // image: FileImage(File(imagePath)),
                          image: FileImage(File(widget.imagePath)),
                        ),
                      ),
                      width: 50,
                      height: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget._user.user,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget._user.email,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFF8A8CC0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        //width: MediaQuery.of(context).size.width * 0.3,
                        //height: MediaQuery.of(context).size.height*0.05,
                        //height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text('LOG OUT ', style: TextStyle(fontSize: 10, color: Colors.white),),
                            Icon(Icons.logout,color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ' + widget._user.user + '.',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFF8A8CC0)),
                    ),
                    const Text(
                      'Welcome To Your Class',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFF0B2AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                //Today class
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Today\'s Classes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    Icon(FontAwesomeIcons.caretDown , color: Color(0xFF8A8CC0)),
                  ],
                ),
                const SizedBox(height: 15),
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
                      //child: Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height*0.2,
                          child: ListView.builder(
                            itemCount: todayCourses.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  child: builtCourse(todayCourses[index]),
                              );
                            },
                          ),
                        ),
                      //),
                    ),
                //const Spacer(),
                SizedBox(height: 15,),
                Container(
                  //margin: const EdgeInsets.all(20),
                  //padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance History',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => History(widget._user.user, _c)));
                        },
                        child: Icon(FontAwesomeIcons.caretRight , color: const Color(0xFF8A8CC0)),
                      ),
                      SizedBox(width: 3,),
                      //Icon(FontAwesomeIcons.caretRight , color: const Color(0xFF8A8CC0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget builtCourse(Course c) {
    _c = c.courseName;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Image.asset('assets/w.png', width: 38, fit: BoxFit.fitWidth),
          SizedBox(width: 6,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _c,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A8CC0)),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    TimeOfDay.now().hour.toString() + ":" + c.getMin(TimeOfDay.now()),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF8A8CC0)),
                  ),
                ],
              ),
              SizedBox(height: 4,),
              c.isValidTime() && !isChecked && !isAbsent
                ? Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: markPresent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFF56C6C2),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        width: MediaQuery.of(context).size.width * 0.2,
                        //height: MediaQuery.of(context).size.height*0.05,
                        //height: 60,
                        child: const Text('Present', style: TextStyle(fontSize: 10, color: Colors.white),),
                      ),
                    ),
                    SizedBox(width: 15,),
                    InkWell(
                      onTap: markAbsent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFFDD219A),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        width: MediaQuery.of(context).size.width * 0.2,
                        //height: MediaQuery.of(context).size.height*0.05,
                        child: const Text('Absent', style: TextStyle(fontSize: 10, color: Colors.white),),
                      ),
                    ),
                  ],
                )
                : isChecked
                  ? Row(
                      children: const [
                        Text('You are marked ', style: TextStyle(fontSize: 12, color: Colors.black),),
                        Text('PRESENT', style: TextStyle(fontSize: 12, color: Color(0xFF56C6C2), fontWeight: FontWeight.w600),)
                      ],
                    )
                  : isAbsent
                    ? Row(
                        children: const [
                          Text('You are marked ', style: TextStyle(fontSize: 12, color: Colors.black),),
                          Text('ADSENT', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),)
                        ],
                      )
                    : !c.isValidTime() && !isChecked
                        ? Row(
                            children: const [
                              Text('You are late and marked ', style: TextStyle(fontSize: 12, color: Colors.black),),
                              Text('ABSENT ', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),)
                            ],
                          )
                        : const Text('Not available', style: TextStyle(fontSize: 12, color: const Color(0xFF56C6C2), fontWeight: FontWeight.w600),)
            ],
          ),
        ],
      ),
    );
  }

}
