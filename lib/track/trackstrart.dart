import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/track/track.dart';
import 'package:ieat/track/trackaction.dart';
import 'package:ieat/track/trackroutine.dart';
import 'package:ieat/util.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';






class StartTrack_Sf extends StatefulWidget {
  const StartTrack_Sf({super.key, required this.tid});

  final int tid;

  @override
  State<StartTrack_Sf> createState() => _StartTrack_SfState();
}

class _StartTrack_SfState extends State<StartTrack_Sf> {

  List<String> mondayString = ["다음주", "다다음주", "다다다음주"];

  List<String> mondays = getMondaysForNextWeeks();
  String _selectedMonday = getMondaysForNextWeeks()[0];
  String _selectedMondayStr = "다음주";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading : IconButton(
          onPressed: () {
            popWithSlideAnimation(context, 2);
            bottomShow(context);
          },
          icon: Icon(Icons.chevron_left, size: 30),
        ),),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '트랙 시작',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              SizedBox(height: 10,),
              Text(
                "트랙을 시작할 날짜를 선택해주세요!",
                style: Text20BoldBlack,
              ),
              SizedBox(height: 20,),
              SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'pixcap/startrackPickDay.png',
                    fit: BoxFit.cover,
                  )
              ),
              Text(
                '${_selectedMondayStr} 월요일',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color : Color(0xffF89C1B)),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: getWidthRatioFromScreenSize(context, 0.7),
                height: 100, // 높이를 적절하게 설정합니다.
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                      initialItem: mondays.indexOf(_selectedMonday)),
                  itemExtent: 100, // 각 항목의 높이
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      final trackStartDayPickProvider =
                      Provider.of<TrackStartDayPickProvider>(context,
                          listen: false);
                      _selectedMonday = mondays[index];
                      print(_selectedMonday);
                      trackStartDayPickProvider.setMonday(index);
                      setState(() {
                        _selectedMondayStr = mondayString[index];
                      });
                    });
                  },
                  children: mondays.map((date) {
                    return Center(child: Text(date));
                  }).toList(),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(height: 25),
              Center(
                child: SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: () {
                      final trackStartDayPickProvider =
                      Provider.of<TrackStartDayPickProvider>(context,
                          listen: false);
                      if (trackStartDayPickProvider.monday == "") {
                        setState(() {
                          _selectedMonday = mondays[0];
                          print("픽 없어서 이번 주로 입력 ${mondays[0]}");
                          trackStartDayPickProvider.setMonday(0);
                        });
                      }
                      startTrack_POST(context, widget.tid);
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(10, 5, 10, 5),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(340, 40),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        ColorMainBack,
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                      shadowColor: MaterialStateProperty.all<Color>(
                        Colors.black,
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(
                        Colors.transparent,
                      ),
                    ),
                    child: Container(
                        width: double.maxFinite,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xffCBFF89),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFFE6E6E6),
                            width: 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "트랙 시작하기",
                            style: Text22BoldBlack,
                          ),
                        )),
                  ),
                ),
              ),
              SizedBox(height: 80),
            ],
          )
        ),
      ),
    );
  }
}








