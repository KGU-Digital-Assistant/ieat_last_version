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
 *  : 트랙 시작
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
  String uri = '$url/track//$tid/${pv.monday}';
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
      await simpleAlert("트랙이 정상적으로 시작되었습니다.");
      popWithSlideAnimation(context, 2);
      bottomShow(context);
    } else if (response.statusCode == 401) {
      await simpleAlert("진행 중인 트랙이 있습니다.");
    } else if (response.statusCode == 409) {
      simpleAlert("오류가 발생하였습니다.");
    }else {
      simpleAlert("오류가 발생하였습니다.");
    }
  } catch (e) {
// 오류 처리
    print('$funcname Error: $e');
    simpleAlert("오류가 발생하였습니다.");
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


//트랙 삭제
Future<void> deleteOneTrack(BuildContext context) async {
  Dio dio = Dio();
  String? tk = await getTk();
  final pv = Provider.of<OneTrackDetailInfoProvider>(context,listen: false);
  String uri ="$url/track/delete/${pv.oneTrackInfo['tid']}";
  try {
    final response = await dio.delete(
      uri,
      options: Options(
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $tk',
        },
      ),
    );
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
    if(response.statusCode == 204) {
      final tpv = Provider.of<TrackProvider>(context,listen: false);
      tpv.removeTrackById(pv.oneTrackInfo['tid']);
      await simpleAlert("트랙이 정상적으로 삭제되었습니다.");
      popWithSlideAnimation(context, 2);
      bottomShow(context);
    }else{
      simpleAlert("오류가 발생하였습니다.");
    }
  } catch (e) {
    simpleAlert("오류가 발생하였습니다.");
    print('Error: $e');
  }
}



Future<diodart.Response> oneTrackInfo_GET(BuildContext context, int tid) async {
  // final pv = Provider.of<HomeSave>(context, listen: false);

  String funNm = 'OneTrackInfo_GET';
  print('$funNm - 요청시작');

  String? tk = await getTk();
  try {
    final response = await dio.get(
      '$url/track/get/$tid/Info',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $tk',
        },
        validateStatus: (status) {
          print('${status}');
          return status != null && status < 500; // 상태 확인을 명확하게
        },
      ),
    );

    final res = response.data;
    print(res);
    // if (response.statusCode == 200) {
    //   print(res);
    //   // pv.setTrack(res);
    // } else if (response.statusCode == 404) {
    //   bottomSheetType500(context,fail500_1(context));
    // } else {
    //   print(' $funNm Error(statusCode): ${response.statusCode}');
    //   bottomSheetType500(context,fail500_1(context));
    // }
    return response.data;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

Future<diodart.Response> calenderInfo_GET(BuildContext context, int tid) async {
  // final pv = Provider.of<HomeSave>(context, listen: false);

  String funNm = 'calenderInfo_GET';
  print('$funNm - 요청시작');

  String? tk = await getTk();
  int? uid = await getUserId();
  print("$tk, $uid");
  try {
    final response = await dio.get('$url/meal_day/get/calender/$uid',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $tk',
          },
          validateStatus: (status) {
            print('${status}');
            return status != null && status < 500; // 상태 확인을 명확하게
          },
        ),
        queryParameters: {"month ": 9, "year  ": 2024});

    final res = response.data;
    print(res);
    // if (response.statusCode == 200) {
    //   print(res);
    // } else if (response.statusCode == 404) {
    //   bottomSheetType500(context,fail500_1(context));
    // } else {
    //   print(' $funNm Error(statusCode): ${response.statusCode}');
    //   bottomSheetType500(context,fail500_1(context));
    // }
    return response.data;
  } catch (e) {
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

// Future<diodart.Response> routineGetWeek_GET( BuildContext context, int tid) async {
//   // final pv = Provider.of<HomeSave>(context, listen: false);
//
//   String funNm = 'routineGetWeek_GET';
//   print('$funNm - 요청시작');
//
//   String? tk = await getTk();
//
//   try {
//     final response = await dio.get(
//       '$url/clear/routine/get_week',
//       options: Options(
//         headers: {
//           'accept': 'application/json',
//           'Authorization': 'Bearer $tk',
//         },
//         validateStatus: (status) {
//           print('${status}');
//           return status != null && status < 500; // 상태 확인을 명확하게
//         },
//       ),
//     );
//
//     final res = response.data;
//     print(res);
//     // if (response.statusCode == 200) {
//     // } else if (response.statusCode == 404) {
//     //   bottomSheetType500(context,fail500_1(context));
//     // } else {
//     //   print(' $funNm Error(statusCode): ${response.statusCode}');
//     //   bottomSheetType500(context,fail500_1(context));
//     // }
//     return response.data;
//   } catch (e) {
// // 오류 처리
//     print('$funNm Error: $e');
//     return diodart.Response(
//         requestOptions: RequestOptions(path: ''), statusCode: 500);
//   }
// }

Future<diodart.Response> allTrackListup_GET(BuildContext context) async {
  //[{track_id: 1, name: 새로운 식단 트랙, create_time: 2024-09-14T00:37:46.923792, using: false}]
  String? tk = await getTk();
  String funNm = 'allTrackListup_GET';
  //회원 검색함수 - 돋보기 클릭 시 작동
  print("tk : $tk");
  print('$funNm - 요청시작');
  String uri = '$url/track/get/alltracks';
  try {
    final response = await dio.get(
      uri,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $tk',
        },
        validateStatus: (status) {
          print('${status}');
          return status != null && status < 500; // 상태 확인을 명확하게
        },
      ),
    );
    final res = response.data;
    print(res);
    if (response.statusCode == 200) {
      // setState(() {
      //   _isloading = false;
      //   var all_TrackList = List<Map<String, dynamic>>.from(res);
      //   print(all_TrackList);
      //   final trackListProvider =
      //   Provider.of<TrackProvider>(context, listen: false);
      //   trackListProvider.listInsert(all_TrackList);
      // });
    } else if (response.statusCode == 404) {
      //트랙 없는 상태
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
    return response.data;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}


