
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



//총 5개의 함수 호출
Future<void> calenderMonthly_Get(BuildContext context,String selectedDay) async {

  try {
    //처음에 200,200,404,404가 정상임(데이터 없어서 404)
    await recordDay_count_GET(context, selectedDay);
    await routine_count_GET(context, selectedDay);
    await avgCalorie_GET(context, selectedDay);
    await goalCalorie_GET(context, selectedDay);
    await calendertotal_GET(context,selectedDay);
  } catch (e) {
    popWithSlideAnimation(context, 2);
  }
}

//[월별데이터] 기록일
Future<diodart.Response> recordDay_count_GET(BuildContext context, String selectedDay) async {
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
//[월별데이터] 지킨 루틴 수
Future<diodart.Response> routine_count_GET(BuildContext context, String selectedDay) async {
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
//[월별데이터] 일 평균 칼로리
Future<diodart.Response> avgCalorie_GET(BuildContext context,String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);
  String funNm = 'avgCalorie_GET';
  String? tk = await getTk();
  List<int> yearAndMonth = getYearAndMonth(selectedDay);

  try {
    final response = await dio.get(
      '$url/meal_day/get/meal_avg_calorie/${yearAndMonth[0]}/${yearAndMonth[1]}',
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

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      pv.setAvgCalorie(data['calorie']);
      print("$funNm : $res");
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
//[월별데이터] 일 목표 칼로리
Future<void> goalCalorie_GET(BuildContext context,String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);
  final hpv = Provider.of<HomeSave>(context,listen: false);
  if(hpv.trackNmDDay['tid'] == -1) {
    pv.setGoalCalorie(2000);
  }else{
    String funNm = 'routine_count_GET';
    String? tk = await getTk();

    try {
      final response = await dio.get(
        '$url/track/get/${hpv.trackNmDDay['tid']}/Info',
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
    } catch (e) {
// 오류 처리
      print('$funNm Error: $e');
    }
  }

}
//[월별데이터] 달력에 백그라운드 표시할 기록한 날짜
Future<void> calendertotal_GET(BuildContext context, String selectedDay) async {

  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);

  String funNm = 'routine_count_GET';
  int? uid = await getUserId();
  String? tk = await getTk();
  List<int> yearAndMonth = getYearAndMonth(selectedDay);

  try {
    final response = await dio.get(
      '$url/meal_day/get/calender/$uid',
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
        "month" : yearAndMonth[1],
        "year" : yearAndMonth[0]
      }
    );

    final res = response.data;

    if (response.statusCode == 200) {
      var data = Map<String, dynamic>.from(res);
      print("$funNm : $res");
      pv.setMonthRecordDayInfo(data);
    } else if (response.statusCode == 404) {
    } else {
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
    print('$funNm Error: $e');
  }
}


//총 4개의 함수 호출
Future<void> calenderDaily_Get(BuildContext context,String selectedDay) async {
  final pv = Provider.of<CalenderSelectedProvider>(context, listen: false);
  pv.setSelectedDay(selectedDay);
  // List<bool> res = [false, false, false, false];
  c_mealDayCalorieToday_GET(context);
  c_saveList_SelectdDay_GET(context,selectedDay);


  // try {
  //
  //   //처음에 404가,404가,200,404가 정상임(데이터 없어서 404)
  //   // var response1 = await trackTitle_GET(context,selectedDay);
  //   // if (response1.statusCode == 200 || response1.statusCode == 204) res[0] = true;
  //   //
  //   // var response2 = await health_SeletedDay_GET(context,selectedDay);
  //   // if (response2.statusCode == 200 || response2.statusCode == 204) res[1] = true;
  //   //
  //   // var response3 = await routine_SelectdDay_GET(context, selectedDay);
  //   // if (response3.statusCode == 200 || response3.statusCode == 204) res[2] = true;
  //   //
  //   // var response4 = await save_SelectdDay_GET(context,selectedDay);
  //   // if (response4.statusCode == 200 || response4.statusCode == 204) res[3] = true;
  //   //
  //
  //   print(res);
  //   // 모든 요청이 성공했는지 확인
  //   // if (res.every((element) => element == true)) {
  //   //   // bottomSheetType500(context, suc500_1(context));
  //   // } else {
  //   //   print('calenderGet - Some requests failed: $res');
  //   //   // bottomSheetType500(context, fail500_1(context));
  //   // }
  // } catch (e) {
  //   bottomSheetType500(context, fail500_1(context));
  // }
}
//[일별데이터] : 트랙명, 몇 일차
Future<diodart.Response> trackTitle_GET(BuildContext context, String selectedDay) async {

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
Future<diodart.Response> health_SeletedDay_GET(BuildContext context, String selectedDay) async {

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
Future<diodart.Response> routine_SelectdDay_GET(BuildContext context,String selectedDay) async {

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
Future<diodart.Response> save_SelectdDay_GET(BuildContext context,String selectedDay) async {

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




Future<void> c_mealDayCalorieToday_GET(BuildContext context) async {
  String? tk = await getTk();
  print("tk : $tk");
  String funNm = 'mealDayCalorieToday_GET';
  print('$funNm - 요청시작');
  String uri = '$url/meal_day/get/calorie_today/$today';
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
    // final data = jsonDecode(response.data);
    print(response.data);
    //
    // Response body
    // Download
    // {
    //   "todaycalorie": 729.62,
    //   "goalcalorie": 0,
    //   "nowcalorie": 729.62,
    //   "burncalorie": 0,
    //   "weight": 0
    // }
    if (response.statusCode == 200) {
      Map<String, dynamic> res = response.data;
      final hpv = Provider.of<CalenderSelectedProvider>(context, listen: false);
      hpv.setHealth(res);
    } else {
      print('$funNm Error(statusCode): ${response.statusCode}');
    }
    return response.data;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}
Future<void> c_saveList_SelectdDay_GET(BuildContext context,String selectedDay) async {

  String funNm = 'save_SelectdDay_GET';
  String? tk = await getTk();

  try {
    final response = await dio.get(
      '$url/meal_day/get/mealhour_today/$today',
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
      //{
      //   "mealday": [
      //     {
      //       "date": "20:31",
      //       "picture": "https://storage.googleapis.com/ieat-76bd6.appspot.com/meal/2_2024-11-03-202902?Expires=1730646751&GoogleAccessId=firebase-adminsdk-eigep%40ieat-76bd6.iam.gserviceaccount.com&Signature=usXiV94%2BYRokFzwL8aEDsgAgpNGmHre4%2B5ZqVzlnz0Td6pwejZwJT%2Fl2usdq7pNExjDGDlSEs77zP7CyaB529JAH%2BwiHZmpNL0spjl3WSzg6JxkQaH%2FKnY0xLx96lQYulb%2FoFW5DzLU6ZPSIDMZzTKcAO3nTkCLj2vgB14d69Ux9OvbKvpvs7i1TxZuJDSV6%2BXaEvWNuCHdkIT7Lpl4ODe%2BGIAZepv8KAA1HY6JHH%2BIxF%2FpRfgK8fmmYPsS4VvHk4b4MgXYc9TcD8AEpy1nEcR6rug8Q0U78p9lzyrDK9GC%2FisbYaaouHDikbgmzwwyw65Zgy6Wcev7vR99lqC5WIA%3D%3D"
      //     },
      //     {
      //       "date": "22:22",
      //       "picture": "https://storage.googleapis.com/ieat-76bd6.appspot.com/meal/2_2024-11-03-222248?Expires=1730646751&GoogleAccessId=firebase-adminsdk-eigep%40ieat-76bd6.iam.gserviceaccount.com&Signature=Aek4MsJ%2FhDa625Jgf669LWLpHLGmJ46P4%2FFCKw8FMOBoCWnzaXzsRyNuZGI3byG9GjN3LvJNjtlmqZnEAj0n3tG5BrBoiD0e%2BbXvx8mHh2ePwHIQ7Fi4DfmzPJniQ3I7cH4Q5%2B0DgqTyAITd%2FAE1NfooU5mVLmgf2kivlldbZfAq7Uk%2BhG68tXQUlP9JrfMQJ5H%2FM92ZbW72vxaEAaOeogANwwJqXNv74Zo5bit%2Bs6xQ51u1WnveIAclCUmjkrv23ofejgf3dSL74zhAH3Lz4zTqJTB96NHCr45oFruN9L0rFDfY2BbrEtuE7iq9O9PNOV%2Fwu8ELjK5cuvdjAIQi6A%3D%3D"
      //     },
      //     {
      //       "date": "22:24",
      //       "picture": "https://storage.googleapis.com/ieat-76bd6.appspot.com/meal/2_2024-11-03-222441?Expires=1730646751&GoogleAccessId=firebase-adminsdk-eigep%40ieat-76bd6.iam.gserviceaccount.com&Signature=FXzeMzCk2lAdhyBC3TLy59zgR38G9LGaB0ae46%2BVtgtvsv9rJY012SdYQt1%2BgasUyebb0uTUAgKq2PBOp5KJxmWn0CCQy5F169CWeHBeV0VyNp7zD8d2cVo8PFko%2B2WO0h1dPEr1PIaeuGFx5yrCEWlUQDylbXqJI%2F2EWfNm8rywKIiEfASIXT9seb5p5OPXFGsUIrl3Uo8oma2ZuA8n2Ij%2FXbjasRd%2B21nJNBuPiqSbF5Epqut7%2B4V9JvHIdqRTMGWNDX6zkyDq8%2BXnWMRUOXLGjSRYuI%2BMb1Ud760hNRaGfmuLh8orz38kRFrQCA%2BHDmOnMslZHH6a1NqOFciUXA%3D%3D"
      //     }
      //   ]
      // }

      final pv = Provider.of<CalenderSelectedProvider>(context,listen: false);
      pv.setSave(data['mealday']);

    } else if (response.statusCode == 404) {

    } else {

    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}
