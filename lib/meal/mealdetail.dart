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
 * 무스에서
 *
 * */




class MealDetail_Sf extends StatefulWidget {
  const MealDetail_Sf({super.key, required this.type});

  final type;

  @override
  State<MealDetail_Sf> createState() => _MealDetail_SfState();
}

class _MealDetail_SfState extends State<MealDetail_Sf> {
  var test_mealTime = '나연';
  bool _isInitDataSet_Suc  = false;



//루틴 리스트 : 키값, 체트여부, 계획한 루틴명
  List<List<dynamic>> _Rlist = [    //예시 데이터
    [0, false, '계획1'],
    [1, false, '계획2'],
    [2, false, '계획3']
  ];
  bool _isgetHeart = true;  //예시 데이터 - 하트
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(_Rlist.toString());

    if (_isInitDataSet_Suc) {  //로딩화면
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'loading',
        theme: ThemeData(
        ),
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(47),
            child:
          AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "식단 ${widget.type}",
            style: Text14BlackBold,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              bottomShow(context);
            },
            icon: Icon(Icons.chevron_left, size: 30),
          ),
        )
    ),
        body: SingleChildScrollView(
          child: Consumer<OneMealDetailInfoProvider>(
            builder: (context,pv,child){
              return  Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      // shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      'assets/test/${pv.mealInfo['img']}.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '날짜',
                        style: Text10,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          '${pv.mealInfo['mealname']}',
                          style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        // TextButton(
                        //     onPressed: () {
                        //       print('상세 영양성분 확인');
                        //     },
                        //     child: Text('영양정보 > '))
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        '영양정보',
                        style: Text15Bold,
                      ),
                    ),
                  ),
                  Container(),
                ],
              );
            },
          ),
        ));
  }
}














