import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/setting.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import '../meal/mealsave.dart';
import '../track/trackaction.dart';
import 'homeaction.dart';
import 'homecalender.dart';
import 'package:ieat/moose.dart';

class Home_Sf extends StatefulWidget {
  const Home_Sf({super.key});

  @override
  State<Home_Sf> createState() => _Home_SfState();
}

class _Home_SfState extends State<Home_Sf> with TickerProviderStateMixin {
  late PieModel carBoChartData;
  late PieModel proChartData;
  late PieModel fatChartData;
  late AnimationController animationController;

  Map<String, int> goalNowNutrientInfo = {
    "carb": 0,
    "protein": 0,
    "fat": 0,
    "gb_carb": 300,
    "gb_protein": 60,
    "gb_fat": 65
  };
  List<bool> isNuFin = [false,false,true];

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.forward();
    // 계산 후 double을 int로 변환
    int carbCount = ((goalNowNutrientInfo['carb'] ?? 0).toDouble() /
        (goalNowNutrientInfo['gb_carb'] ?? 0).toDouble() *
        100).toInt(); // 예시로 100을 곱함
    int probCount = ((goalNowNutrientInfo['protein'] ?? 0).toDouble() /
        (goalNowNutrientInfo['gb_protein'] ?? 0).toDouble() *
        100)
        .toInt(); // 예시로 100을 곱함
    int fatbCount = ((goalNowNutrientInfo['fat'] ?? 0).toDouble() /
        (goalNowNutrientInfo['gb_fat'] ?? 0).toDouble() *
        100)
        .toInt(); // 예시로 100을 곱함
    setState(() {
      if(carbCount == 100 ) isNuFin[0] = true;
      if(probCount == 100 ) isNuFin[1] = true;
      if(fatbCount == 100 ) isNuFin[2] = true;

      carBoChartData = PieModel(
          count:  carbCount == 0 ? 69 : carbCount, // double을 int로 변환
          color: const Color(0xFF21C87D),
          thickness: 7);
      proChartData = PieModel(
          count:  probCount == 0 ? 81 : probCount, // double을 int로 변환
          color: const Color(0xFF21C87D),
          thickness: 7);
      fatChartData = PieModel(
          count:  fatbCount == 0 ? 100 : fatbCount, // double을 int로 변환
          color: const Color(0xFF21C87D),
          thickness: 7);
    });
  }
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }


  int _selectedBurnCalorieValue = 0;
  final List<int> _BurnCalorievalues =
  List.generate(300, (index) => index * 10); // 0부터 3000까지 10 단위로 값 생성
  int _selectedWeghtValue = 50;
  final List<int> _Weghtvalues =
  List.generate(300, (index) => index * 1); // 0부터 3000까지 10 단위로 값 생성

  Widget todayBurnCalorie() => Container(
      color: ColorMainBack,
      width: double.infinity,
      height: 500,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text("오늘 소모한 칼로리", style: Text25BoldBlack),
          Text("오늘은 활동적인 하루를 보내셨나요?", style: Text14Black),
          SizedBox(
            height: 70,
          ),
          Container(
            color: ColorMainBack,
            height: 130,
            width: 300,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem:
                  _BurnCalorievalues.indexOf(_selectedBurnCalorieValue)),
              itemExtent: 80.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedBurnCalorieValue = _BurnCalorievalues[index];
                });
              },
              children: _BurnCalorievalues.map(
                      (value) => Center(child: Text('$value'))).toList(),
            ),
          ),
          SizedBox(
            height: 70,
          ),
          SizedBox(
            width: 370,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await updateBurncalorie_PATCH(context, _selectedBurnCalorieValue);
                  //서버에서 트랙 시작 안 하면 기록 못하게 막힘
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.fromLTRB(10, 5, 10, 5),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(40, 30),
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
                        "저장하기",
                        style: Text22BoldBlack,
                      ),
                    )),
              ),
            ),
          )
        ],
      ));
  Widget todayWeight() => Container(
      color: ColorMainBack,
      width: double.infinity,
      height: 500,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text("오늘 나의 체중", style: Text25BoldBlack),
          Text("일주일 전보다 얼마나 달라졌나요?", style: Text14Black),
          SizedBox(
            height: 70,
          ),
          Container(
            color: ColorMainBack,
            height: 130,
            width: 300,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem: _Weghtvalues.indexOf(_selectedWeghtValue)),
              itemExtent: 80.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedWeghtValue = _Weghtvalues[index];
                });
              },
              children:
              _Weghtvalues.map((value) => Center(child: Text('$value')))
                  .toList(),
            ),
          ),
          SizedBox(
            height: 70,
          ),
          SizedBox(
            width: 370,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await updateWeght_PATCH(context, _selectedWeghtValue);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.fromLTRB(10, 5, 10, 5),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(40, 30),
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
                        "저장하기",
                        style: Text22BoldBlack,
                      ),
                    )),
              ),
            ),
          )
        ],
      ));
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                  size: 30,
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                ),
                onPressed: () {
                  bottomHide(context);
                  NvgToNxtPageSlide(context, const HomeboardCalender_Sf());
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.black,
                  size: 30,
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                ),
                onPressed: () {
                  bottomHide(context);
                  NvgToNxtPageSlide(context, const Setting_Sf());
                },
              ),
              SizedBox(
                width: 5,
              )
            ],
            title: Consumer<HomeSave>(builder: (context, pv, child) {
              Map<String, dynamic> trackNmDDay = pv.trackNmDDay;
              return pv.isTracking
                  ? Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 7, 0),
                    child: Text('${trackNmDDay['name']}',
                        style: TextStyle(
                            color: Color(0xFF009E54),
                            fontSize: 22,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w900)),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Text(
                      '+${trackNmDDay['dday']}',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/i-eat_Text_Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ));
            })),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 1, // 최소 높이
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$today(오늘)", style: Text16BoldBlack),
                SizedBox(height: 15),
                Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // 그림자 색상 및 투명도 설정
                          spreadRadius: 2, // 그림자 퍼짐 정도
                          blurRadius: 5,   // 그림자의 흐림 정도
                          offset: Offset(1, 3), // 그림자의 위치 (x, y)
                        ),
                      ],
                      color: ColorMainBack,
                      border: Border.all(
                          color: mainGrey.withOpacity(0.5),
                          width: 1.5
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 400,
                    width: double.maxFinite,
                    padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Stack(
                          children: [
                            SizedBox(
                              height: 100,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    // "${formatNumberWithComma(todaymealInfo['todaycalorie'])}",
                                    "2,980",
                                    style: GoogleFonts.racingSansOne(
                                      // decoration: TextDecoration.underline,
                                      fontSize: 89, // 폰트 크기 조절
                                      color: Colors.black, // 폰트 색상
                                      fontWeight: FontWeight.bold, // 굵기 조절
                                    ),
                                  )),
                            ),
                            SizedBox(
                              height: 100,
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "목표 칼로리 : 00kcal",
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff7F7F7F)),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        SizedBox(
                          // color: Colors.brown,
                          width: double.maxFinite,
                          height: 100,
                          child: Container(
                            width: 200,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    isNuFin[0]
                                        ?Container(
                                        width: 100,
                                        height: 100,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color : Color(0xff21C87D).withOpacity(0.18)
                                          )
                                          ,))
                                        :SizedBox(),
                                    AnimatedBuilder(
                                      animation: animationController,
                                      builder: (context, child) {
                                        if (animationController.value < 0.1) {
                                          return const SizedBox();
                                        }
                                        return SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Center(
                                              child: CustomPaint(
                                                size: const Size(95, 95),
                                                painter: _RadialChart(
                                                    carBoChartData, animationController.value),
                                              )),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                        width: 100,
                                        height: 100,
                                        child:  Padding(
                                            padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                // "${formatNumberWithComma(todaymealInfo['todaycalorie'])}",
                                                "탄",
                                                style: TextHomeNuTitle,
                                              ),
                                            ))),
                                    SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 53, 0, 0),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                                "69",
                                                // "${formatNumberWithComma(goalNowNutrientInfo['carb']!)}",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ))
                                  ],
                                ),
                                Stack(
                                  children: [
                                    isNuFin[1]
                                        ?Container(
                                        width: 100,
                                        height: 100,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color : Color(0xff21C87D).withOpacity(0.18)
                                          )
                                          ,))
                                        :SizedBox(),
                                    AnimatedBuilder(
                                      animation: animationController,
                                      builder: (context, child) {
                                        if (animationController.value < 0.1) {
                                          return const SizedBox();
                                        }
                                        return SizedBox(
                                          width: 100,
                                          height: double.maxFinite,
                                          child: Center(
                                              child: CustomPaint(
                                                size: const Size(95, 95),
                                                painter: _RadialChart(
                                                    proChartData, animationController.value),
                                              )),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                        width: 100,
                                        height: 100,
                                        child:  Padding(
                                            padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                "단",
                                                style: TextHomeNuTitle,
                                              ),
                                            ))),
                                    SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 53, 0, 0),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                                "81",
                                                // "${formatNumberWithComma(goalNowNutrientInfo['protein']!)}",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ))
                                  ],
                                ),
                                Stack(
                                  children: [
                                    isNuFin[2]
                                        ?Container(
                                      width: 100,
                                      height: 100,
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                      ),
                                    child:
                                    Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color : Color(0xff21C87D).withOpacity(0.18)
                                      )  
                                      ,))
                                        :SizedBox(),
                                    AnimatedBuilder(
                                      animation: animationController,
                                      builder: (context, child) {
                                        if (animationController.value < 0.1) {
                                          return const SizedBox();
                                        }
                                        return Container(
                                          width: 100,
                                          height: double.maxFinite,
                                          child: Center(
                                              child: CustomPaint(
                                                size: const Size(95, 95),
                                                painter: _RadialChart(
                                                    fatChartData, animationController.value),
                                              )),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                        width: 100,
                                        height: 100,
                                        child:  Padding(
                                            padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text("지",
                                                  style: TextHomeNuTitle),
                                            ))),
                                    SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 53, 0, 0),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                                "100",
                                                // "${formatNumberWithComma(goalNowNutrientInfo['fat']!)}",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 8,),
                        ElevatedButton(
                          onPressed: () {
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(double.maxFinite, 40),
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
                                side: BorderSide(
                                  color: Colors.transparent,
                                  width: 1, // 테두리 두께
                                ),
                              ),
                            ),
                            overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                          ),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 40,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text('총 섭취 칼로리',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: mainBlack,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Spacer(),
                                Align(
                                  alignment: AlignmentDirectional(1, 0),
                                  child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                      child: Consumer<HomeSave>(
                                        builder: (context, pv, child) {
                                          return Text(
                                              '${formatNumberWithComma(pv.todayWeightCalories['takeCalorie']!)}',
                                              style: TextStyle(
                                                color: mainBlack,
                                                fontFamily: 'Readex Pro',
                                                fontSize: 21,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ));
                                        },
                                      )),
                                ),
                                Container(
                                  width: 38,
                                  child: Align(
                                    alignment: AlignmentDirectional(1, 0),
                                    child: Text('kg',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: mainBlack,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            bottomHide(context);
                            bottomSheetType500(context, todayBurnCalorie());
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(double.maxFinite, 40),
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
                                side: BorderSide(
                                  color: Colors.transparent,
                                  width: 1, // 테두리 두께
                                ),
                              ),
                            ),
                            overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                          ),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 40,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text('소모칼로리',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: mainBlack,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Spacer(),
                                Align(
                                  alignment: AlignmentDirectional(1, 0),
                                  child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                      child: Consumer<HomeSave>(
                                        builder: (context, pv, child) {
                                          return Text(
                                              '${formatNumberWithComma(pv.todayWeightCalories['burnCalorie']!)}',
                                              style: TextStyle(
                                                color: mainBlack,
                                                fontFamily: 'Readex Pro',
                                                fontSize: 21,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ));
                                        },
                                      )),
                                ),
                                Container(
                                  width: 38,
                                  child: Align(
                                    alignment: AlignmentDirectional(1, 0),
                                    child: Text('kg',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: mainBlack,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            bottomHide(context);
                            bottomSheetType500(context, todayWeight());
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(double.maxFinite, 40),
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
                                side: BorderSide(
                                  color: Colors.transparent,
                                  width: 1, // 테두리 두께
                                ),
                              ),
                            ),
                            overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                          ),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 40,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text('몸무게',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: mainBlack,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Spacer(),
                                Align(
                                  alignment: AlignmentDirectional(1, 0),
                                  child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                      child: Consumer<HomeSave>(
                                        builder: (context, pv, child) {
                                          return Text(
                                              '${formatNumberWithComma(pv.todayWeightCalories['weight']!)}',
                                              style: TextStyle(
                                                color: mainBlack,
                                                fontFamily: 'Readex Pro',
                                                fontSize: 21,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ));
                                        },
                                      )),
                                ),
                                Container(
                                  width: 38,
                                  child: Align(
                                    alignment: AlignmentDirectional(1, 0),
                                    child: Text('kg',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: mainBlack,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 25),
                Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // 그림자 색상 및 투명도 설정
                          spreadRadius: 2, // 그림자 퍼짐 정도
                          blurRadius: 5,   // 그림자의 흐림 정도
                          offset: Offset(1, 3), // 그림자의 위치 (x, y)
                        ),
                      ],
                      color: ColorMainBack,
                      border: Border.all(
                          color: mainGrey.withOpacity(0.5),
                        width: 1.5
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 600,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.width * 1, // 최소 높이
                    ),
                    width: double.maxFinite,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: WeekSf()),
              ],
            ),
          ),
        ),
      )
    );
  }
}

//메인화면 차트(home.dart)
class _RadialChart extends CustomPainter {
  final PieModel data;
  final double value;

  _RadialChart(this.data, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    Offset offset = Offset(size.width / 2, size.height / 2);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = data.thickness; // 각 데이터에 대해 두께 설정
    paint.color = data.color;

    double _count = data.count.toDouble();
    _count = (_count * value + _count) - data.count;

    double position = double.parse("0.${8 - 0}");
    double radius = ((size.width / 2) * position) - 5;
    double _nextAngle = 2 * math.pi * (_count / 100);

    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: radius),
      -math.pi / 2,
      _nextAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class WeekSf extends StatefulWidget {
  const WeekSf({super.key});

  @override
  State<WeekSf> createState() => _WeekSfState();
}

class _WeekSfState extends State<WeekSf> {
  // DayWidget 정의
  Widget DayWidget(int idx, BuildContext context) {
    return Container(
      width: 45.0,
      height: 70.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: ColorMainBack,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isClickedWeek[idx] == 1 ? Color1BAF79 : mainGrey.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Consumer<trackDetailTabProvider>(
                    builder: (context, pv, child) {
                      int week = pv.selectedWeek;
                      return Text(
                        "${(week - 1) * 7 + (idx + 1)}",
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xff1E1E1E).withOpacity(0.3),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${formatDay(idx)}요일',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Noto Sans KR',
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  List<int> isClickedWeek = [0,0,0,0,0,0,0]; // 탭 클릭 상태 초기화
  List<String> imgs = ["food1","food2","food3","food4","food3","food4"];   //테스트 용도

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int todayweek = getTodayWeekday();
    setState(() {
      isClickedWeek[todayweek] = 1;
    });
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7, // 탭의 개수를 지정
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: const Color(0xffEBFFEE),
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 5,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70), // TabBar의 높이 조정
            child: TabBar(
              isScrollable: false,
              // dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: mainBlack,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: mainBlack.withOpacity(0.8),
              ),
              tabs: List.generate(7, (index) {
                return DayWidget(index, context); // 각 탭의 내용
              }),
              onTap: (idx) {
                setState(() {
                  isClickedWeek = List.filled(7, 0); // 모든 상태 초기화
                  isClickedWeek[idx] = 1; // 클릭된 탭 상태 설정
                });
              },
            ),
          ),
          elevation: 0, // AppBar의 그림자 제거
        ),
        body:
        TabBarView(
          children: List.generate(
            7,
                (idx) =>Container(
                  padding: EdgeInsets.only(top: 10),
                  // color: CupertinoColors.activeGreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 110,
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: Container(
                              width: 100,
                              height: 110,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                      imgs.length+1,
                                          (idx)=>
                                      idx == 0
                                          ?ElevatedButton(onPressed: (){
                                            bottomHide(context);
                                            NvgToNxtPageSlide(context, MealSave(type : 'save'));
                                      }, style: ButtonStyle(
                                          minimumSize: MaterialStateProperty.all(Size(70, 70)), // 최소 크기 설정
                                          backgroundColor: MaterialStateProperty.all(Colors.transparent), // 배경색 투명
                                          shadowColor: MaterialStateProperty.all(Colors.transparent), // 그림자 제거
                                          elevation: MaterialStateProperty.all(0), // 높이 제거
                                          padding: MaterialStateProperty.all(EdgeInsets.zero), // 패딩 제거
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0), // 모서리 둥글기 제거
                                            ),
                                          ),
                                          overlayColor: MaterialStateProperty.all<Color>(
                                            Colors.transparent,
                                          )
                                      ),child: Container(
                                        width: 75,
                                        height: 110,
                                        decoration: BoxDecoration(color: ColorMainBack),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 70,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(25),
                                                  // shape: BoxShape.circle,
                                                  color: mainGrey.withOpacity(0.1)
                                              ),
                                              child: Icon(Icons.add, color: mainBlack,),
                                            ),
                                            Text('',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w900,
                                                )),
                                          ],
                                        ),
                                      ))
                                          :Container(
                                        width: 75,
                                        height: 105,
                                        decoration: BoxDecoration(color: ColorMainBack),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(onPressed: (){
                                              final mpv = Provider.of<OneFoodDetail>(context, listen: false);
                                              // mpv.setimg(imgs[idx-1]);
                                              // mpv.settime("06:04");
                                              // mpv.setmealname("식단", idx);
                                              NvgToNxtPage(context, MooseDetail(type: "음식 상세보기"));
                                            },
                                                style: ButtonStyle(
                                                  minimumSize: MaterialStateProperty.all(Size(70, 70)), // 최소 크기 설정
                                                  backgroundColor: MaterialStateProperty.all(Colors.transparent), // 배경색 투명
                                                  shadowColor: MaterialStateProperty.all(Colors.transparent), // 그림자 제거
                                                  elevation: MaterialStateProperty.all(0), // 높이 제거
                                                  padding: MaterialStateProperty.all(EdgeInsets.zero), // 패딩 제거
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(0), // 모서리 둥글기 제거
                                                    ),
                                                  ),
                                                    overlayColor: MaterialStateProperty.all<Color>(
                                                      Colors.transparent,
                                                    )
                                                ),
                                                child: Container(
                                              width: 70,
                                              height: 70,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Image.network(
                                                'assets/test/${imgs[idx-1]}.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                            SizedBox(height: 3),
                                            Text('06:04',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w900,
                                                )),
                                          ],
                                        ),
                                      )
                                  ),
                                ),
                              )),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text("트랙을 시작하고 루틴을 확인해보세요!", style: Text16BoldBlack,),
                      ),)
                    ],
                  ),
                ),
          ),
        )
      ),
    );
  }
}


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
  await mealDayCalorieToday_GET(context);
  await dailyTargetCalorie_GET(context); //
  await mealDayCalorieToday_GET(context); //
}


Future<void> homeMainBottomPart() async {

}

