import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // jsonDecode 사용을 위해 필요
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/init.dart';
import 'package:ieat/moose.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/setting.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeago/timeago.dart';
import '../constants.dart';
import '../home/homeaction.dart';


/***
 *
 * 루틴 생성 (페이지 initstate에서 클릭 시 호출)
 * createRoutine_1_POST : 루틴 아이디, 루틴 데이트 아이디 반환
 * createRoutine_2_POST : 루틴 기본항목 디비에 세팅
 * > 둘 중 하나라도 비정상작동하면 페이지 이탈(이전 페이지로)
 *
 * 루틴 수정
 * updateRoutine_POST : createRoutine_2_POST와 같은 api사용 중
 *
 */

Future<void> createRoutine_1_POST(BuildContext context) async {
  final tpv = Provider.of<OneTrackDetailInfoProvider>(context, listen: false);
  String? tk = await getTk();
  final tabpv = Provider.of<trackDetailTabProvider>(context, listen: false);

  String funcname = 'createRoutine_1_POST';
  setupDio();

  String selectedDay = formatDay(tabpv.selectedDay);
  print("tabpv.selectedWeek : ${tabpv.selectedWeek}");
  print("tabpv.selectedDay : ${selectedDay}");

  try {
    final response = await http.post(
      Uri.parse('$url/track/routine/create/${tpv.oneTrackInfo['tid']}?week=${tabpv.selectedWeek}&weekday=$selectedDay'),
      headers: {'accept': '*/*', 'Authorization': 'Bearer $tk'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      var utf8Res = utf8.decode(response.bodyBytes);
      var data = jsonDecode(utf8Res);
      print(data);
      createRoutine_2_POST(context, data['routine_id'], data['routine_date_id']);
    } else if (response.statusCode == 401) {
      await simpleAlert("오류가 발생하였습니다.");
      Navigator.pop(context);
      // bottomSheetType500(context, onlyCanStartMonday(context));
    } else {
      await simpleAlert("오류가 발생하였습니다.");
      Navigator.pop(context);
      // bottomSheetType500(context, fail500_1(context));
    }
  } catch (e) {
// 오류 처리
    await simpleAlert("오류가 발생하였습니다.");
    Navigator.pop(context);
    print('$funcname Error: $e');
  }
}
Future<void> createRoutine_2_POST(BuildContext context, int rid, int rdateid) async {
  final tabpv = Provider.of<trackDetailTabProvider>(context, listen: false);

  String? tk = await getTk();
  String funcname = 'createRoutine_2_POST';
  String uri = '$url/track/routine/create/next/$rdateid';
  setupDio();
  Map<String,dynamic> data = {
    "title": "새로운 루틴",
    "clock": "01:00:00.975Z",
    "weekday": "${formatDay(tabpv.selectedDay)}",
    "time": "아침",
    "calorie": 0,
    "repeat": false,
    "alarm": false
  };
  try {
    final response = await dio.request(
      uri,
      data: data,
      options: Options(
        method: 'POST',
        headers: {'accept': '*/*', 'Authorization': 'Bearer $tk'},
        validateStatus: (status) {
          print('$funcname : $status');
          return status! < 500;
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {

      final rpv = Provider.of<OneRoutineDetailInfoProvider>(context, listen: false);
      rpv.clear();
      rpv.setPageType("생성");
      rpv.setInfoFromDetail(data, rid, rdateid);  //한 루틴 정보, 루틴아이디, 루틴데이트아이디(create_1에서 반환)

      final rlistpv = Provider.of<RoutinListProvider>(context, listen: false);
      rlistpv.addList(rid, rdateid, data);  //해당일의 루틴리스트에 항목 추가

    } else if (response.statusCode == 401) {
      await simpleAlert("오류가 발생하였습니다.");
      Navigator.pop(context);
    } else {
      await simpleAlert("오류가 발생하였습니다.");
      Navigator.pop(context);
    }
  } catch (e) {
    await simpleAlert("오류가 발생하였습니다.");
    Navigator.pop(context);
    print('$funcname Error: $e');
  }
}





Future<void> updateRoutine_POST(BuildContext context) async {
  final rpv = Provider.of<OneRoutineDetailInfoProvider>(context, listen: false);

  String? tk = await getTk();
  String funcname = 'updateRoutine_POST';
  String uri = '$url/track/routine/create/next/${rpv.oneRoutineInfo['rdateid']}';
  setupDio();

  Map<String,dynamic> data = {
    "title": rpv.oneRoutineInfo['title'],
    "clock":  rpv.oneRoutineInfo['clock'],
    "weekday":  rpv.oneRoutineInfo['weekday'],
    "time": rpv.oneRoutineInfo['time'],
    "calorie":rpv.oneRoutineInfo['calorie'],
    "repeat":rpv.oneRoutineInfo['repeat'],
    "alarm": rpv.oneRoutineInfo['alarm'],
  };
  try {
    final response = await dio.request(
      uri,
      data: data,
      options: Options(
        method: 'POST',
        headers: {'accept': '*/*', 'Authorization': 'Bearer $tk'},
        validateStatus: (status) {
          print('$funcname : $status');
          return status! < 500;
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      Navigator.pop(context);
      rpv.clear();
      final rlistpv = Provider.of<RoutinListProvider>(context, listen: false);
      rlistpv.addList(rpv.oneRoutineInfo['rid'], rpv.oneRoutineInfo['rdateid'], data);  //해당일의 루틴리스트에 항목 추가
      await simpleAlert("정상적으로 수정되었습니다.");
    } else if (response.statusCode == 401) {
      Navigator.pop(context);
      await simpleAlert("오류가 발생하였습니다.");
    } else {
      Navigator.pop(context);
      await simpleAlert("오류가 발생하였습니다.");
    }
  } catch (e) {
    Navigator.pop(context);
    await simpleAlert("오류가 발생하였습니다.");
    print('$funcname Error: $e');
  }
}



