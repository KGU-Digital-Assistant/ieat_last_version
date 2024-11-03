import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // jsonDecode 사용을 위해 필요
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/home/homeaction.dart';
import 'package:ieat/moose.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/setting.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/track/trackroutineaction.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeago/timeago.dart';
import '../constants.dart';

class RoutineDetail extends StatefulWidget {
  const RoutineDetail({super.key, required this.type});

  final type; //"생성", "상세보기"

  @override
  State<RoutineDetail> createState() => _RoutineDetailState();
}

class _RoutineDetailState extends State<RoutineDetail> {
  int selectedHour = 0;
  int selectedMinute = 0;
  int selectedA = 0; //0 : 오전, 1 : 오후
  TextEditingController routine_GoalKcal_Controller = TextEditingController();
  List<dynamic> selectedDate = ["", ""];
  final FocusNode textFieldFocusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabpv = Provider.of<trackDetailTabProvider>(context, listen: false);
      setState(() {
        selectedDate[0] = tabpv.selectedWeek;
        selectedDate[1] = formatDay(tabpv.selectedDay);
      });
      createRoutine_1_POST(context); //루틴 생성
    });
  }

  bool isEditing = false;
  String rnm = '새로운 루틴';
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      //onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "루틴 ${widget.type}",
            style: Text20BoldBlack,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              bottomShow(context);
            },
            icon: Icon(Icons.chevron_left, size: 30),
          ),
        ),
        body: SingleChildScrollView(
          child: Consumer<OneRoutineDetailInfoProvider>(
              builder: (context, pv, child) {
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  pv.oneRoutineInfo['repeat']
                  ?Text('매주 ${pv.oneRoutineInfo['weekday']}요일',
                      style: TextStyle(
                          color: mainBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w600))
                  :Text('${selectedDate[0]}주차 ${pv.oneRoutineInfo['weekday']}요일',
                      style: TextStyle(
                          color: mainBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)), //루틴명
                  Stack(
                    children: [
                      if (isEditing)
                        Row(
                          children: [
                            SizedBox(
                                width: 200,
                                height: 50,
                                child: TextField(
                                  style: Text24BoldBlack,
                                  // 입력하는 텍스트 스타일
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        15, 0, 0, 5), // 왼쪽 여백 조정
                                    hintText: rnm,
                                    hintStyle: Text24BoldBlack,
                                    border: InputBorder.none, // 모든 테두리 제거
                                  ),
                                  controller: controller..text = rnm,
                                  // 기존 텍스트로 초기화
                                  onSubmitted: (newText) {
                                    setState(() {
                                      rnm = newText; // 새 텍스트로 업데이트
                                      isEditing = true; // 편집 모드 종료
                                    });
                                  },
                                )),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                  child: SizedBox(
                                      width: 100,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsets>(
                                              EdgeInsets.zero), // 패딩 없애기
                                          overlayColor:
                                              MaterialStateProperty.all<Color>(
                                            Colors.transparent,
                                          ),
                                        ),
                                        child: Text('저장'),
                                        onPressed: () {
                                          setState(() {
                                            rnm = controller.text; // 텍스트 업데이트
                                            isEditing = false; // 편집 모드 종료
                                          });

                                          final rpv = Provider.of<
                                                  OneRoutineDetailInfoProvider>(
                                              context,
                                              listen: false);
                                          rpv.setRoutineNm(controller.text);
                                        },
                                      ))),
                            )
                          ],
                        )
                      else
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: TextButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.zero),
                                          // 패딩 없애기
                                          overlayColor:
                                              MaterialStateProperty.all<Color>(
                                            Colors.transparent,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isEditing) {
                                              rnm = controller.text; // 텍스트 업데이트
                                              isEditing = false; // 편집 모드 종료
                                            } else {
                                              isEditing = true; // 편집 모드 시작
                                            }
                                          });
                                        },
                                        child: Text(
                                            '${pv.oneRoutineInfo['title'] ?? "새로운 루틴"}',
                                            style: Text24BoldBlack))),
                              ),
                              SizedBox(
                                height: 44,
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Icon(Icons.create_outlined,
                                      color: mainBlack, size: 20),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      height: 280,
                      width: 320,
                      decoration: BoxDecoration(
                        color: ColorBackGround,
                        // 배경색 설정
                        borderRadius: BorderRadius.circular(20),
                        // 모서리 둥글기 설정
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // 그림자 색상
                            spreadRadius: 2, // 그림자 확산 정도
                            blurRadius: 105, // 흐림 정도
                            offset: Offset(0, 3), // 그림자 위치 (x, y)
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text('선택된 시간: $selectedHour:$selectedMinute'),
                            SizedBox(
                              width: 100,
                              child: CupertinoPicker(
                                itemExtent: 70.0,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    selectedHour = index; // 시간 선택
                                  });

                                  final rpv =
                                      Provider.of<OneRoutineDetailInfoProvider>(
                                          context,
                                          listen: false);
                                  rpv.setColock("hour", index + 1);
                                },
                                children:
                                    List<Widget>.generate(23, (int index) {
                                  return Center(child: Text('${index + 1}'));
                                }),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: CupertinoPicker(
                                itemExtent: 70.0,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    selectedMinute = index; // 분 선택
                                  });

                                  final rpv =
                                      Provider.of<OneRoutineDetailInfoProvider>(
                                          context,
                                          listen: false);
                                  rpv.setColock("minute", index);
                                },
                                children:
                                    List<Widget>.generate(60, (int index) {
                                  return index <= 9
                                      ? Center(child: Text('0$index'))
                                      : Center(child: Text('$index'));
                                }),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: CupertinoPicker(
                                itemExtent: 70.0,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    selectedA = index; // 분 선택
                                  });
                                },
                                children: List<Widget>.generate(2, (int index) {
                                  return index == 0
                                      ? Center(child: Text('AM'))
                                      : Center(child: Text('PM'));
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), //select time
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      // bottomHide(context);
                      Get.defaultDialog(
                        title: "요일 선택",
                        titleStyle: Text20BoldBlack,
                        content: SizedBox(
                            height: 400,
                            width: MediaQuery.sizeOf(context).width,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child:
                              Consumer<OneRoutineDetailInfoProvider>(
                                  builder: (context, pv, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: List.generate(
                                          7,
                                              (idx) => ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                pv.setRoutineWeekDay('${fomatDay(idx)}');
                                              }, child: Text('${fomatDay(idx)}'))),
                                    );
                                  }),
                            )),
                        barrierDismissible: true, // 바깥 영역 클릭 시 닫히지 않도록 설정
                        backgroundColor: Colors.white, // 다이얼로그 배경색
                        radius: 10, // 모서리 둥글기
                      );
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(MediaQuery.sizeOf(context).width, 45),
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
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: colorMainBolder,
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
                      height: 55,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text('요일',
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
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                child: Text('${pv.oneRoutineInfo['weekday']}요일',
                                    style: TextStyle(
                                      color: mainBlack,
                                      fontFamily: 'Readex Pro',
                                      fontSize: 21,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ))),
                          ),
                        ],
                      ),
                    ),
                  ), //요일
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // bottomHide(context);
                      Get.defaultDialog(
                        title: "시간대 선택",
                        titleStyle: Text14BlackBold,
                        content: SizedBox(
                            height: 400,
                            width: MediaQuery.sizeOf(context).width,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child:
                              Consumer<OneRoutineDetailInfoProvider>(
                                  builder: (context, pv, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: List.generate(
                                          7,
                                              (idx) => ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                pv.setRoutineTime('${timeList[idx]}');
                                              }, child: Text('${timeList[idx]}'))),
                                    );
                                  }),
                            )),
                        barrierDismissible: true, // 바깥 영역 클릭 시 닫히지 않도록 설정
                        backgroundColor: Colors.white, // 다이얼로그 배경색
                        radius: 10, // 모서리 둥글기
                      );
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(MediaQuery.sizeOf(context).width, 45),
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
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: colorMainBolder,
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
                      height: 55,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text('시간대',
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
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                child: Text('${pv.oneRoutineInfo['time']}',
                                    style: TextStyle(
                                      color: mainBlack,
                                      fontSize: 21,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ))),
                          ),
                        ],
                      ),
                    ),
                  ), //시간대
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 55,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                      color: ColorMainBack,
                      borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                    color: colorMainBolder,
                    width: 1,
                  ),
                    ),
                    child :Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Text('반복',
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
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Consumer<RoutinListProvider>(
                                builder: (context, pv, child) {
                                  return Text('',
                                      style: TextStyle(
                                        color: mainBlack,
                                        fontSize: 21,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      ));
                                },
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      bottomHide(context);
                      bottomSheetType300(context, Container(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text('목표 칼로리 설정',style: Text20BoldBlack,),
                            Image.asset(
                              'assets/test/text_burnkcalIcon.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width*0.2,
                              child: TextField(
                                focusNode: textFieldFocusNode, // TextField에 FocusNode 연결
                                textAlign: TextAlign.center,
                                controller: routine_GoalKcal_Controller,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey), // 기본 언더라인 색상
                                  ),
                                  hintText: pv.oneRoutineInfo['calorie'] != null
                                      ? pv.oneRoutineInfo['calorie'].toString()
                                      : '칼로리를 입력하세요',
                                  hintStyle: TextStyle(
                                    color: Colors.grey, // 힌트 텍스트 색상
                                    fontSize: 25, // 힌트 텍스트 크기
                                    fontWeight: FontWeight.bold, // 힌트 텍스트 두께
                                  ),
                                  border: InputBorder.none, // 모든 테두리 제거
                                ),
                                onChanged: (value){
                                  pv.setGoalKcal(routine_GoalKcal_Controller.text);
                                },
                                keyboardType: TextInputType.number,
                              ),
                            )
                          ],
                        ),
                      ));
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(MediaQuery.sizeOf(context).width, 45),
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
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: colorMainBolder,
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
                      height: 55,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text('목표 칼로리',
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
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                child: Text('${pv.oneRoutineInfo['calorie']}',
                                    style: TextStyle(
                                      color: mainBlack,
                                      fontSize: 21,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ))),
                          ),
                          Container(
                            width: 38,
                            child: Align(
                              alignment: AlignmentDirectional(1, 0),
                              child: Text('kcal',
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
                  ), //목표칼로리
                  SizedBox(height: 50),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        updateRoutine_POST(context);
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.fromLTRB(0, 0, 0, 0),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(280, 55),
                        ),
                        maximumSize: MaterialStateProperty.all<Size>(
                          Size(280, 55),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff20C387),
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: colorMainBolder,
                              width: 1, // 테두리 두께
                            ),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text('저장하기',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: ColorMainBack,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
