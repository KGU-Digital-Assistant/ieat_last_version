import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../constants.dart';

/**
 *
 * homeMainTopPart()
 * 트랙명, 일차
 * 목표 칼로리,
 * 오늘 섭취칼로리
 * 오늘 탄단지
 * 총 섭취
 * 소모
 * 몸무게
 *
 */
Future<void> homeMainTopPart(BuildContext context) async {
  await trackNmDDay_GET(context);
  await todayNutri_GET(context);
  await mealDayCalorieToday_GET(context);
}

Future<void> homeMainBottomPart(BuildContext context,String selectedDate) async {
// 트랙 루틴 리스트, 선택한 일자에 기록한 음식 리스트
await saveList_SelectdDay_GET(context,selectedDate);
}

Future<void> trackNmDDay_GET(BuildContext context) async {
  // final pv = Provider.of<HomeSave>(context, listen: false);

  String funNm = 'trackNmDDay_GET';
  print('$funNm - 요청시작');

  String? tk = await getTk();

  try {
    final response = await dio.get(
      '$url/track/group/get/$today/name_dday',
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
    if (response.statusCode == 200) {
      print(res);
      final hpv = Provider.of<HomeSave>(context, listen: false);
      hpv.setRunningTrackInfo(res);
    } else {
      print('$funNm Error(statusCode): ${response.statusCode}');
    }
    return response.data;
  } catch (e) {
    print('$funNm Error: $e');
  }
}

Future<void> todayNutri_GET(BuildContext context) async {
  // final pv = Provider.of<HomeSave>(context, listen: false);

  String funNm = 'todayNutri_GET';
  print('$funNm - 요청시작');

  String? tk = await getTk();

  try {
    final response = await dio.get(
      '$url/meal_day/get/goal_now_nutrient/$today',
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
    if (response.statusCode == 200) {
      print(res);
      //{carb: 196.92000000000002, protein: 72.53, fat: 53.58, gb_carb: 300.0, gb_protein: 60.0, gb_fat: 65.0}
      final hpv = Provider.of<HomeSave>(context, listen: false);
      hpv.setTodayNutir(res);
    } else {
      print('$funNm Error(statusCode): ${response.statusCode}');
    }
    return response.data;
  } catch (e) {
    print('$funNm Error: $e');
  }
}

Future<void> mealDayCalorieToday_GET(BuildContext context) async {
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
      final hpv = Provider.of<HomeSave>(context, listen: false);
      hpv.setTodayCalorie(res['todaycalorie']);
      hpv.setNowCalorie(res['nowcalorie']);
      hpv.setGoalcalorie(res['goalcalorie']);
      hpv.setBurnCalorie(res['burncalorie']);
      hpv.setWeight(res['weight']);
    } else {
      print('$funNm Error(statusCode): ${response.statusCode}');
    }
    return response.data;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

Future<void> trackRoutineList_GET(BuildContext context, int tid) async {
  // final pv = Provider.of<HomeSave>(context, listen: false);

  String funNm = 'trackRoutineList_GET';
  print('$funNm - 요청시작');

  String? tk = await getTk();
  try {
    final response = await dio.get('$url/track/routine/list/$tid',
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
        queryParameters: {
          'week ': 1,
          'weekday ': "월",
        });

    final res = response.data;
    print(res);
    if (response.statusCode == 200) {
      print(response.data);
      final hpv = Provider.of<HomeSave>(context, listen: false);
      hpv.setSelectedDateRoutineList(response.data);
    } else {
      print('$funNm Error(statusCode): ${response.statusCode}');
    }
    return response.data;
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}





//[bottom] : 선택한 날짜에 기록한 식단
Future<void> saveList_SelectdDay_GET(BuildContext context,String selectedDay) async {

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

      final pv = Provider.of<HomeSave>(context,listen: false);
      pv.setSaveList(data['mealday']);

    } else if (response.statusCode == 404) {

    } else {

    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}
