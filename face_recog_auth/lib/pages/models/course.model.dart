import 'dart:developer';

import 'package:flutter/material.dart';

class Course {
  String courseName;
  int day;
  TimeOfDay openTime;
  TimeOfDay closeTime;

  Course({
    this.courseName,
    this.day,
    this.openTime,
    this.closeTime
  });

  toMap() {
    return {
      'course': courseName,
      'dayofweek': day,
      'openHour': openTime.hour,
      'openMin': openTime.minute,
      'closeHour': closeTime.hour,
      'closeMin': closeTime.minute,
    };
  }

  bool isValidTime() {
    double nowTime = TimeOfDay.now().hour.toDouble() + (TimeOfDay.now().minute.toDouble()/60);
    double cTime = closeTime.hour.toDouble() + (closeTime.minute.toDouble()/60);
    print("now: " + nowTime.toString());
    print("close: " + cTime.toString());
    return (cTime > nowTime);
  }

  String getMin(TimeOfDay t) {
    if (t.minute < 10)
      return "0" + t.minute.toString();
    return t.minute.toString();
  }


}
