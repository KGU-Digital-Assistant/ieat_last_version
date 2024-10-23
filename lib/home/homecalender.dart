
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:table_calendar/table_calendar.dart';
import '../calender/application/calendar_bloc.dart';
import '../calender/application/calendar_event.dart';
import '../calender/application/calendar_state.dart';
import '../provider.dart';
import 'homecalenderaction.dart';



class HomeboardCalender_Sf extends StatefulWidget {
  const HomeboardCalender_Sf({super.key});

  @override
  State<HomeboardCalender_Sf> createState() => _HomeboardCalender_SfState();
}

class _HomeboardCalender_SfState extends State<HomeboardCalender_Sf> {

  DateTime focusedDay = DateTime.now();
  DateTime firstDay = DateTime(2020);
  DateTime lastDay = DateTime(2025);

  final List<DateTime> highlightedDays = [
    DateTime(2024, 9, 13),
    DateTime(2024, 9, 20),
    DateTime(2024, 9, 21),
    DateTime(2024, 9, 23),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calenderMonthly_Get(context,today);
    });
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
                title: Text("캘린더", style: TextAppbar,),
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
                    bottomShow(context);
                    popWithSlideAnimation(context, 2);
                  },
                )),
            body: SingleChildScrollView(
              child: BlocProvider<CalendarBloc>(
                  create: (_) => CalendarBloc(),
                  child: BlocBuilder<CalendarBloc, CalendarState>(
                      builder: (context, state) {
                    return Column(
                      children: [
                        SizedBox(height: 10,),
                        _buildCustomHeader(),
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
                        Wrap(
                          children: [
                            ...List.generate(
                              7,
                                  (index) => SizedBox(
                                height:MediaQuery.of(context).size.width / 7.0001,
                                width: MediaQuery.of(context).size.width / 7.0001,
                                child: Center(
                                  child: Text(
                                    ["일", "월", "화", "수", "목", "금", "토"][index],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey.withOpacity(0.7)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),  //일월화수목금토
                        TableCalendar(
                            firstDay: firstDay,
                            lastDay: lastDay,
                            headerVisible: false,
                            daysOfWeekVisible: false,
                            focusedDay: focusedDay,
                            onDaySelected: (selectedDay,focusedDay){
                              String formateSelectedDay = DateFormat('yyyy-MM-dd').format(selectedDay);
                              calenderDaily_Get(context,formateSelectedDay);
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                // 특정 날짜에만 백그라운드 컬러 적용
                                if (highlightedDays.any((d) =>
                                d.year == day.year && d.month == day.month && d.day == day.day)) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.5), // 원하는 백그라운드 컬러
                                      shape: BoxShape.circle, // 원형으로 표시
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            )),
                        SizedBox(height: 20),  // 날짜와 데이터 사이 간격
                        //selectedDayType : 날짜 클릭 여부
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                              color: Color(0xffE0E0E0),
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.width * 1, // 최소 높이
                            ),
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(dailyDateFormat(pv.dailyInfo['selectedDay']),style: Text20BoldBlack,),
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
                                SizedBox(height: 10),
                                RichText(text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text : "${dInfo['health']['totalCalorie']}",
                                          style: Text35Bold),
                                      TextSpan(text : "kcal",
                                      style: Text14BlackBold)
                                    ]
                                )),
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorMainBack,
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
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorMainBack,
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
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorMainBack,
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
                                SizedBox(height: 25),
                                dInfo['isTracking']
                                    ?Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('이 날의 루틴', style: Text20BoldBlack,),
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
                                    Text('이 날의 기록', style: Text20BoldBlack,),
                                  ],
                                ),
                                SizedBox(height: 10),
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
                          ),
                        )
                      ],
                    );
                  }
                )
              ),
            ),
          );
        }
    );

  }


  Widget _buildCustomHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () async{
            setState(() {
              focusedDay = DateTime(focusedDay.year, focusedDay.month - 1);
            });
            await calenderMonthly_Get(context, DateFormat('yyyy-MM-dd').format(focusedDay));
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(
              Colors.transparent
            )
          ),
        ),
        Text(
          '${focusedDay.year}년 ${focusedDay.month}월', // 현재 포커스된 달 표시
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () async{
            setState(() {
              focusedDay = DateTime(focusedDay.year, focusedDay.month + 1);
            });
            await calenderMonthly_Get(context, DateFormat('yyyy-MM-dd').format(focusedDay));
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(
              Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}




