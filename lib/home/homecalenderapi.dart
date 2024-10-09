
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as diodart;
import 'package:flutter/material.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import '../constants.dart';
import '../provider.dart';



/**
 * calenderMonthly_Get : 월별 데이터 호출(4개의 함수)
 * recordDay_count_GET
 * routine_count_GET
 * avgCalorie_GET
 * goalCalorie_GET
 *
 *
 *
 * calenderDaily_Get : 일별 데이터 호출
 * trackTitle_GET
 * health_SeletedDay_GET
 * routine_SelectdDay_GET
 * save_SelectdDay_GET
 */




//총 4개의 함수 호출
Future<void> calenderMonthly_Get(BuildContext context, int tid, String selectedDay) async {
  List<bool> res = [false, false, false, false];

  try {
    //처음에 200,200,404,404가 정상임(데이터 없어서 404)
    var response1 = await recordDay_count_GET(context, tid, selectedDay);
    if (response1.statusCode == 200 || response1.statusCode == 204) res[0] = true;

    var response2 = await routine_count_GET(context, tid, selectedDay);
    if (response2.statusCode == 200 || response2.statusCode == 204) res[1] = true;

    var response3 = await avgCalorie_GET(context, tid, selectedDay);
    if (response3.statusCode == 200 || response3.statusCode == 204) res[2] = true;

    var response4 = await goalCalorie_GET(context, tid, selectedDay);
    if (response4.statusCode == 200 || response4.statusCode == 204) res[3] = true;


    print(res);
    // 모든 요청이 성공했는지 확인
    // if (res.every((element) => element == true)) {
    //   // bottomSheetType500(context, suc500_1(context));
    // } else {
    //   print('calenderGet - Some requests failed: $res');
    //   // bottomSheetType500(context, fail500_1(context));
    // }
  } catch (e) {
    bottomSheetType500(context, fail500_1(context));
  }
}
//기록일
Future<diodart.Response> recordDay_count_GET(BuildContext context, int tid, String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  List<int> yearAndMonth = getYearAndMonth(selectedDay);

  String funNm = 'meal_recording_count_GET';
  String? tk = await getTk();
  try {
    final response = await dio.get(
      '$url/meal_day/get/meal_recording_count/${yearAndMonth[0]}/${yearAndMonth[1]}',
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
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setMonthRecordDay(data);

    } else if (response.statusCode == 404) {



    } else {



    }

    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

//지킨 루틴 수
Future<diodart.Response> routine_count_GET(BuildContext context, int tid, String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  List<int> yearAndMonth = getYearAndMonth(selectedDay);
  String funNm = 'routine_count_GET';

  String? tk = await getTk();
  try {
    final response = await dio.get(
      '$url/clear/routine/calendar/${yearAndMonth[0]}/${yearAndMonth[1]}',
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
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setMonthRoutine(data);

    } else if (response.statusCode == 404) {



    } else {



    }

    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

//일 평균 칼로리
Future<diodart.Response> avgCalorie_GET(BuildContext context, int tid, String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);
  String funNm = 'avgCalorie_GET';
  String? tk = await getTk();
  List<int> yearAndMonth = getYearAndMonth(selectedDay);

  try {
    final response = await dio.get(
      '$url/meal_day//get/meal_avg_calorie/${yearAndMonth[0]}/${yearAndMonth[1]}',
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
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setAvgCalorie(data['calorie']);

    } else if (response.statusCode == 404) {
      pv.setAvgCalorie(0);  //데이터 없을 때



    } else {



    }
    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

//일 목표 칼로리
Future<diodart.Response> goalCalorie_GET(BuildContext context, int tid, String selectedDay) async {

  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  String funNm = 'routine_count_GET';
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
          print('$funNm : ${status}');
          return status != null && status < 500; // 상태 확인을 명확하게
        },
      ),
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setGoalCalorie(data['calorie']);

    } else if (response.statusCode == 404) {
      pv.setGoalCalorie(0);

    } else {



    }
    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}



//총 4개의 함수 호출
Future<void> calenderDaily_Get(BuildContext context, int tid, String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);
  pv.setSelectedDay(selectedDay);
  List<bool> res = [false, false, false, false];

  try {

    //처음에 404가,404가,200,404가 정상임(데이터 없어서 404)
    var response1 = await trackTitle_GET(context, tid, selectedDay);
    if (response1.statusCode == 200 || response1.statusCode == 204) res[0] = true;

    var response2 = await health_SeletedDay_GET(context, tid, selectedDay);
    if (response2.statusCode == 200 || response2.statusCode == 204) res[1] = true;

    var response3 = await routine_SelectdDay_GET(context, tid, selectedDay);
    if (response3.statusCode == 200 || response3.statusCode == 204) res[2] = true;

    var response4 = await save_SelectdDay_GET(context, tid, selectedDay);
    if (response4.statusCode == 200 || response4.statusCode == 204) res[3] = true;


    print(res);
    // 모든 요청이 성공했는지 확인
    // if (res.every((element) => element == true)) {
    //   // bottomSheetType500(context, suc500_1(context));
    // } else {
    //   print('calenderGet - Some requests failed: $res');
    //   // bottomSheetType500(context, fail500_1(context));
    // }
  } catch (e) {
    bottomSheetType500(context, fail500_1(context));
  }
}


//[일별데이터] : 트랙명, 몇 일차
Future<diodart.Response> trackTitle_GET(BuildContext context, int tid, String selectedDay) async {

  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  String funNm = 'trackTitle_GET';
  String? tk = await getTk();

  try {
    final response = await dio.get(
        '$url/clear/routine/calendar/date',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $tk',
          },
          validateStatus: (status) {
            print('$funNm : ${status}');
            return status != null && status < 500; // 상태 확인을 명확하게
          },
        ),queryParameters : {"_date" : selectedDay}
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setIsTracking(true);
      pv.setTrackTitle(data);
    } else if (response.statusCode == 404) {
      pv.setIsTracking(false);
    } else {
    }
    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

//[일별데이터] : 건강정보 조회 - 금일 칼로리, 목표칼로리 조회, 섭취칼로리, 소모칼로리, 몸무게
Future<diodart.Response> health_SeletedDay_GET(BuildContext context, int tid, String selectedDay) async {

  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  String funNm = 'health_SeletedDay_GET';
  String? tk = await getTk();

  try {
    final response = await dio.get(
      '$url/meal_day/get/calorie_today/$selectedDay',
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
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setHealth(data);

    } else if (response.statusCode == 404) {

    } else {



    }
    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

//[일별데이터] : 루틴정보
Future<diodart.Response> routine_SelectdDay_GET(BuildContext context, int tid, String selectedDay) async {

  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  String funNm = 'routine_SelectdDay_GET';
  String? tk = await getTk();

  try {
    final response = await dio.get(
      '$url/clear/routine/success/routine/$selectedDay',
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
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      //pv.setHealth(data);

    } else if (response.statusCode == 404) {

    } else {



    }
    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}

//[일별데이터] : 기록정보
Future<diodart.Response> save_SelectdDay_GET(BuildContext context, int tid, String selectedDay) async {

  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  String funNm = 'save_SelectdDay_GET';
  String? tk = await getTk();

  try {
    final response = await dio.get(
      '$url/meal_day/get/mealhour_today/$selectedDay',
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
    );

    final res = response.data;
    print("$funNm : $res");

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setSave(data['mealday']);
    } else if (response.statusCode == 404) {

    } else {



    }
    return response;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    return diodart.Response(
        requestOptions: RequestOptions(path: ''), statusCode: 500);
  }
}








String dailyDateFormat(String inputDate) {

  // 문자열을 '-'를 기준으로 분리
  List<String> dateParts = inputDate.split('-');

  // 년, 월, 일 가져오기
  String year = dateParts[0];
  String month = dateParts[1];
  String day = dateParts[2];

  // 월 앞의 '0'을 제거 (만약 있으면)
  String formattedMonth = int.parse(month).toString();
  // 일 앞의 '0'을 제거 (만약 있으면)
  String formattedDay = int.parse(day).toString();

  // 원하는 형식으로 조합
  String formattedDate = '$formattedMonth월 $formattedDay일';
return formattedDate;
}