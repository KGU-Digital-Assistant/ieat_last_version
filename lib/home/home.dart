import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // jsonDecode 사용을 위해 필요
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/moose.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/setting.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeago/timeago.dart';
import '../constants.dart';
import 'homecalender.dart';
import 'homecalenderapi.dart';
import 'homemeal.dart';

class MealMain_Sf extends StatefulWidget {
  const MealMain_Sf({super.key});

  @override
  State<MealMain_Sf> createState() => _MealMain_SfState();
}

class _MealMain_SfState extends State<MealMain_Sf>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _typeController;
  late Animation<double> _typeLeftPageAnimation;
  late Animation<double> _typeRightPageAnimation;
  bool _isMoved = false;
  bool isLoading = true;
  String selectDay = today;
  int tid = -1;
  int week = 1;
  String weekday = "";

  @override
  void initState() {
    super.initState();
    // initState에서 trackNmDDay_GET 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trackNmDDay_GET(context, today); // 원하는 날짜 값 넣기
    });
    //토글 버튼
    _typeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _typeRightPageAnimation = Tween<double>(begin: 1000, end: 0).animate(
      CurvedAnimation(parent: _typeController, curve: Curves.easeInOut),
    );
    _typeLeftPageAnimation = Tween<double>(begin: 0, end: -1000).animate(
      CurvedAnimation(parent: _typeController, curve: Curves.easeInOut),
    );
  }


  void _moveWidget() {
    setState(() {
      if (_isMoved) {
        _typeController.reverse(); // 원래 위치로 돌아가기
      } else {
        _typeController.forward(); // 오른쪽으로 이동
      }
      _isMoved = !_isMoved;
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }
//오늘의 칼로리, 목표 칼로리, 소모 칼로리, 몸무게

  @override
  Widget build(BuildContext context) {
    // print("build");
    //trackNmDDay_GET(context,selectDay);
    // if (isLoading) {
    //   //로딩화면
    //   return MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     title: 'loading',
    //     theme: ThemeData(
    //       // 테마 설정
    //     ),
    //     home: Scaffold(
    //       body: Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     ),
    //   );
    // }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: ColorMainBack,
          appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    NvgToNxtPage(context, const Setting_Sf());
                    bottomHide(context);
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
          body: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextButton(
                        onPressed: _moveWidget,
                        child: Text(
                          '기록',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all<Color>(
                            Colors.transparent,
                          )
                      ),),
                    TextButton(
                        onPressed: (){
                          _moveWidget();
                          calenderMonthly_Get(context,tid,today);
                        },
                        child: Text(
                          '보드',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        )
                    ),),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Container(
                    width: double.maxFinite,
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _typeLeftPageAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_typeLeftPageAnimation.value, 0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                height:
                                MediaQuery.sizeOf(context).height * 0.82,
                                child: const HomeSave_Sf(),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _typeRightPageAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_typeRightPageAnimation.value, 0),
                              child: Container(
                                width: double.maxFinite,
                                height:
                                MediaQuery.sizeOf(context).height * 0.82,
                                // constraints: BoxConstraints(
                                //   minHeight: MediaQuery.of(context).size.width * 0.9, // 최소 높이
                                // ),
                                color: Colors.purple,
                                child: Homeboard_Sf(),
                              ),
                            );
                          },
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ));

    // return GestureDetector(
    //     onTap: () => FocusScope.of(context).unfocus(),
    //     child: Scaffold(
    //       key: scaffoldKey,
    //       backgroundColor: ColorMainBack,
    //       appBar: AppBar(
    //           scrolledUnderElevation: 0,
    //           automaticallyImplyLeading: false,
    //           backgroundColor: Colors.white,
    //           actions: [
    //             IconButton(
    //               icon: Icon(
    //                 Icons.notifications_none,
    //                 color: Colors.black,
    //                 size: 30,
    //               ),
    //               onPressed: () {
    //                 print('IconButton pressed ...');
    //               },
    //             ),
    //             IconButton(
    //               icon: Icon(
    //                 Icons.settings,
    //                 color: Colors.black,
    //                 size: 30,
    //               ),
    //               onPressed: () {
    //                 NvgToNxtPage(context, const Setting_Sf());
    //                 bottomHide(context);
    //               },
    //             ),
    //             SizedBox(
    //               width: 5,
    //             )
    //           ],
    //           title: Consumer<HomeSave>(builder: (context, pv, child) {
    //             Map<String, dynamic> trackNmDDay = pv.trackNmDDay;
    //             return pv.isTracking
    //                 ? Row(
    //               mainAxisSize: MainAxisSize.max,
    //               children: [
    //                 Padding(
    //                   padding: EdgeInsetsDirectional.fromSTEB(0, 0, 7, 0),
    //                   child: Text('${trackNmDDay['name']}',
    //                       style: TextStyle(
    //                           color: Color(0xFF009E54),
    //                           fontSize: 22,
    //                           letterSpacing: 0.0,
    //                           fontWeight: FontWeight.w900)),
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
    //                   child: Text(
    //                     '+${trackNmDDay['dday']}',
    //                     style: TextStyle(
    //                       fontSize: 15,
    //                       letterSpacing: 0.0,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             )
    //                 : Container(
    //                 padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
    //                 child: SizedBox(
    //                   width: 100,
    //                   child: Image.asset(
    //                     'assets/i-eat_Text_Logo.png',
    //                     fit: BoxFit.cover,
    //                   ),
    //                 ));
    //           })),
    //       body: Column(
    //         children: [
    //           Padding(
    //             padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
    //             child: Row(
    //               mainAxisSize: MainAxisSize.max,
    //               children: [
    //                 TextButton(
    //                   onPressed: _moveWidget,
    //                   child: Text(
    //                     '기록',
    //                     style: TextStyle(
    //                       fontSize: 11,
    //                       letterSpacing: 0.0,
    //                       color: Colors.black,
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                   style: ButtonStyle(
    //                       overlayColor: MaterialStateProperty.all<Color>(
    //                         Colors.transparent,
    //                       )
    //                   ),),
    //                 TextButton(
    //                   onPressed: (){
    //                     _moveWidget();
    //                     calenderMonthly_Get(context,tid,today);
    //                   },
    //                   child: Text(
    //                     '보드',
    //                     style: TextStyle(
    //                       fontSize: 11,
    //                       letterSpacing: 0.0,
    //                       color: Colors.black,
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                   style: ButtonStyle(
    //                       overlayColor: MaterialStateProperty.all<Color>(
    //                         Colors.transparent,
    //                       )
    //                   ),),
    //               ],
    //             ),
    //           ),
    //           SingleChildScrollView(
    //             child: Container(
    //                 width: double.maxFinite,
    //                 constraints: BoxConstraints(
    //                   minHeight: MediaQuery.of(context).size.width * 0.9, // 최소 높이
    //                 ),
    //                 child: Stack(
    //                   children: [
    //                     AnimatedBuilder(
    //                       animation: _typeLeftPageAnimation,
    //                       builder: (context, child) {
    //                         return Transform.translate(
    //                           offset: Offset(_typeLeftPageAnimation.value, 0),
    //                           child: Container(
    //                             width: MediaQuery.sizeOf(context).width,
    //                             height:
    //                             MediaQuery.sizeOf(context).height * 0.82,
    //                             child: const HomeSave_Sf(),
    //                           ),
    //                         );
    //                       },
    //                     ),
    //                     AnimatedBuilder(
    //                       animation: _typeRightPageAnimation,
    //                       builder: (context, child) {
    //                         return Transform.translate(
    //                           offset: Offset(_typeRightPageAnimation.value, 0),
    //                           child: Container(
    //                             width: double.maxFinite,
    //                             // height: 600,
    //                             constraints: BoxConstraints(
    //                               minHeight: MediaQuery.of(context).size.width * 0.9, // 최소 높이
    //                             ),
    //                             color: Colors.purple,
    //                             child: Homeboard_Sf(),
    //                           ),
    //                         );
    //                       },
    //                     ),
    //                   ],
    //                 )),
    //           ),
    //         ],
    //       ),
    //     ));
  }
}

class HomeSave_Sf extends StatefulWidget {
  const HomeSave_Sf({super.key});

  @override
  State<HomeSave_Sf> createState() => _HomeSave_Sf_SfState();
}

class _HomeSave_Sf_SfState extends State<HomeSave_Sf>
    with SingleTickerProviderStateMixin {
  Color containerBolderColor = Color(0xFFE6E6E6);
  List _week = [1, 2, 3, 4, 5, 6, 7];
  late AnimationController _modeController;
  late Animation<double> _modeAnimation;
  late Animation<double> _modeLeftPageAnimation;
  late Animation<double> _modeRightPageAnimation;
  bool _isMoved = false;
  List<int> _isClickedWeek = [0, 0, 0, 0, 0, 0, 0];
  int todyWeekDay = getTodayWeekday();

  @override
  void initState() {
    super.initState();
    //토글 버튼
    setState(() {
      _isClickedWeek[todyWeekDay] = 1;
    });
    _modeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _modeAnimation = Tween<double>(begin: 0, end: 60).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _modeRightPageAnimation = Tween<double>(begin: 1000, end: 0).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _modeLeftPageAnimation = Tween<double>(begin: 0, end: -1000).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
  }

  Future<void> initAsyncFunctions_nonetrack() async {}

  @override
  void dispose() {
    _modeController.dispose();
    super.dispose();
  }

  //func list
  void _moveWidget() {
    setState(() {
      if (_isMoved) {
        _modeController.reverse(); // 원래 위치로 돌아가기
      } else {
        _modeController.forward(); // 오른쪽으로 이동
      }
      _isMoved = !_isMoved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        height: MediaQuery.sizeOf(context).height * 1,
        child: Column(
          children: [
            Container(
                width: MediaQuery.sizeOf(context).width,
                height: 75,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBFFEE),
                ),
                child: Consumer<HomeSave>(
                  builder: (context, pv, child) {
                    return pv.isTracking
                        ? SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _week.length,
                                itemBuilder: (c, idx) {
                                  int dayCnt = (idx + 1);
                                  String dayCntString =
                                      dayCnt.toString(); //1일 차
                                  String day = "";
                                  switch (idx) {
                                    case 0:
                                      day = "월";
                                    case 1:
                                      day = "화";
                                    case 2:
                                      day = "수";
                                    case 3:
                                      day = "목";
                                    case 4:
                                      day = "금";
                                    case 5:
                                      day = "토";
                                    case 6:
                                      day = "일";
                                  }

                                  return SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          7, // 화면 크기에 맞춰 균등 분할
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                        child: Container(
                                          width: 45.0,
                                          height: 70.0,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffEFEFEF),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  border: Border.all(
                                                    color:
                                                        _isClickedWeek[idx] == 1
                                                            ? mainGreen
                                                            : Color(0xFFE6E6E6),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: TextButton(
                                                    child: Text(
                                                      day,
                                                      style: TextStyle(
                                                          color: const Color(
                                                                  0xff1E1E1E)
                                                              .withOpacity(0.3),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isClickedWeek[idx] = 1;
                                                        for (int i = 0;
                                                            i <
                                                                _isClickedWeek
                                                                    .length;
                                                            i++) {
                                                          if (idx != i)
                                                            _isClickedWeek[i] =
                                                                0;
                                                        }
                                                        containerBolderColor =
                                                            Color(0xFFE6E6E6);
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                      // 클릭 및 hover 효과 제거
                                                      overlayColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .transparent),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text('$dayCntString일 차',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontFamily: 'Noto Sans KR',
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ));
                                }),
                          )
                        : SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _week.length,
                                itemBuilder: (c, idx) {
                                  int dayCnt = (idx + 1);
                                  String dayCntString = dayCnt.toString();
                                  String day = "";
                                  switch (idx) {
                                    case 0:
                                      day = "월";
                                    case 1:
                                      day = "화";
                                    case 2:
                                      day = "수";
                                    case 3:
                                      day = "목";
                                    case 4:
                                      day = "금";
                                    case 5:
                                      day = "토";
                                    case 6:
                                      day = "일";
                                  }

                                  return SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          7, // 화면 크기에 맞춰 균등 분할
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                        child: Container(
                                          width: 45.0,
                                          height: 70.0,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color:
                                                  const Color(0xffEFEFEF),
                                                  borderRadius:
                                                  BorderRadius.circular(50),
                                                  border: Border.all(
                                                    color:
                                                    _isClickedWeek[idx] == 1
                                                        ? mainGreen
                                                        : Color(0xFFE6E6E6),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    day,
                                                    style: TextStyle(
                                                        color: const Color(
                                                                0xff1E1E1E)
                                                            .withOpacity(0.3),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                }),
                          );
                  },
                )),
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                  width: double.maxFinite,
                  // color: Colors.brown,
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _modeLeftPageAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_modeLeftPageAnimation.value, 0),
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  width: double.maxFinite,
                                  height: getHeightRatioFromScreenSize(
                                      context, 0.8),
                                  child: const homeSave_TODAYANALYZE_Sf(),
                                )),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _modeRightPageAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_modeRightPageAnimation.value, 0),
                            child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Container(
                                  width: double.maxFinite,
                                  height: getHeightRatioFromScreenSize(
                                      context, 0.8),
                                  child: const homeSave_TODAYROUTINE_Sf(),
                                )),
                          );
                        },
                      ),
                    ],
                  )),
            )),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              Container(
                height: 33,
                width: 120,
                decoration: BoxDecoration(
                  color: Color(0xff787880).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              AnimatedBuilder(
                animation: _modeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_modeAnimation.value, 0),
                    child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Container(
                          height: 27,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0FFCF),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        )),
                  );
                },
              ),
              Container(
                height: 33,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: _moveWidget,
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                            Colors.transparent), // Hover 효과 없애기
                      ),
                      child: const Text(
                        "메인",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.black),
                      ),
                    ),
                    TextButton(
                        onPressed: _moveWidget,
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                              Colors.transparent), // Hover 효과 없애기
                        ),
                        child: const Text(
                          "루틴",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}

class Homeboard_Sf extends StatefulWidget {
  const Homeboard_Sf({super.key});

  @override
  State<Homeboard_Sf> createState() => _Homeboard_Sf_SfState();
}

class _Homeboard_Sf_SfState extends State<Homeboard_Sf>
    with SingleTickerProviderStateMixin {
  List<Widget> _typepages = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        Provider.of<HomeboardTabModel>(context, listen: false)
            .setIndex(_tabController.index);
      }
    });
    _typepages = [const HomeboardCalender_Sf(), const Placeholder()];
  }

  final List<GlobalKey<NavigatorState>> _typeNavigatorKeyList =
      List.generate(2, (index) => GlobalKey<NavigatorState>());
  int _currentIndex = 0;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !(await _typeNavigatorKeyList[_currentIndex]
            .currentState!
            .maybePop());
      },
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Consumer<HomeboardTabModel>(
              builder: (context, tabModel, child) {
                return TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  automaticIndicatorColorAdjustment: true,
                  labelColor: Colors.black,
                  onTap: (index) {
                    tabModel.setIndex(index);
                    _tabController.animateTo(index);
                  },
                  indicatorColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      text: '달력',
                    ),
                    Tab(
                      text: '트랙',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: Container(
          // color: CupertinoColors.systemGreen,
          child: TabBarView(
            controller: _tabController,
            children: _typepages,
          ),
        ),
      ),
    );
  }
}

class homeSave_TODAYANALYZE_Sf extends StatefulWidget {
  const homeSave_TODAYANALYZE_Sf({super.key});

  @override
  State<homeSave_TODAYANALYZE_Sf> createState() =>
      _homeSave_TODAYANALYZE_SfState();
}

class _homeSave_TODAYANALYZE_SfState extends State<homeSave_TODAYANALYZE_Sf>
    with TickerProviderStateMixin {
  late PieModel carBoChartData;
  late PieModel proChartData;
  late PieModel fatChartData;
  late AnimationController animationController;
  final TextEditingController _burncalorieController = TextEditingController();
  String nnm = "";
  Map<String, dynamic> todaymealInfo = {
    "todaycalorie": 0,
    "goalcalorie": 0,
    "nowcalorie": 0,
    "burncalorie": 0,
    "weight": 0
  };
  Map<String, int> goalNowNutrientInfo = {
    "carb": 0,
    "protein": 0,
    "fat": 0,
    "gb_carb": 300,
    "gb_protein": 60,
    "gb_fat": 65
  };

  @override
  void initState() {
    super.initState();

    initAsyncFunctions();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.forward();
    // 계산 후 double을 int로 변환
    int carbCount = ((goalNowNutrientInfo['carb'] ?? 0).toDouble() /
            (goalNowNutrientInfo['gb_carb'] ?? 0).toDouble() *
            100)
        .toInt(); // 예시로 100을 곱함
    int probCount = ((goalNowNutrientInfo['protein'] ?? 0).toDouble() /
            (goalNowNutrientInfo['gb_protein'] ?? 0).toDouble() *
            100)
        .toInt(); // 예시로 100을 곱함
    int fatbCount = ((goalNowNutrientInfo['fat'] ?? 0).toDouble() /
            (goalNowNutrientInfo['gb_fat'] ?? 0).toDouble() *
            100)
        .toInt(); // 예시로 100을 곱함

    setState(() {
      carBoChartData = PieModel(
          count: carbCount, // double을 int로 변환
          color: const Color(0xFF21C87D),
          thickness: 7);
      proChartData = PieModel(
          count: probCount, // double을 int로 변환
          color: const Color(0xFF21C87D),
          thickness: 7);
      fatChartData = PieModel(
          count: fatbCount, // double을 int로 변환
          color: const Color(0xFF21C87D),
          thickness: 7);
    });
  }

  Future<void> initAsyncFunctions() async {
    String? nickname = await getNickNm();
    setState(() {
      nnm = nickname;
    });
    // await mealDayCalorieToday_GET();
    // await mealTodayListup_GET();
    // await goalNowNutrient_GET();
    await todayWCA_GET();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  //api list

  Future<void> updateBurncalorie_PATCH(BuildContext context) async {
    String funNm = "updateBurncalorie_PATCH";
    String? tk = await getTk();
    print('$funNm - 요청시작');

    final pv = Provider.of<HomeSave>(context, listen: false);
    int burncalorie = _selectedBurnCalorieValue;
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
        bottomSheetType500(context, fail500_1(context));
        // simpleAlert(context, "트랙 시작 후 등록할 수 있습니다.");
      }
    } catch (e) {
      print('$funNm Error : $e');
    }
  }

  Future<void> updateWeght_PATCH(BuildContext context) async {
    String funNm = "updateWeght_PATCH";
    String? tk = await getTk();
    print('$funNm - 요청시작');

    final pv = Provider.of<HomeSave>(context, listen: false);
    int weight = _selectedWeghtValue;
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
        bottomSheetType500(context, fail500_1(context));
        // simpleAlert(context, "트랙 시작 후 등록할 수 있습니다.");
      }
    } catch (e) {
      print('$funNm Error : $e');
    }
  }

  int _selectedWaterValue = 1000;
  final List<int> _Watervalues =
      List.generate(300, (index) => index * 10); // 0부터 3000까지 10 단위로 값 생성
  int _selectedBurnCalorieValue = 0;
  final List<int> _BurnCalorievalues =
      List.generate(300, (index) => index * 10); // 0부터 3000까지 10 단위로 값 생성
  int _selectedCoffeeValue = 0;
  int _selectedWeghtValue = 50;
  final List<int> _Weghtvalues =
      List.generate(300, (index) => index * 1); // 0부터 3000까지 10 단위로 값 생성

  void subCoffeeCnt() {
    setState(() {
      _selectedCoffeeValue--;
    });
  }

  void addCoffeeCnt() {
    setState(() {
      _selectedCoffeeValue++;
    });
  }

  Widget todayWater(BuildContext context) => Container(
      color: ColorMainBack,
      width: double.infinity,
      height: 500,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text("오늘 섭취한 수분", style: Text25BoldBlack),
          Text("하루 물 권장량은 1,500mL예요.", style: Text14Black),
          SizedBox(
            height: 70,
          ),
          Container(
            color: ColorMainBack,
            height: 150,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem: _Watervalues.indexOf(_selectedWaterValue)),
              itemExtent: 80.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedWaterValue = _Watervalues[index];
                });
              },
              children:
                  _Watervalues.map((value) => Center(child: Text('$value')))
                      .toList(),
            ),
          ),
          SizedBox(
            height: 70,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                updateTodayLq_PATCH(context, "water", _selectedWaterValue);
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
          )
        ],
      ));

  Widget todayCoffee(BuildContext context) => Container(
      width: double.infinity,
      height: 500,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text("오늘 섭취한 커피", style: Text25BoldBlack),
          Text("과도한 카페인은 만성피로를 유발할 수 있어요.", style: Text14Black),
          SizedBox(
            height: 70,
          ),
          Container(
              color: ColorMainBack,
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.fromLTRB(10, 5, 10, 5),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(60, 60),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color1BAF79,
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: Color1BAF79, // 원하는 테두리 색상
                              width: 1.0, // 테두리 두께
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                            Colors.transparent),
                      ),
                      onPressed: () {
                        subCoffeeCnt();
                        print(_selectedCoffeeValue);
                      },
                      child: Icon(Icons.remove, size: 30, color: Colors.white)),
                  Text("$_selectedCoffeeValue", style: Text35Bold),
                  ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.fromLTRB(10, 5, 10, 5),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(60, 60),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color1BAF79,
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: Color1BAF79, // 원하는 테두리 색상
                              width: 1.0, // 테두리 두께
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                            Colors.transparent),
                      ),
                      onPressed: () {
                        addCoffeeCnt();
                        print(_selectedCoffeeValue);
                      },
                      child: Icon(Icons.add, size: 30, color: Colors.white))
                ],
              )),
          SizedBox(
            height: 70,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                updateTodayLq_PATCH(context, "coffee", _selectedCoffeeValue);
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
          )
        ],
      ));




  Future<void> todayWCA_GET() async {
    String? tk = await getTk();
    String funNm = 'todayWCA_GET';
    //회원 검색함수 - 돋보기 클릭 시 작동
    print("tk : $tk");
    print('$funNm - 요청시작');
    String uri = '$url/meal_day/get/wca/mine/$today';
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
      if (response.statusCode == 200) {
        final res = response.data;
        if (res.length == 0) {}
        print(res);
        setState(() {
          // _isloading = false;   {water: 0, coffee: 0, alcohol: 0}
          var data = Map<String, int>.from(res);
          final pv = Provider.of<DaySubInfo>(context, listen: false);
          pv.updateWater(data['water']!);
          pv.updateCoffee(data['coffee']!);
        });
      } else if (response.statusCode == 404) {
        //트랙 없는 상태
      } else {
        print(' $funNm Error(statusCode): ${response.statusCode}');
      }
    } catch (e) {
// 오류 처리
      print('$funNm Error: $e');
    }
  }

  //치팅쿠폰
  Future<void> todaycheatingCnt_GET(BuildContext context) async {
    final pv = Provider.of<DaySubInfo>(context, listen: false);

    String? tk = await getTk();
    String funcname = 'todaycheatingCnt_GET';
    final response = await http
        .get(Uri.parse('$url/meal_day/get/cheating_count/$today'), headers: {
      'Authorization': 'Bearer $tk',
      'Content-Type': 'application/json',
    });
    print('$funcname - ${response.statusCode}');
    if (response.statusCode == 200) {
      var utf8Res = utf8.decode(response.bodyBytes);
      pv.initCheating(jsonDecode(utf8Res)['cheating_count']);
      bottomHide(context);
      bottomSheetType500(context, cheatingDialog_1(context));
    } else {
      bottomHide(context);
      bottomSheetType500(context, fail500_1(context));
      throw Exception('[todaycheatingCnt_GET] Failed to load data');
    }
  } //todaycheatingCnt_GET : 오늘 치팅 갯수 조회

  Widget cheatingDialog_1(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            SizedBox(
              width: 170,
              child: Image.asset(
                'assets/icons/track/Speak-no-evil monkey.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "오늘을 치팅데이로 할까요?",
              style: Text25BoldBlack,
            ),
            SizedBox(height: 10),
            Consumer<DaySubInfo>(builder: (context, DaySubInfo, child) {
              return Text(
                  "(잔여 치팅 쿠폰 : ${DaySubInfo.daySubInfoList['cheating'][0]})",
                  style: Text14Black);
            }),
            SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 340,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    updateCheating_PATCH(context);
                    bottomShow(context);
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.fromLTRB(10, 5, 10, 5),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(40, 40),
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
                          "쿠폰 사용하기",
                          style: Text22BoldBlack,
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ); //치팅 쿠폰 사용할 것인지 ask
  Future<void> updateCheating_PATCH(BuildContext context) async {
    String funNm = "updateCheating_PATCH";
    String? tk = await getTk();
    print('$funNm - 요청시작');

    final pv = Provider.of<DaySubInfo>(context, listen: false);
    String uri = '$url/meal_day/update/cheating/2024-09-18';
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
        pv.updateCheating(today);
        bottomSheetType500(context, cheatingDialog_2_saveSuc(context));
      } else {
        bottomSheetType500(context, fail500_1(context));
        // simpleAlert(context, "트랙 시작 후 등록할 수 있습니다.");
      }
    } catch (e) {
      print('$funNm Error : $e');
    }
  } //updateCheating_PATCH : 치팅 쿠폰 사용

  Widget cheatingDialog_2_saveSuc(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            SizedBox(
              width: 170,
              child: Image.asset(
                'assets/icons/track/Speak-no-evil monkey.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            Text("치팅 쿠폰을 사용하였습니다.", style: Text25BoldBlack),
            SizedBox(height: 10),
            Text("맛있는 하루 되세요!", style: Text14Black),
            SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 340,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    updateCheating_PATCH(context);
                    bottomShow(context);
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.fromLTRB(10, 5, 10, 5),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(40, 40),
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
                          "닫기",
                          style: Text22BoldBlack,
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ); //사용 완료 알림창

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 70,
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 70,
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Text('$today',
                              style: TextStyle(
                                fontFamily: 'Noto Sans KR',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ))),
                    ),
                    Container(
                      height: 70,
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text('1주 차',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Noto Sans KR',
                                fontSize: 13,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ))),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                        width: 65,
                        child: ElevatedButton(
                            onPressed: () {
                              bottomHide(context);
                              bottomSheetType500(context, todayWater(context));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorMainBack, // 백그라운드 색상
                              elevation: 0, // 그림자 높이 (0으로 설정하면 그림자 제거 가능)
                              shape: RoundedRectangleBorder(
                                // 버튼 모양
                                borderRadius:
                                    BorderRadius.circular(8), // 모서리 둥글게
                              ),
                              padding: EdgeInsets.zero, // 패딩 조정
                            ),
                            child: Consumer<DaySubInfo>(
                                builder: (context, DaySubInfo, child) {
                              int water =
                                  DaySubInfo.daySubInfoList["water"] ?? 0;
                              return Text("$water mL",
                                  style: TextStyle(
                                    fontFamily: 'Noto Sans KR',
                                    color: Colors.black,
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                  ));
                            }))),
                    const SizedBox(width: 5),
                    SizedBox(
                        width: 45,
                        child: ElevatedButton(
                            onPressed: () {
                              final pv = Provider.of<DaySubInfo>(context,
                                  listen: false);
                              setState(() {
                                _selectedCoffeeValue =
                                    pv.daySubInfoList['coffee'];
                              });
                              bottomHide(context);
                              bottomSheetType500(context, todayCoffee(context));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorMainBack, // 백그라운드 색상
                              elevation: 0, // 그림자 높이 (0으로 설정하면 그림자 제거 가능)
                              shape: RoundedRectangleBorder(
                                // 버튼 모양
                                borderRadius:
                                    BorderRadius.circular(8), // 모서리 둥글게
                              ),
                              padding: EdgeInsets.zero, // 패딩 조정
                            ),
                            child: Consumer<DaySubInfo>(
                                builder: (context, DaySubInfo, child) {
                              int coffee =
                                  DaySubInfo.daySubInfoList["coffee"] ?? 0;
                              return Text("$coffee샷",
                                  style: TextStyle(
                                    fontFamily: 'Noto Sans KR',
                                    color: Colors.black,
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                  ));
                            }))),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          todaycheatingCnt_GET(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorMainBack, // 백그라운드 색상
                          elevation: 0, // 그림자 높이 (0으로 설정하면 그림자 제거 가능)
                          shape: RoundedRectangleBorder(
                            // 버튼 모양
                            borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                          ),
                          padding: EdgeInsets.zero, // 패딩 조정
                        ),
                        child: SizedBox(
                          width: 30,
                          child: Image.asset(
                            'assets/icons/cheating_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )),
        SizedBox(
          width: double.maxFinite,
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                SizedBox(
                  height: 130,
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        // "${formatNumberWithComma(todaymealInfo['todaycalorie'])}",
                        "2,980",
                        style: GoogleFonts.racingSansOne(
                          fontSize: 89, // 폰트 크기 조절
                          color: Colors.black, // 폰트 색상
                          fontWeight: FontWeight.bold, // 굵기 조절
                        ),
                      )),
                ),
                SizedBox(
                  height: 130,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "목표 칼로리 : ${formatNumberWithComma(todaymealInfo['goalcalorie'])}kcal",
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff7F7F7F)),
                      )),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        // SizedBox(
        //   // color: Colors.brown,
        //   width: double.maxFinite,
        //   height: 100,
        //   child: Container(
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: [
        //         Stack(
        //           children: [
        //             AnimatedBuilder(
        //               animation: animationController,
        //               builder: (context, child) {
        //                 if (animationController.value < 0.1) {
        //                   return const SizedBox();
        //                 }
        //                 return SizedBox(
        //                   width: MediaQuery.sizeOf(context).width * 0.3,
        //                   height: 100,
        //                   child: Center(
        //                       child: CustomPaint(
        //                     size: const Size(95, 95),
        //                     painter: _RadialChart(
        //                         carBoChartData, animationController.value),
        //                   )),
        //                 );
        //               },
        //             ),
        //             SizedBox(
        //                 width: MediaQuery.sizeOf(context).width * 0.3,
        //                 height: 100,
        //                 child:  Padding(
        //                     padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
        //                     child: Align(
        //                       alignment: Alignment.topCenter,
        //                       child: Text(
        //                         // "${formatNumberWithComma(todaymealInfo['todaycalorie'])}",
        //                         "탄",
        //                         style: TextHomeNuTitle,
        //                       ),
        //                     ))),
        //             SizedBox(
        //                 width: MediaQuery.sizeOf(context).width * 0.3,
        //                 height: 100,
        //                 child: Padding(
        //                   padding: EdgeInsets.fromLTRB(0, 53, 0, 0),
        //                   child: Align(
        //                     alignment: Alignment.topCenter,
        //                     child: Text(
        //                         "${formatNumberWithComma(goalNowNutrientInfo['carb']!)}",
        //                         style: TextStyle(
        //                             fontSize: 13,
        //                             color: Colors.grey,
        //                             fontWeight: FontWeight.bold)),
        //                   ),
        //                 ))
        //           ],
        //         ),
        //         Stack(
        //           children: [
        //             AnimatedBuilder(
        //               animation: animationController,
        //               builder: (context, child) {
        //                 if (animationController.value < 0.1) {
        //                   return const SizedBox();
        //                 }
        //                 return SizedBox(
        //                   width: MediaQuery.sizeOf(context).width * 0.3,
        //                   height: double.maxFinite,
        //                   child: Center(
        //                       child: CustomPaint(
        //                     size: const Size(95, 95),
        //                     painter: _RadialChart(
        //                         proChartData, animationController.value),
        //                   )),
        //                 );
        //               },
        //             ),
        //             SizedBox(
        //                 width: MediaQuery.sizeOf(context).width * 0.3,
        //                 height: 100,
        //                 child:  Padding(
        //                     padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
        //                     child: Align(
        //                       alignment: Alignment.topCenter,
        //                       child: Text(
        //                          "단",
        //                         style: TextHomeNuTitle,
        //                       ),
        //                     ))),
        //             SizedBox(
        //                 width: MediaQuery.sizeOf(context).width * 0.3,
        //                 height: 100,
        //                 child: Padding(
        //                   padding: EdgeInsets.fromLTRB(0, 53, 0, 0),
        //                   child: Align(
        //                     alignment: Alignment.topCenter,
        //                     child: Text(
        //                         "${formatNumberWithComma(goalNowNutrientInfo['protein']!)}",
        //                         style: TextStyle(
        //                             fontSize: 13,
        //                             color: Colors.grey,
        //                             fontWeight: FontWeight.bold)),
        //                   ),
        //                 ))
        //           ],
        //         ),
        //         Stack(
        //           children: [
        //             AnimatedBuilder(
        //               animation: animationController,
        //               builder: (context, child) {
        //                 if (animationController.value < 0.1) {
        //                   return const SizedBox();
        //                 }
        //                 return Container(
        //                   width: MediaQuery.sizeOf(context).width * 0.3,
        //                   height: double.maxFinite,
        //                   child: Center(
        //                       child: CustomPaint(
        //                     size: const Size(95, 95),
        //                     painter: _RadialChart(
        //                         fatChartData, animationController.value),
        //                   )),
        //                 );
        //               },
        //             ),
        //             SizedBox(
        //                 width: MediaQuery.sizeOf(context).width * 0.3,
        //                 height: 100,
        //                 child:  Padding(
        //                     padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
        //                     child: Align(
        //                       alignment: Alignment.topCenter,
        //                       child: Text("지",
        //                           style: TextHomeNuTitle),
        //                     ))),
        //             SizedBox(
        //                 width: MediaQuery.sizeOf(context).width * 0.3,
        //                 height: 100,
        //                 child: Padding(
        //                   padding: EdgeInsets.fromLTRB(0, 53, 0, 0),
        //                   child: Align(
        //                     alignment: Alignment.topCenter,
        //                     child: Text(
        //                         "${formatNumberWithComma(goalNowNutrientInfo['fat']!)}",
        //                         style: TextStyle(
        //                             fontSize: 13,
        //                             color: Colors.grey,
        //                             fontWeight: FontWeight.bold)),
        //                   ),
        //                 ))
        //           ],
        //         )
        //       ],
        //     ),
        //   ),
        // ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('오늘의 기록',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  )),
              Spacer(),
              Text('3/6',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 100,
              decoration: BoxDecoration(
                color: ColorMainBack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorMainBolder,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Container(
                    width: 100,
                    height: 100,
                    child: Row(
                      children: List.generate(
                          2,
                          (idx) => Container(
                                width: 75,
                                height: 100,
                                decoration: BoxDecoration(color: ColorMainBack),
                                child: Column(
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
                                        'https://picsum.photos/seed/889/600',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text('06:04',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w900,
                                        )),
                                  ],
                                ),
                              )),
                    )),
              ),
            ),
            Container(
                width: MediaQuery.sizeOf(context).width,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorMainBolder,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        //NvgToNxtPage(context, MealSaveSf());
                        Map<String, dynamic> testdata = {
                          "file_path": "temp/1_2024-09-17-215711",
                          "food_info": {
                            "name": "Oatmeal",
                            "date": "2024-06-27T07:30:00",
                            "heart": true,
                            "carb": 50,
                            "protein": 10,
                            "fat": 5,
                            "calorie": 300,
                            "unit": "gram",
                            "size": 200,
                            "daymeal_id": 1
                          },
                          "image_url":
                              "https://storage.googleapis.com/ieat-76bd6.appspot.com/temp/1_2024-09-17-215711?Expires=1726581433&GoogleAccessId=firebase-adminsdk-eigep%40ieat-76bd6.iam.gserviceaccount.com&Signature=T2T4mqNv8MJytZTchoj3ne8ubwvhhA6IEgLodnokmq%2FSWmtESHJzaSv%2F9cy2G1VWbQZ45214yRQEiPop9CKGEuxqdcUBerXiA%2BRWV7y%2Fa8ttw8zHk4IUH%2BxoHJY9S%2FScR%2BVYQ0Lke39Vb36CcpvJVcioz71wyuQhJvVofBmSfzpWEqTsSbruaSFOjjkj6rKYUgq6DeLyotsCQsCY2t%2BOYTxeph9HPm1JcDSW7CKcVmNos4TLy3tUV0q9B8Ajx0NF%2F20uu1pX5M8r6580nx%2BJKLK7qYF0UsqZVYwBold2J7T5JwosPuRdR%2BAGYBxV%2FdpcGGDkX3He8bXbHBLKq9sKxg%3D%3D"
                        };
                        bottomHide(context);
                        NvgToNxtPage(context, MealSaveSf());
                        // bottomSheetType90per(context, newMealSave(context, testdata));
                      },
                    ),
                  ),
                ))
          ],
        ),
        SizedBox(height: 20),
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorMainBolder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Text('섭취칼로리',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF464646),
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
                      '${formatNumberWithComma(todaymealInfo['nowcalorie'])}',
                      style: TextStyle(
                        fontFamily: 'Readex Pro',
                        fontSize: 21,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                width: 38,
                child: Align(
                  alignment: AlignmentDirectional(1, 0),
                  child: Text('kcal',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF464646),
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
        ElevatedButton(
          onPressed: () {
            bottomHide(context);
            // bottomSheetType500(context, todayBurnCalorie());
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.fromLTRB(0, 0, 0, 0),
            ),
            minimumSize: MaterialStateProperty.all<Size>(
              Size(MediaQuery.sizeOf(context).width, 40),
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
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            bottomHide(context);
            // bottomSheetType500(context, todayWeight());
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.fromLTRB(0, 0, 0, 0),
            ),
            minimumSize: MaterialStateProperty.all<Size>(
              Size(MediaQuery.sizeOf(context).width, 40),
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
        SizedBox(height: 20),
      ],
    );
  }
}

class homeSave_TODAYROUTINE_Sf extends StatefulWidget {
  const homeSave_TODAYROUTINE_Sf({super.key});

  @override
  State<homeSave_TODAYROUTINE_Sf> createState() =>
      _homeSave_TODAYROUTINE_SfState();
}

class _homeSave_TODAYROUTINE_SfState extends State<homeSave_TODAYROUTINE_Sf> {
  bool isTracking = false;

  @override
  Widget build(BuildContext context) {
    (isTracking) {
      return Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('계획한 오늘의 루틴',
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          color: mainGrey)),
                )),
            Container(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFFCDCFD0),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                        child: Container(
                          width: 100,
                          height: 60,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('아침 - 12시',
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  Text('육회비빔밥',
                                      style: TextStyle(
                                        fontSize: 18,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w900,
                                      )),
                                ],
                              ),
                              Spacer(),
                              // ToggleIcon(
                              //   onPressed: () async {},
                              //   value: true,
                              //   onIcon: Icon(
                              //     Icons.check_box,
                              //     color: FlutterFlowTheme.of(context).primary,
                              //     size: 24,
                              //   ),
                              //   offIcon: Icon(
                              //     Icons.check_box_outline_blank,
                              //     color: FlutterFlowTheme.of(context).secondaryText,
                              //     size: 24,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    };
    return Padding(
        padding: EdgeInsets.all(0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center, // 수직 방향 중앙 정렬
                children: [
                  Text(
                    "트랙을 시작하고",
                    style: TextStyle(
                        color: mainBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "오늘 지켜야할 식단루틴을 확인해보세요!",
                    style: TextStyle(
                        color: mainBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              )),
        ));
  }
}




//1주차 부분
class HomeboardTrackRoutineInfo extends StatefulWidget {
  const HomeboardTrackRoutineInfo({super.key});

  @override
  State<HomeboardTrackRoutineInfo> createState() =>
      _HomeboardTrackRoutineInfoState();
}

class _HomeboardTrackRoutineInfoState extends State<HomeboardTrackRoutineInfo>
    with SingleTickerProviderStateMixin {
  List<Widget> _weekpages = [];
  List<int> weekList = List.filled(9, 0);
  late TabController _HomeboardTrackWeekTabController;

  //HomeboardTrackRoutineInfo_Widget

  @override
  void initState() {
    super.initState();
    _HomeboardTrackWeekTabController =
        TabController(length: homeBoardTrackWeekCnt, vsync: this);
    _HomeboardTrackWeekTabController.addListener(() {
      if (_HomeboardTrackWeekTabController.indexIsChanging) {
        Provider.of<HomeboardTabModel>(context, listen: false)
            .setIndex(_HomeboardTrackWeekTabController.index);
      }
    });
  }

  final List<GlobalKey<NavigatorState>> _typeNavigatorKeyList = List.generate(
      homeBoardTrackWeekCnt, (index) => GlobalKey<NavigatorState>());
  int _currentIndex = 0;

  Widget HomeboardTrackRoutineInfo_Widget(int idx) => Container(
        width: double.infinity,
        height: 600,
        padding: EdgeInsets.all(20),
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
              border: Border.all(
            color: Colors.red, // 테두리 색상
            width: 1.0, // 테두리 두께
          )),
          child: Center(child: Text('Content for Tab $idx')),
        ),
      );

  @override
  void dispose() {
    _HomeboardTrackWeekTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !(await _typeNavigatorKeyList[_currentIndex]
            .currentState!
            .maybePop());
      },
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Consumer<HomeboardTrackWeekTabModel>(
              builder: (context, tabModel, child) {
                return TabBar(
                    controller: _HomeboardTrackWeekTabController,
                    isScrollable: false,
                    automaticIndicatorColorAdjustment: true,
                    labelColor: Colors.black,
                    onTap: (index) {
                      tabModel.setIndex(index);
                      _HomeboardTrackWeekTabController.animateTo(index);
                    },
                    indicatorColor: Colors.green,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 3,
                    tabs: List.generate(
                      homeBoardTrackWeekCnt,
                      (index) => Tab(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width *
                                0.2, // Adjust tab width
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Tab $index',
                              style: TextStyle(fontSize: 14), // 작은 폰트 사이즈
                            ),
                          ),
                        ),
                      ),
                    ));
              },
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          child: TabBarView(
            controller: _HomeboardTrackWeekTabController,
            children: List.generate(
              homeBoardTrackWeekCnt, // 탭의 수에 따라 조정
              (index) => HomeboardTrackRoutineInfo_Widget(index),
            ),
          ),
        ),
      ),
    );
  }
}

//7일, 루틴 리스트
class HomeboardTrackRoutineInfo_Widget extends StatefulWidget {
  const HomeboardTrackRoutineInfo_Widget({super.key});

  @override
  State<HomeboardTrackRoutineInfo_Widget> createState() =>
      _HomeboardTrackRoutineInfo_WidgetState();
}

class _HomeboardTrackRoutineInfo_WidgetState
    extends State<HomeboardTrackRoutineInfo_Widget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              width: double.maxFinite,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFEBFFEE),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                    child: Container(
                      width: 45.0,
                      height: 70.0,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.network(
                              'https://picsum.photos/seed/570/600',
                              width: 42.0,
                              height: 42.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text('7일 차',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Noto Sans KR',
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  )),
                ],
              )),
          Container()
        ],
      ),
    );
  }
}
//물 커피 치팅 init 데이터는 버튼 클릭 시 가져옴

//1번만 가져오고 provider에서 사용
//목표 칼로리

Future<void> trackSetting(BuildContext context) async {
  //물 커피 알코올 init
}

Future<void> todayWCA_GET(BuildContext context) async {
  String? tk = await getTk();
  String funNm = 'todayWCA_GET';
  //회원 검색함수 - 돋보기 클릭 시 작동
  print("tk : $tk");
  print('$funNm - 요청시작');
  String uri = '$url/meal_day/get/wca/mine/$today';
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
    if (response.statusCode == 200) {
      final res = response.data;
      if (res.length == 0) {}
      print(res);
      var data = Map<String, int>.from(res);
      final pv = Provider.of<DaySubInfo>(context, listen: false);
      pv.updateWater(data['water']!);
      pv.updateCoffee(data['coffee']!);
    } else if (response.statusCode == 404) {
      //트랙 없는 상태
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}


//homeSetting
Future<void> homeSetting(BuildContext context, int tid, int week, int selectedDay) async {
print("${selectedDay}");
  //날짜 + 주차
  await getweek_GET(context);
  await mealDayCalorieToday_GET(context);
  await goalNowNutrient_GET(context);
  await mealTodayListup_GET(context);
 // await routine_GET(context, tid, week, weekday);


  bottomShow(context);
}

//api list
//루틴의 진행 퍼센트 출력 > 그룹에 들어야 출력
Future<void> getweek_GET(BuildContext context) async {
  // final pv = Provider.of<HomeSave>(context);
  // bool istracking = pv.istracking;
  String? tk = await getTk();
  String funNm = 'getweek_GET';
  String uri = '$url/clear/routine/get_week';
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
    );
    // final data = jsonDecode(response.data);
    print(response.data);

    if (response.statusCode == 200) {
      final res = response.data;
      if (res.length == 0) {}
    } else if (response.statusCode == 404) {
      //기록된 내역이 없음
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

//오늘의 칼로리, 목표 칼로리, 소모 칼로리, 몸무게
Future<void> mealDayCalorieToday_GET(BuildContext context) async {
  String? tk = await getTk();
  print("tk : $tk");
  String funNm = 'mealDayCalorieToday_GET';
  print('$funNm - 요청시작');
  String uri = '$url/meal_day/get/calorie_today';
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

    if (response.statusCode == 200) {
      final res = response.data;
      if (res.length == 0) {}
    } else if (response.statusCode == 404) {
      //기록된 내역이 없음
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

// 탄단지
Future<void> goalNowNutrient_GET(BuildContext context) async {
  String? tk = await getTk();
  String funNm = 'goalNowNutrient_GET';
  print('$funNm - 요청시작');
  String uri = '$url/meal_day/get/goal_now_nutrient';
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
    print(response.data);

    if (response.statusCode == 200) {
      final res = response.data;
      if (res.length == 0) {}
    } else if (response.statusCode == 404) {
      //기록된 내역이 없음
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

// 기록
Future<void> mealTodayListup_GET(BuildContext context) async {
  String? tk = await getTk();
  String funNm = 'mealTodayListup_GET';
  //회원 검색함수 - 돋보기 클릭 시 작동
  print("tk : $tk");
  print('$funNm - 요청시작');
  String uri = '$url/meal_day/get/mealhour_today/$today';
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
    if (response.statusCode == 200) {
      final res = response.data;
      if (res.length == 0) {}
      print(res);
      var _list = Map<String, List<dynamic>>.from(res);
      final pv = Provider.of<HomeSave>(context, listen: false);
      pv.setMealList(_list);
    } else if (response.statusCode == 404) {
      //트랙 없는 상태
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

//루틴리스트
Future<void> routine_GET( BuildContext context, int tid, int week, String weekday) async {
  String funNm = 'Routine_GET';
  print('$funNm - 요청시작');

  String? tk = await getTk();
  String trackId = tid.toString();
  String uri = '$url/track/routine/list/$trackId';

  try {
    final response = await dio.get(uri,
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
        queryParameters: {"week": week, "weekday": "$weekday"});

    final res = response.data;
    if (response.statusCode == 200) {
      // print(List<dynamic>.from(res));
      // final pv = Provider.of<RoutineListProvider>(context, listen: false);
      // pv.update(List<dynamic>.from(res));
    } else if (response.statusCode == 404) {
      //트랙 없는 상태
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

//updateTodayLq_PATCH : 물, 커피 업데이트
Future<void> updateTodayLq_PATCH(BuildContext context, String type, int data) async {
  String funNm = "updateTodayLq_PATCH";
  String? tk = await getTk();
  print('$funNm - 요청시작');
  final pv = Provider.of<DaySubInfo>(context, listen: false);
  // 전송할 데이터 정의
  Map<String, dynamic> requestBody = {"water": 0, "coffee": 0, "alcohol": 0};

  type == "water"
      ? requestBody = {
          "water": data,
          "coffee": pv.daySubInfoList['coffee'],
          "alcohol": 0
        }
      : requestBody = {
          "water": pv.daySubInfoList['water'],
          "coffee": data,
          "alcohol": 0
        };

  String uri = '$url/meal_day/update/wca/$today';
  try {
    final response = await dio.patch(
      uri,
      data: requestBody,
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
      type == "water" ? pv.updateWater(data) : pv.updateCoffee(data);
      bottomSheetType500(context, suc500_1(context));
    } else {
      bottomSheetType500(context, fail500_1(context));
    }
  } catch (e) {
    print('$funNm Error : $e');
  }
}




//중요한 api(결과값에 따라 트랙 진행여부 및 home화면의 init Data setting이 바뀜)
Future<void> trackNmDDay_GET(BuildContext context, String selectDay) async {
  //그룹 들어가야 출력됨
  String? tk = await getTk();
  String funNm = 'trackNmDDay_GET';
  String uri = '$url/track/group/get/$selectDay/name_dday';
  try {
    final response = await dio.get(
      uri,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $tk',
        },
        validateStatus: (status) {
          print('$funNm :  ${status}');
          return status != null && status < 500; // 상태 확인을 명확하게
        },
      ),
    );
    print(response.data);
    //200 : 트랙 진행, 404 : 트랙 미진행
    final pv = Provider.of<HomeSave>(context, listen: false);
    if (response.statusCode == 200) {
      final res = response.data;
      if (res != null && res.isEmpty) {  //트랙 진행 중이지 않은 경우
        pv.setIsTracking(false);
      } else {                           //트랙 진행 중인 경우
        int dday = res['dday'];  //오늘 몇 일째(트랙에서)
        int weekCnt = 0;  //주차
        switch(dday % 7){   //(오늘 몇 일째 기록 중 / 7) 의 나머지로 주차 확인
          case 0 : weekCnt = 1;
          case 1 : weekCnt = 2;
          case 2 : weekCnt = 3;
          case 3 : weekCnt = 4;
          case 4 : weekCnt = 5;
          case 5 : weekCnt = 6;
          case 6 : weekCnt = 7;
          case 7 : weekCnt = 8;
        }
        String weekDay = getTodayWeekdayStr();
        pv.setWeekDay(weekCnt,weekDay, today);  //오늘 날짜 form init Setting
        pv.setIsTracking(true);

        //home화면 selectedDay의 init 데이터 세팅(디폴트 : 오늘)
        int selectedDay = getTodayWeekday();  //초기데이터로 오늘 세팅
        //homeSetting(context, tid, week, selectedDay);
      }
    }
    else if (response.statusCode == 404) {
      //기록된 내역이 없음
      pv.setIsTracking(false);
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
      pv.setIsTracking(false);
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
  // setState(() {
  //   isLoading = false;
  // });
  bottomShow(context);
}

//몇 주차, 날짜
Future<void> trackDate_GET() async {
  //그룹 들어가야 출력됨
  String? tk = await getTk();
  print("tk : $tk");
  String funNm = 'trackDate_GET';
  print('$funNm - 요청시작');
  String uri = '$url/track/name/date';
  try {
    final response = await dio.get(
      uri,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $tk',
        },
        validateStatus: (status) {
          print('$funNm :  ${status}');
          return status != null && status < 500; // 상태 확인을 명확하게
        },
      ),
    );
    // final data = jsonDecode(response.data);
    print(response.data);

    // if (response.statusCode == 200) {
    //   final res = response.data;
    //   if (res.length == 0) {}
    // } else if (response.statusCode == 404) {
    //   //기록된 내역이 없음
    // } else {
    //   print(' $funNm Error(statusCode): ${response.statusCode}');
    // }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}

// 선택한 날의 식단 기록 리스트
Future<void> saveMealListup_GET(BuildContext context) async {
  String? tk = await getTk();
  String funNm = 'mealTodayListup_GET';
  //회원 검색함수 - 돋보기 클릭 시 작동
  print("tk : $tk");
  print('$funNm - 요청시작');
  String uri = '$url/meal_day/get/mealhour_today/$today';
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
    if (response.statusCode == 200) {
      final res = response.data;
      if (res.length == 0) {}
      print(res);
      var _list = Map<String, List<dynamic>>.from(res);
      final pv = Provider.of<HomeSave>(context, listen: false);
      pv.setMealList(_list);
    } else if (response.statusCode == 404) {
      //트랙 없는 상태
    } else {
      print(' $funNm Error(statusCode): ${response.statusCode}');
    }
  } catch (e) {
// 오류 처리
    print('$funNm Error: $e');
  }
}