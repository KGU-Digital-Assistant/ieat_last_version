import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart' as diodart;
import 'package:flutter/material.dart';
import 'package:ieat/track/track.dart';
import 'package:ieat/track/trackroutine.dart';
import 'package:ieat/util.dart';
import 'package:ieat/constants.dart';
import 'package:provider/provider.dart';

import '../home/homeaction.dart';
import '../init.dart';
import '../provider.dart';
import '../styleutil.dart';

/**
 * 모든 함수가 있지는 않음(track.dart에서 본 파일로 옮기는 작업 필요)
 * startTrack_POST : 트랙 시작
 * routineListup_GET  : 주차, 요일 넘기면 해당 날짜의 루틴 리스트업
 *
 */



//트랙 시작
Future<void> startTrack_POST(BuildContext context, int tid) async {
  String? tk = await getTk();
  final pv = Provider.of<TrackStartDayPickProvider>(context, listen: false);
  print(pv.monday);
  String funcname = 'startTrack_POST';
  print('$funcname - 요청시작');
  String uri = '$url/track/group/start_track/$tid/${pv.monday}';
  setupDio();
  try {
    final response = await dio.request(
      uri,
      options: Options(
        method: 'POST',
        headers: {'accept': '*/*', 'Authorization': 'Bearer $tk'},
        validateStatus: (status) {
          print('$funcname : $status');
          return status! < 500;
        },
      ),
    );
    print(response.data);
    if (response.statusCode == 200 || response.statusCode == 204) {
      startTrack_inviteMe_POST(context, tid);
    } else if (response.statusCode == 401) {
      bottomSheetType500(context, onlyCanStartMonday(context));
    } else {
      bottomSheetType500(context, fail500_1(context));
    }
  } catch (e) {
// 오류 처리
    print('$funcname Error: $e');
  }
}

//하루에 대한 루틴 리스트
Future<void> routineListup_GET(BuildContext context) async {
  String funNm = 'routineListup_GET';

  final pv = Provider.of<OneTrackDetailInfoProvider>(context, listen: false);
  final tabpv = Provider.of<trackDetailTabProvider>(context, listen: false);
  String? tk = await getTk();
  String weekDay = formatDay(tabpv.selectedDay);
print("weekDay : $weekDay");
  print("week : ${tabpv.selectedWeek}");
print("tid : ${pv.oneTrackInfo['tid']}");

  String uri = '$url/track/routine/list/${pv.oneTrackInfo['tid']}';
  try {
    final response = await dio.get(
      uri,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $tk',
        },
        validateStatus: (status) {
          print('$funNm : ${status}');
          return status != null && status < 500; // 상태 확인을 명확하게
        },
      ),
      queryParameters: {
        "week" : tabpv.selectedWeek,
        "weekday" : weekDay
      }
    );
    List<Map<String,dynamic>> data = List<Map<String,dynamic>>.from(response.data);
    final rlistpv = Provider.of<RoutinListProvider>(context, listen: false);
    rlistpv.clear();
    if (response.statusCode == 200) {
      print("setList");
      print(data);
      rlistpv.setList(data);
    } else if (response.statusCode == 404) {
      //루틴 리스트 없는 상태
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}










