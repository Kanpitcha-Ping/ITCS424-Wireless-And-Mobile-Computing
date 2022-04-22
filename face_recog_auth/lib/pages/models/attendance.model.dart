
class Attendance {

  String username;
  String course;
  DateTime timestamp;
  String status;
  //String datetime = DateTime.now().toString();

  Attendance({
    this.username,
    this.course,
    this.timestamp,
    this.status
  });

  toMap() {
    return {
      'user': username,
      'course': course,
      'checkedTime': timestamp.toString(),
      'status': status
    };
  }



}
