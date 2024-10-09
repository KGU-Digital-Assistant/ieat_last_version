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
import 'package:ieat/track/trackroutine.dart';
import 'package:ieat/util.dart';
import 'package:ieat/constants.dart';
import 'package:provider/provider.dart';

import '../init.dart';
import '../provider.dart';
import '../styleutil.dart';



/**
 * updateBurncalorie_PATCH : 소모 칼로리 저장
 * updateWeght_PATCH : 몸무게 저장
 *
 *
 *
 *
 * fomatDay() : 인덱스 값에 따라서 요일 출력  => return 월,화 수 등
 * */

Future<void> updateBurncalorie_PATCH(BuildContext context,int selectedBurnCalorieValue) async {
  String funNm = "updateBurncalorie_PATCH";
  String? tk = await getTk();
  print('$funNm - 요청시작');

  final pv = Provider.of<HomeSave>(context, listen: false);
  int burncalorie = selectedBurnCalorieValue;
  print("$burncalorie");
  String uri = '$url/meal_day/update/burncaloire/$today/$burncalorie';
  try {
    final response = await dio.patch(
      uri,
      options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': ' Bearer $tk'
          },
          validateStatus: (status) {
            print('$funNm : $status');
            return status! < 500;
          }),
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      pv.setBurnCalorie(burncalorie);
      print(pv.todayWeightCalories["burnCalorie"]);
      bottomSheetType500(context, suc500_1(context));
    } else {
      Navigator.pop(context);
      await simpleAlert("트랙 시작 후 기록할 수 있습니다.");
    }
  } catch (e) {
    Navigator.pop(context);
    await simpleAlert("트랙 시작 후 기록할 수 있습니다.");
    print('$funNm Error : $e');
  }
}
Future<void> updateWeght_PATCH(BuildContext context, int selectedWeghtValue) async {
  String funNm = "updateBurncalorie_PATCH";
  String? tk = await getTk();
  print('$funNm - 요청시작');

  final pv = Provider.of<HomeSave>(context, listen: false);
  int weight = selectedWeghtValue;
  String uri = '$url/meal_day/update/weight/$today/$weight';
  try {
    final response = await dio.patch(
      uri,
      options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': ' Bearer $tk'
          },
          validateStatus: (status) {
            print('$funNm : $status');
            return status! < 500;
          }),
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      pv.setWeight(weight);
      bottomSheetType500(context, suc500_1(context));
    } else {
      Navigator.pop(context);
      await simpleAlert("트랙 시작 후 기록할 수 있습니다.");
    }
  } catch (e) {
    Navigator.pop(context);
    await simpleAlert("트랙 시작 후 기록할 수 있습니다.");
    print('$funNm Error : $e');
  }
}


String formatDay(int idx) {
  const days = ['월', '화', '수', '목', '금', '토','일'];
  return days[idx];
}


//시간 String으로 넘겼을 때 14시 이렇게 반환
String extractHour(String time) {
  // 시(hour) 부분만 서브스트링으로 추출 (0번째부터 2번째까지)
  String hour = time.substring(0, 2);
  return hour;
}











