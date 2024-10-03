
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as diodart;
import 'package:flutter/material.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants.dart';
import '../provider.dart';
import 'homecalenderapi.dart';



class HomeboardCalender_Sf extends StatefulWidget {
  const HomeboardCalender_Sf({super.key});

  @override
  State<HomeboardCalender_Sf> createState() => _HomeboardCalender_SfState();
}

class _HomeboardCalender_SfState extends State<HomeboardCalender_Sf> {
  CalendarFormat _calendarFormat = CalendarFormat.month;  // 캘린더 형식
  DateTime _focusedDay = DateTime.now();  // 현재 날짜
  DateTime? _selectedDay;  // 선택된 날짜
// 예시 데이터

  bool selectedDayType = false;  //false : 클릭 x, true : 클릭,
  
  String _selectedEvent = '';
int tid = -1;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final pv = Provider.of<HomeSave>(context, listen: false);
    //   pv.setPageType(widget.pagetype);
    // });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<CalenderSelectedProvider>(
        builder : (context,pv,child){
          final Map<String, dynamic> dInfo = pv.dailyInfo;
          return Scaffold(
            appBar: AppBar(
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                centerTitle: true,
                title: Text("캘린더", style: Text14BlackBold,),
                leading: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 30,
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.transparent,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: (){}, icon:Icon(Icons.chevron_left)),
                      Text('2024년 10월', style: Text20BoldBlack),
                      IconButton(onPressed: (){}, icon:Icon(Icons.chevron_right))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 90,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Text('기록일', style: TextCalenderMonthlyInfoTitle),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Text('${pv.monthlyInfo['recordDay']['record_cnt']}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w900,
                                    )),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Text('/${pv.monthlyInfo['recordDay']['all_cnt']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('지킨 루틴',
                                  style: TextCalenderMonthlyInfoTitle),
                              Text('${pv.monthlyInfo['routine']['success_cnt']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w900,
                                  )),
                              Text('/${pv.monthlyInfo['routine']['all_cnt']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('일평균 칼로리',
                                  style: TextCalenderMonthlyInfoTitle),
                              Text('${pv.monthlyInfo['avgCalorieOfDay']['save_calorie']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w900,
                                  )),
                              Text('/${pv.monthlyInfo['avgCalorieOfDay']['goal_calorie']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2050),
                    // locale: 'ko_KR',  // 한국어 설정
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        selectedDayType = true;
                      });
                      String formatSelectedDay = DateFormat('yyyy-MM-dd').format(selectedDay);
                      calenderDaily_Get(context,0, formatSelectedDay);
                      //차이점 요약:
                      // selectedDay는 사용자가 캘린더에서 선택한 날짜이고,
                      // focusedDay는 현재 캘린더가 어떤 날짜를 중심으로 표시되고 있는지 나타냅니다.
                      // 보통 focusedDay는 캘린더가 월별로 스크롤될 때 변경되지만, selectedDay는 사용자가 특정 날짜를 클릭할 때만 변경됩니다.
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    headerVisible: false,  // 기본 헤더 제거
                    calendarBuilders: CalendarBuilders(
                      todayBuilder: (context, date, _) {  //오늘 날짜 style 적용
                        return Container(
                          decoration: const BoxDecoration(
                              color: Colors.transparent
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextCalenderToday,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),  // 날짜와 데이터 사이 간격
                  //selectedDayType : 날짜 클릭 여부
                  selectedDayType ? Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.width * 1, // 최소 높이
                    ),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: ColorMainBack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dailyDateFormat(pv.dailyInfo['selectedDay'])),
                            dInfo['isTracking']
                                ?RichText(text: TextSpan(
                                children: [
                                  TextSpan(text : "${dInfo['selectedDayTrackTitle']['TNm']}"),
                                  TextSpan(text : "${dInfo['selectedDayTrackTitle']['TCountingDay']}")
                                ]
                            ))
                                :SizedBox()
                          ],
                        ),
                        RichText(text: TextSpan(
                            children: [
                              TextSpan(text : "${dInfo['health']['totalCalorie']}"),
                              TextSpan(text : "kcal")
                            ]
                        )),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFCDCFD0),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          width: MediaQuery.sizeOf(context).width,
                          height: 40,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Text('섭취칼로리',
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
                                          '${dInfo['health']['burnCalorie']}',
                                          style: TextStyle(
                                            color: mainBlack,
                                            fontFamily: 'Readex Pro',
                                            fontSize: 21,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                          ));
                                    },
                                  ),
                                ),
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFCDCFD0),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          width: MediaQuery.sizeOf(context).width,
                          height: 40,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
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
                                    child: Text(
                                        '${dInfo['health']['burnCalorie']}',
                                        style: TextStyle(
                                          color: mainBlack,
                                          fontFamily: 'Readex Pro',
                                          fontSize: 21,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ))
                                ),
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFCDCFD0),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          width: MediaQuery.sizeOf(context).width,
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
                                    child: Text(
                                        '${dInfo['health']['Weight']}',
                                        style: TextStyle(
                                          color: mainBlack,
                                          fontFamily: 'Readex Pro',
                                          fontSize: 21,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ))
                                ),
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
                        dInfo['isTracking']
                            ?Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('이 날의 루틴'),
                                Text('3/6')
                              ],
                            ),
                            Container(
                              child: Column(
                                children : List.generate(4,
                                        (idx) => Row(
                                      children: [
                                        Text("체크박스"),
                                        Text("9시"),
                                        Text("루틴명")
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        )
                            :SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('이 날의 기록'),
                          ],
                        ),
                        Container(
                          constraints: BoxConstraints(
                            minHeight: 100, // 최소 높이
                          ),
                          decoration: BoxDecoration(
                            color: ColorMainBack,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFFE6E6E6),
                              width: 1,
                            ),
                          ),
                          child: dInfo['save'].length == 0
                              ?Center(child :Text("기록한 식단이 없습니다."))
                              :Row(
                            children : List.generate(dInfo['save'].length,
                                    (idx) => Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                      ),
                                      child: Image.network(
                                        '${dInfo['save'][idx]['picture']}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text('${dInfo['save'][idx]['date']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ],
                                )),
                          ),
                        )
                      ],
                    ),
                  ) : const SizedBox()
                ],
              ),
            ),
          );
        }
    );
  }
}
