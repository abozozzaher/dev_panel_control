import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../addNewProduct/helper.dart';

class WorkTime extends StatefulWidget {
  const WorkTime(
      {super.key,
      required void Function() toggleTheme,
      required void Function() toggleLocale});

  @override
  State<WorkTime> createState() => _WorkTimeState();
}

class _WorkTimeState extends State<WorkTime> {
  int totalRunTime = 0; // مدة التشغيل الكلية لليوم بالدقائق

  @override
  void initState() {
    super.initState();
    fetchDailyRunTime();
  }

  Future<void> fetchDailyRunTime() async {
    try {
      final today = DateTime.now();
      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // جلب جميع الأحداث لليوم الحالي
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('connection_logs')
          .doc(todayStr)
          .collection('POINT_5')
          .get();

      // التأكد من وجود بيانات
      if (snapshot.docs.isEmpty) {
        setState(() {
          totalRunTime = 0;
        });
        return;
      }

      // ترتيب الأحداث حسب الوقت
      List<Map<String, dynamic>> events = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['events'] != null) {
          events.addAll(List<Map<String, dynamic>>.from(data['events']));
        }
      }
      events.sort((a, b) =>
          DateTime.parse(a['time']).compareTo(DateTime.parse(b['time'])));

      // حساب مدة التشغيل
      int runTimeInSeconds = 0;
      for (int i = 0; i < events.length - 1; i++) {
        if (events[i]['state'] == 'on' && events[i + 1]['state'] == 'off') {
          DateTime start = DateTime.parse(events[i]['time']);
          DateTime end = DateTime.parse(events[i + 1]['time']);
          runTimeInSeconds += end.difference(start).inSeconds;
        }
      }

      // إذا كانت الحالة الأخيرة هي "on"، استخدم الوقت الحالي كوقت النهاية
      if (events.isNotEmpty && events.last['state'] == 'on') {
        DateTime start = DateTime.parse(events.last['time']);
        DateTime now = DateTime.now();
        runTimeInSeconds += now.difference(start).inSeconds;
      }

      // تحويل الثواني إلى دقائق
      setState(() {
        totalRunTime = (runTimeInSeconds / 60).round();
      });
    } catch (e) {
      print("Error fetching runtime: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now);

    return Scaffold(
      appBar: AppBar(title: Text('مدة التشغيل اليومي')),
      body: Column(
        children: [
          Center(
            child: Text(
              "${convertArabicToEnglish(formattedTime)} : الساعة الان ",
              style: TextStyle(fontSize: 18),
              textDirection: ui.TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              "${(totalRunTime ~/ 60)} : ${(totalRunTime % 60)}  وقت العمل ",
              style: TextStyle(fontSize: 18),
              textDirection: ui.TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
