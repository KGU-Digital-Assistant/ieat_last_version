import 'package:flutter/material.dart';
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
import 'package:ieat/track/trackaction.dart';
import 'package:ieat/track/trackroutine.dart';
import 'package:ieat/track/trackstrart.dart';
import 'package:ieat/util.dart';
import 'package:ieat/constants.dart';
import 'package:provider/provider.dart';

import '../home/homeaction.dart';
import '../init.dart';
import '../provider.dart';
import '../styleutil.dart';


class TrackSf extends StatefulWidget {
  const TrackSf({super.key});

  @override
  State<TrackSf> createState() => _TrackSfState();
}

class _TrackSfState extends State<TrackSf> {
  final itemCount = 10; // 예시로 항목 수를 설정
  final trackList = List.generate(20, (index) => 'Track $index'); // 예시 리스트
  String? nnm;
  bool _isloading = true;
  List<String> mondays = getMondaysForNextWeeks();
  String _selectedMonday = getMondayOfCurrentWeek(DateTime.now());

  // int _selectedTrackStartDay = mondaysAsInts[0];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsyncFunctions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final trackProvider = Provider.of<TrackProvider>(context, listen: false);
    trackProvider.notifyListeners(); // 상태 강제 트리거
  }

  Future<void> initAsyncFunctions() async {
    String? nickname = await getNickNm();
    setState(() {
      nnm = nickname;
    });
    await allTrackListup_GET();
  }

  // nnm = await getNickNm();
  Future<void> allTrackListup_GET() async {
    //[{track_id: 1, name: 새로운 식단 트랙, create_time: 2024-09-14T00:37:46.923792, using: false}]
    String? tk = await getTk();
    String funNm = 'allTrackListup_GET';
    String uri = '$url/track/get/alltracks';
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
      if (response.statusCode == 200) {
        final res = response.data;
        print("$funNm : $res");
        if (res.length == 0) {}
        setState(() {
          _isloading = false;
          var all_TrackList = List<Map<String, dynamic>>.from(res);
          final trackListProvider =
          Provider.of<TrackProvider>(context, listen: false);
          trackListProvider.listInsert(all_TrackList);
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

  // 트랙 생성 서버요청
  Future<void> createTrack_POST(BuildContext context) async {
    String? tk = await getTk();
    String funcname = 'createTrack_POST';
    print('$funcname - 요청시작');
    String uri = '$url/track/create';
    try {
      final response = await dio.request(
        uri,
        options: Options(
            method: 'POST',
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $tk'
            },
            validateStatus: (status) {
              print('$funcname : $status');
              return status! < 500;
            }),
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 204) {
        int tid = response.data['track_id'];
        createTrackNext_PATCH(context, tid);
      } else {
        bottomSheetType300(context, Text('트랙 생성 실패'));
      }
    } catch (e) {
// 오류 처리
      print('$funcname Error: $e');
    }
  }

  //트랙 생성 초기에 호출하는 것
  Future<void> createTrackNext_PATCH(BuildContext context, int tid) async {
    String? tk = await getTk();
    print('create_next_Track_PATCH 요청시작');
    String uri = '$url/track/create/next';
    final uriset = Uri.parse(uri).replace(queryParameters: {
      '_track_id': '$tid',
      'cheating_cnt': "0",
    });
    var track = {
      "name": "새로운 식단트랙",
      "icon": "Melting face",
      "water": 0,
      "coffee": 0,
      "alcohol": 0,
      "duration": 14,
      "delete": false,
      "alone": true,
      "calorie": 0,
      "start_date": today,
      "end_date": today
    };
    var data = jsonEncode(track);

    try {
      final response = await http.patch(
        uriset,
        headers: {
          'Authorization': 'Bearer $tk',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: data,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        NvgToNxtPage(context, TrackCreate_Sf_1(tid: tid));
        bottomHide(context);
        final pv =
        Provider.of<OneTrackDetailInfoProvider>(context, listen: false);
        pv.clear();
        pv.setInfoFromCreate(tid);

        final trackListProvider =
        Provider.of<TrackProvider>(context, listen: false);
        trackListProvider.oneTrackInsert(tid);
        final Map<String, dynamic> _trackInfo = {
          "tid": tid,
          "name": "새로운 식단 트랙",
          "icon_name": "",
          "goal_calorie": 0,
          "water": 0,
          "coffee": 0,
          "alcohol": 0,
          "cheating_cnt": 0,
          "duration": 14,
          "delete": false,
          "alone": true,
          "start_date": today,
          "end_date": today
        };
        trackListProvider.oneTrackInsertNext(_trackInfo, tid);
      } else {
        // bottomSheetType500(context,createTrackFail(context));
      }
    } catch (e) {
      print('create_next_Track_PATCH Error : $e');
    }
  }

  Widget trackStartSuc(BuildContext context) => Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        SizedBox(
          width: 170,
          child: Image.asset(
            'assets/icons/dialog/save_suc_1.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 30),
        Text(
          "성공적으로 트랙이 시작되었습니다!",
          style: Text25BoldBlack,
        ),
        SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: 340,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
  );

  @override
  Widget build(BuildContext context) {
    if (_isloading) {
      //로딩화면
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'loading',
        theme: ThemeData(
          // 테마 설정
        ),
        home: Scaffold(
          body: SizedBox(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: ColorMainBack,
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                '트랙',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(double.maxFinite, 70),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    ColorMainBack, // 버튼 배경색
                  ),
                  elevation: MaterialStateProperty.all<double>(2),
                  shadowColor: MaterialStateProperty.all<Color>(mainBlack.withOpacity(0.5)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                      side: BorderSide(
                        color: mainBlack.withOpacity(0.1), // 테두리 색상
                        width: 0.5,       // 테두리 두께
                      ),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent, // hover 색상 제거
                  ),
                ),
                onPressed: () async {
                  await createTrack_POST(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "짜고 지키고 목표 달성!",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: Color(0xffF89C1B),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Image.asset(
                            'assets/icons/track/Melting face.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '$nnm',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: mainGrey)),
                                TextSpan(
                                    text: '님 맞춤 트랙 짜러 가기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ))
                              ])),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          size: 30,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: ()async=> await simpleAlert("연내 제공 예정인 서비스입니다."),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.fromLTRB(15, 5, 15, 5),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(double.maxFinite, 145),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      ColorMainBack,
                    ),
                    elevation: MaterialStateProperty.all<double>(2),
                    shadowColor: MaterialStateProperty.all<Color>(mainBlack.withOpacity(0.5)),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: mainBlack.withOpacity(0.1), // 테두리 색상
                          width: 0.5,       // 테두리 두께
                        ),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.transparent,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                          height: 145,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: ColorMainBack,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              const Text("트랙 마켓",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: mainBlack,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const Text("1위 박나래 2주 5kg 순삭루트",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xff7AD64F),
                                    fontWeight: FontWeight.bold,
                                  )),
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: List.generate(5,
                                          (idx)=> SizedBox(
                                          width: MediaQuery.of(context).size.width /
                                              7, // 화면 크기에 맞춰 균등 분할
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                0.0, 8.0, 0.0, 0.0),
                                            child: Container(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: 60,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                        color:
                                                        const Color(0xffEFEFEF),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFE6E6E6),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "img",
                                                          style: TextStyle(
                                                              color: const Color(
                                                                  0xff1E1E1E)
                                                                  .withOpacity(0.3),
                                                              fontWeight:
                                                              FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text('트랙명',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: mainBlack,
                                                          fontSize: 10,
                                                          fontFamily:
                                                          'Noto Sans KR',
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )))
                              )
                            ],
                          )),
                      Container(
                          height: 145,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Icon(Icons.chevron_right,
                                    size: 30, color: mainBlack),
                              )))
                    ],
                  )),
              const SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                child: Text(
                  "내 트랙",
                  style: TextStyle(
                    fontSize: 16,
                    color: mainBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              ElevatedButton(onPressed: (){},
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.fromLTRB(15, 5, 15, 5),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(double.maxFinite, 40),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    ColorMainBack,
                  ),
                  elevation: MaterialStateProperty.all<double>(2),
                  shadowColor: MaterialStateProperty.all<Color>(mainBlack.withOpacity(0.5)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                      side: BorderSide(
                        color: mainBlack.withOpacity(0.1), // 테두리 색상
                        width: 0.5,       // 테두리 두께
                      ),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: mainBlack,
                    ),
                    Text("키워드 검색",style: Text14BlackBold)
                  ],
                ),),
              // Container(
              //     height: 47,
              //     width: double.maxFinite,
              //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //     decoration: BoxDecoration(
              //       color: ColorMainBack,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: const Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           Icons.search,
              //           size: 20,
              //         ),
              //         Text("키워드 검색",
              //             style: TextStyle(
              //                 fontWeight: FontWeight.bold, fontSize: 14))
              //       ],
              //     )),
              const SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width * 1, // 최소 높이
                ),
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                  // bor   Colors.black.withOpacity(0.3)
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),  // 테두리 색상
                    width: 0.5,           // 테두리 두께
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.3), // 그림자 색상
                  //     spreadRadius: 2,  // 그림자 확산 정도
                  //     blurRadius: 5,    // 그림자 흐림 정도
                  //     offset: Offset(3, 3), // 그림자 위치 (x, y)
                  //   ),
                  // ],
                ),
                child: Consumer<TrackProvider>(
                  builder: (context, trackListProvider, child) {
                    List<Map<String, dynamic>> list =
                        trackListProvider.trackList;
                    return Column(
                      children: List.generate(
                        trackListProvider.trackList.length,
                            (idx) => Column(
                          children: [
                            Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    final pv =
                                    Provider.of<OneTrackDetailInfoProvider>(
                                        context,
                                        listen: false);
                                    pv.clear();
                                    pv.setInfoFromDetail(list[idx]);
                                    NvgToNxtPage(
                                        context,
                                        TrackDetail_Sf(
                                            pagetype: "상세보기",
                                            track: list[idx]));
                                    bottomHide(context);
                                  },
                                  style: ButtonStyle(
                                    padding:
                                    MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.fromLTRB(5, 5, 10, 5),
                                    ),
                                    minimumSize:
                                    MaterialStateProperty.all<Size>(
                                      Size(double.infinity, 65),
                                    ),
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                      ColorMainBack,
                                    ),
                                    elevation:
                                    MaterialStateProperty.all<double>(0),
                                    shadowColor:
                                    MaterialStateProperty.all<Color>(
                                      Colors.black,
                                    ),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    overlayColor:
                                    MaterialStateProperty.all<Color>(
                                      Colors.transparent,
                                    ),
                                  ),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 3, 0, 0),
                                            child: list[idx]['icon'] == null
                                                ? SizedBox(
                                                width: 40,
                                                child: Image.asset(
                                                  'assets/icons/track/Melting face.png',
                                                  fit: BoxFit.cover,
                                                ))
                                                : SizedBox(
                                                width: 40,
                                                child: Image.asset(
                                                  'assets/icons/track/${list[idx]['icon']}.png',
                                                  fit: BoxFit.cover,
                                                ))),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${list[idx]['name']}",
                                              style: const TextStyle(
                                                color: Color(0xff7F7F7F),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            list[idx]['daily_calorie'] == null || list[idx]['daily_calorie'] == 0
                                                ? Text(
                                              "00Kcal",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            )
                                                : Text(
                                              "${list[idx]['daily_calorie']}Kcal",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        Spacer(),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: list[idx]['using']
                                              ? SizedBox(
                                            width: 70,
                                            height: 35,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      // trackStart(context,2);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      minimumSize: Size(70, 40),
                                                      backgroundColor:
                                                      Color(0xffCBFF89),
                                                      elevation: 0,
                                                      shadowColor: Colors.black,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(13),
                                                      ),
                                                    ),
                                                    child: SizedBox(),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    "진행 중",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                              : SizedBox(
                                            width: 70,
                                            height: 35,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      bottomHide(context);
                                                      Get.defaultDialog(
                                                        title: "",
                                                        content: Column(
                                                          children: [
                                                            Text(
                                                              "진행 중인 트랙을 종료하고 이 트랙을 시작할까요?",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontSize: 16),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    Get.back(); // 다이얼로그 닫기
                                                                    bottomShow(context);
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    minimumSize: Size(70, 40),
                                                                    backgroundColor:
                                                                    mainGrey,
                                                                    elevation: 0,
                                                                    shadowColor: Colors.black,
                                                                    shape:
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(5),
                                                                    ),
                                                                  ),
                                                                  child: Text('닫기', style: Text14BlackBold),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    Get.back(); // 다이얼로그 닫기
                                                                    NvgToNxtPageSlide(context, StartTrack_Sf(tid :list[idx]['track_id']));
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    minimumSize: Size(70, 40),
                                                                    backgroundColor:
                                                                    Color(0xffCBFF89),
                                                                    elevation: 0,
                                                                    shadowColor: Colors.black,
                                                                    shape:
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(5),
                                                                    ),
                                                                  ),
                                                                  child: Text('시작', style: Text14BlackBold),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        barrierDismissible: false, // 바깥 영역 클릭 시 닫히지 않도록 설정
                                                        backgroundColor: Colors.white, // 다이얼로그 배경색
                                                        radius: 10, // 모서리 둥글기
                                                      );

                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      minimumSize: Size(70, 40),
                                                      backgroundColor:
                                                      Color(0xffF3F3F3),
                                                      elevation: 0,
                                                      shadowColor: Colors.black,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(13),
                                                      ),
                                                    ),
                                                    child: SizedBox(),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    "빠른 시작",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackCreate_Sf_1 extends StatefulWidget {
  const TrackCreate_Sf_1({super.key, required this.tid});

  final tid;

  @override
  State<TrackCreate_Sf_1> createState() => _TrackCreate_Sf_1State();
}

class _TrackCreate_Sf_1State extends State<TrackCreate_Sf_1> {
  final CarouselSliderController? _controller = CarouselSliderController();
  final CarouselSliderController? _tabcontroller = CarouselSliderController();
  TextEditingController _trackNmController = TextEditingController();
  TextEditingController _goalCalController = TextEditingController();
  Map<String, dynamic> createTrackInitInfo = {
    "track id": 0,
    "track icon": "Melting face",
    "track name": "",
    "goal Calorie": "",
  };

  String trackIconNm = "";
  String errmsg = "";

  @override
  void initState() {
    setState(() {
      createTrackInitInfo['track id'] = widget.tid;
    });
    super.initState();
  }

  Widget tabSlider(idx, context) => idx == 0 ? trackNmCal(context) : goalCal(context);

  Widget trackNmCal(context) => Padding(
    padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
    child: Container(
      height: 110,
      width: getWidthRatioFromScreenSize(context, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "트랙의 이름은 무엇으로 할까요?",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Stack(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 70,
                      width: getWidthRatioFromScreenSize(context, 0.7),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black, // 바텀 테두리 색상
                              width: 1.0, // 바텀 테두리 두께
                              style: BorderStyle
                                  .solid, // 바텀 테두리 스타일 (solid, dashed 등)
                            ),
                          )),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.grey, // 입력 텍스트 색상
                            fontSize: 30, // 입력 텍스트 크기
                            fontWeight: FontWeight.w900, // 입력 텍스트 두께
                          ),
                          controller: _trackNmController,
                          decoration: InputDecoration(
                            hintText: '한문철식단따라잡기',
                            hintStyle: TextStyle(
                              color: Colors.grey, // 힌트 텍스트 색상
                              fontSize: 30, // 힌트 텍스트 크기
                              fontWeight: FontWeight.w900, // 힌트 텍스트 두께
                            ),
                            border: InputBorder.none, // 모든 테두리 제거
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ))
                ],
              ),
              Container(
                height: 70,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      onPressed: () {
                        if (_trackNmController.text.isEmpty) {
                          setState(() {
                            errmsg = "트랙 이름을 입력해 주세요.";
                          });
                        } else {
                          if (errmsg != "")
                            setState(() {
                              errmsg = "";
                            }); // 오류 메시지 초기화
                          _tabcontroller?.nextPage();
                          setState(() {
                            createTrackInitInfo['track name'] =
                                _trackNmController.text;
                          });
                        }
                      }, //여기
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(getWidthRatioFromScreenSize(context, 0.2),
                              60),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          ColorMainBack, // 버튼 배경색
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        shadowColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                            ColorBackGround),
                      ),
                      child: Icon(Icons.arrow_forward,
                          color: mainBlack, size: 30)),
                ),
              )
            ],
          ),
          Text(
            errmsg,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
        ],
      ),
    ),
  );

  Widget goalCal(context) => Padding(
    padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
    child: Container(
      height: 110,
      width: getWidthRatioFromScreenSize(context, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "일일 목표 칼로리는 몇으로 설정할까요?",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Stack(
            children: [
              Stack(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Container(
                            height: 70,
                            width:
                            getWidthRatioFromScreenSize(context, 0.5),
                            decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    // 바텀 테두리 색상
                                    width: 1.0,
                                    // 바텀 테두리 두께
                                    style: BorderStyle
                                        .solid, // 바텀 테두리 스타일 (solid, dashed 등)
                                  ),
                                ))),
                        Container(
                            height: 70,
                            width: 100,
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Kcal',
                                style: TextStyle(
                                  color: mainBlack, // 힌트 텍스트 색상
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: TextField(
                            style: TextStyle(
                              color: Colors.grey, // 힌트 텍스트 색상
                              fontSize: 30, // 힌트 텍스트 크기
                              fontWeight: FontWeight.w900, // 힌트 텍스트 두께
                            ),
                            controller: _goalCalController,
                            decoration: InputDecoration(
                              hintText: '2,000',
                              hintStyle: TextStyle(
                                color: Colors.grey, // 힌트 텍스트 색상
                                fontSize: 30, // 힌트 텍스트 크기
                                fontWeight: FontWeight.w900, // 힌트 텍스트 두께
                              ),
                              border: InputBorder.none, // 모든 테두리 제거
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        )),
                  )
                ],
              ),
              Container(
                height: 70,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      onPressed: () {
                        if (_goalCalController.text.isEmpty) {
                          setState(() {
                            errmsg = "목표 칼로리를 입력해 주세요.(추천 목표 칼로리 : 2,000)";
                          });
                        } else {
                          if (errmsg != "")
                            setState(() {
                              errmsg = "";
                            }); // 오류 메시지 초기화
                          final pv =
                          Provider.of<OneTrackDetailInfoProvider>(
                              context,
                              listen: false);
                          pv.setName(_trackNmController.text);
                          pv.setCalorie(int.parse(_goalCalController.text));
                          NvgToNxtPage(context, TrackDetail_Sf(pagetype: "생성"));
                        }
                      }, //여기
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(getWidthRatioFromScreenSize(context, 0.2),
                              60),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          ColorMainBack, // 버튼 배경색
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        shadowColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                            ColorBackGround),
                      ),
                      child: Icon(Icons.arrow_forward,
                          color: mainBlack, size: 30)),
                ),
              )
            ],
          ),
          Text(
            errmsg,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                "트랙 생성",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              leading: IconButton(
                onPressed: () {
                  popWithSlideAnimation(context, 2);
                  bottomShow(context);
                },
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.transparent,
                    )
                ),
                icon: Icon(Icons.chevron_left, size: 30),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        height: 100,
                        width: getWidthRatioFromScreenSize(context, 1),
                        child: CarouselSlider(
                          items: List.generate(
                              8,
                                  (i) => ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    padding:
                                    MaterialStateProperty.all<EdgeInsets>(
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                      Size(double.maxFinite, 70),
                                    ),
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                      ColorMainBack, // 버튼 배경색
                                    ),
                                    elevation:
                                    MaterialStateProperty.all<double>(0),
                                    shadowColor: MaterialStateProperty.all<Color>(
                                        Colors.black),
                                    shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    overlayColor:
                                    MaterialStateProperty.all<Color>(
                                      Colors.transparent, // hover 색상 제거
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: 70,
                                    child: Image.asset(
                                      'assets/icons/track/${icons[i]}.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ))),
                          options: CarouselOptions(
                            scrollDirection: Axis.horizontal,
                            viewportFraction: 0.26,
                            // 아이콘의 크기에 맞게 조정
                            height: 80,
                            // 아이콘의 높이에 맞게 조정
                            enlargeCenterPage: true,
                            // 중앙 아이콘을 강조
                            autoPlay: false,
                            // 자동 재생 여부
                            onPageChanged: (idx, reason) {
                              // print("$idx : ${getIconNm(idx)}");
                              setState(() {
                                createTrackInitInfo['track icon'] = icons[idx];
                              });
                              final pv = Provider.of<OneTrackDetailInfoProvider>(
                                  context,
                                  listen: false);
                              pv.setIcon(icons[idx]);
                            },
                          ),
                          carouselController: _controller,
                        )),
                    CarouselSlider.builder(
                      carouselController: _tabcontroller,
                      options: CarouselOptions(
                          height: 400,
                          initialPage: 0,
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                          scrollPhysics: NeverScrollableScrollPhysics()),
                      itemCount: 2,
                      itemBuilder: (context, idx, realIndex) {
                        return tabSlider(idx, context);
                      },
                    ),
                  ],
                ),
              ),
            )));
  }
}

Widget onlyCanStartMonday(BuildContext context) => Container(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 10),
      SizedBox(
        width: 170,
        child: Image.asset(
          'assets/icons/dialog/save_fail_1.png',
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 30),
      Text(
        "트랙은 월요일부터 시작할 수 있어요.",
        style: Text25BoldBlack,
      ),
      SizedBox(height: 40),
      SizedBox(height: 15),
      Center(
        child: SizedBox(
          width: 340,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
                  color: ColorBackGround,
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
);

Widget createTrackSuc(BuildContext context) => Container(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 30),
      SizedBox(
        width: 170,
        child: Image.asset(
          'assets/icons/dialog/save_suc_1.png',
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 30),
      Text(
        "성공적으로 저장하였습니다.",
        style: Text25BoldBlack,
      ),
      SizedBox(height: 40),
      Center(
        child: SizedBox(
          width: 340,
          child: ElevatedButton(
            onPressed: () {
              bottomShow(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
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
);

Widget createTrackFail(BuildContext context) => Container(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 30),
      SizedBox(
        width: 170,
        child: Image.asset(
          'assets/icons/dialog/save_fail_1.png',
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 30),
      Text(
        "오류가 발생하였습니다.",
        style: Text25BoldBlack,
      ),
      SizedBox(height: 40),
      Center(
        child: SizedBox(
          width: 340,
          child: ElevatedButton(
            onPressed: () {
              bottomShow(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
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
);

class TrackDetail_Sf extends StatefulWidget {
  const TrackDetail_Sf(
      {super.key, this.pagetype, this.track, this.createTrackInitInfo});

  final pagetype; // 생성, 상세보기
  final track; // 상세보기일 때만 전달
  final createTrackInitInfo; // 생성일 때만 전달

  @override
  State<TrackDetail_Sf> createState() => _TrackDetail_SfState();
}

class _TrackDetail_SfState extends State<TrackDetail_Sf>
    with TickerProviderStateMixin, ChangeNotifier {
  bool _isloading = true;

  TextEditingController _goalCalController = TextEditingController();
  TextEditingController _trackNmController = TextEditingController();

  Widget chgTrackNm(BuildContext context, String hintText) => Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "트랙 이름 변경",
          style: Text15Bold,
        ),
        SizedBox(
            width: 200,
            child: Center(
              child: TextField(
                controller: _trackNmController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainBlack),
                  border: InputBorder.none, // 모든 테두리 제거
                ),
                keyboardType: TextInputType.text,
              ),
            )),
        SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                bottomShow(context);
                Navigator.pop(context);
                final pv = Provider.of<OneTrackDetailInfoProvider>(context,
                    listen: false);
                pv.setName(_trackNmController.text);
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
                      "저장",
                      style: Text22BoldBlack,
                    ),
                  )),
            ),
          ),
        )
      ],
    ),
  );

  @override
  void dispose() {
    _trackNmController.dispose();
    _goalCalController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.pagetype == "생성") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pv = Provider.of<OneTrackDetailInfoProvider>(context, listen: false);
        pv.setPageType(widget.pagetype);
        setState(() {
          _isloading = false;
        });
      });
    } else {
      OneTrackInfo_GET();
    }
  }

  Future<void> OneTrackInfo_GET() async {
    String funNm = 'OneTrackInfo_GET';
    print('$funNm - 요청시작');
    final pv = Provider.of<OneTrackDetailInfoProvider>(context, listen: false);
    pv.setPageType(widget.pagetype);
    String? tk = await getTk();
    String uri = '$url/track/get/${pv.oneTrackInfo['tid']}/Info';
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

      final res = response.data;
      print(res);
      if (response.statusCode == 200) {
        var oneTrackInfo = Map<String, dynamic>.from(res); //name에서 사용자 아이디 뽑힘
        pv.setInfoFromDetail_GETinfo(oneTrackInfo);
        setState(() {
          _isloading = false;
        });
      } else if (response.statusCode == 404) {
      } else {
        print(' $funNm Error(statusCode): ${response.statusCode}');
      }
    } catch (e) {
// 오류 처리
      print('$funNm Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isloading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'loading',
        theme: ThemeData(
          // 테마 설정
        ),
        home: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "트랙 ${widget.pagetype}",
              style: Text14BlackBold,
            ),
            leading: IconButton(
                onPressed: () {
                  popWithSlideAnimation(context, 2);
                },
                icon: Icon(Icons.chevron_left, size: 30),
                style: ButtonStyle(
                  overlayColor:
                  MaterialStateProperty.all(Colors.transparent), // Hover 효과 없애기
                )
            ),
          ),
          body: SizedBox(),
        ),
      );
    }

    return Consumer<OneTrackDetailInfoProvider>(builder: (context, pv, child) {

      return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "트랙 ${widget.pagetype}",
            style: TextAppbar,
          ),
          leading: IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: '',
                content: Column(
                  children: [
                    const Text(
                      "잠깐!\n지금 페이지에서 나가면\n내용이 저장되지 않아요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            popWithSlideAnimation(context, 2);
                            bottomShow(context);
                          },
                          style: ElevatedButton
                              .styleFrom(
                            minimumSize: Size(70, 40),
                            backgroundColor:
                            Color(0xffCBFF89),
                            elevation: 0,
                            shadowColor: Colors.black,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(5),
                            ),
                          ),
                          child: Text('나가기', style: Text14BlackBold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton
                              .styleFrom(
                            minimumSize: Size(70, 40),
                            backgroundColor:
                            Color(0xffCBFF89),
                            elevation: 0,
                            shadowColor: Colors.black,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(5),
                            ),
                          ),
                          child: Text('돌아가기', style: Text14BlackBold),
                        )
                      ],
                    )
                  ],
                ),
                barrierDismissible: false, // 바깥 영역 클릭 시 닫히지 않도록 설정
                backgroundColor: Colors.white, // 다이얼로그 배경색
                radius: 10, // 모서리 둥글기
              );
            },
            style: ButtonStyle(
              overlayColor:
              MaterialStateProperty.all(Colors.transparent), // Hover 효과 없애기
            ),
            icon: Icon(Icons.chevron_left, size: 30),
          ),
          actions: [ //상세보기일 경우 삭제 버튼 배치
            widget.pagetype == "생성"
                ?const SizedBox()
                :TextButton(
                style: ButtonStyle(
                  overlayColor:
                  MaterialStateProperty.all(Colors.transparent), // Hover 효과 없애기
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: "",
                    content: Column(
                      children: [
                        Text(
                          "${pv.oneTrackInfo['name']}트랙을 삭제할까요?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Get.back(); // 다이얼로그 닫기
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(70, 40),
                                backgroundColor: mainGrey.withOpacity(0.6),
                                elevation: 0,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text('닫기', style: Text14BlackBold),
                            ),
                            ElevatedButton(
                              onPressed: () async{
                                Get.back(); // 다이얼로그 닫기
                                deleteOneTrack(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(70, 40),
                                backgroundColor: Color1BAF79,
                                elevation: 0,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text('삭제', style: Text14BlackBold),
                            )
                          ],
                        )
                      ],
                    ),
                    barrierDismissible: false,
                    // 바깥 영역 클릭 시 닫히지 않도록 설정
                    backgroundColor: Colors.white,
                    // 다이얼로그 배경색
                    radius: 10, // 모서리 둥글기
                  );
                },
                child: Text(
                  "삭제",
                  style: Text14BlackBold,
                ))
          ],
        ),
        body: GestureDetector(
          onTap: () {},
          child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              bottomHide(context);
                              bottomSheetType300(context, chgTrackIcon(context));
                            },
                            child: SizedBox(
                              width: 33,
                              child: Image.asset(
                                'assets/icons/track/${pv.oneTrackInfo['icon']}.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.all(0),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                Size(33, 33),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                              shadowColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                              // shape:
                              // MaterialStateProperty.all<OutlinedBorder>(
                              //   RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(10),
                              //   ),
                              // ),
                              overlayColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                            )),
                        TextButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.only(top: 3),
                              ),
                              overlayColor:
                              MaterialStateProperty.all(Colors.transparent), // Hover 효과 없애기
                            ),
                            onPressed: () {
                              bottomHide(context);
                              bottomSheetType300(context,
                                  chgTrackNm(context, pv.oneTrackInfo['name']));
                            },
                            child: Text(
                              "${pv.oneTrackInfo['name']}",
                              style: Text25BoldBlack,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Container(
                      width: double.maxFinite,
                      height: 50,
                      child: Row(
                        children: [
                          Text(
                            "하루 목표 칼로리",
                            style: Text17BoldBlack,
                          ),
                          Spacer(),
                          Container(
                            width: 150,
                            height: 40,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                              color: ColorMainBack,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFFE6E6E6),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    controller: _goalCalController,
                                    decoration: InputDecoration(
                                      contentPadding:
                                      EdgeInsets.fromLTRB(15, 0, 15, 9),
                                      hintText:
                                      '${pv.oneTrackInfo['calorie'] ?? "00"}',
                                      hintStyle: const TextStyle(
                                        color: mainBlack,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged : (value) {
                                      final pv =
                                      Provider.of<OneTrackDetailInfoProvider>(
                                          context,
                                          listen: false);
                                      pv.setCalorie(int.parse(value));
                                      print(pv.oneTrackInfo);
                                    },
                                  ),
                                ),
                                Text(
                                  "Kcal",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff818181)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      return DefaultTabController(
                        length: 3, // 탭의 개수를 지정
                        initialIndex: // null이나 14는 0, 30은 1, 60은 2
                        pv.oneTrackInfo['duration'] == null || pv.oneTrackInfo['duration'] == 14
                            ? 0 : pv.oneTrackInfo['duration'] == 30 ? 1: 2,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    height: 45,
                                    width: MediaQuery.sizeOf(context).width * 0.8,
                                    decoration: BoxDecoration(
                                      color: Color(0xff787880).withOpacity(0.09),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SizedBox(
                                      child: TabBar(
                                        dividerColor: Colors.transparent,
                                        indicatorColor: Colors.transparent,
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                        labelStyle: TextStyle(
                                          fontSize: 14,
                                          // 클릭된 탭의 텍스트 크기
                                          fontWeight: FontWeight.bold,
                                          // 클릭된 탭의 텍스트 두께
                                          color: mainBlack, // 클릭된 탭의 텍스트 색상
                                        ),
                                        unselectedLabelStyle: TextStyle(
                                          fontSize: 14,
                                          // 선택되지 않은 탭의 텍스트 크기
                                          fontWeight: FontWeight.normal,
                                          // 선택되지 않은 탭의 텍스트 두께
                                          color: mainBlack.withOpacity(
                                              0.8), // 선택되지 않은 탭의 텍스트 색상
                                        ),
                                        tabs: [
                                          Tab(text: "14일"),
                                          Tab(text: "30일"),
                                          Tab(text: "60일"),
                                        ],
                                        onTap: (idx) {
                                          final pv = Provider.of< OneTrackDetailInfoProvider>(
                                              context,
                                              listen: false);
                                          switch (idx) {
                                            case 0:
                                              pv.setduration(14);
                                            case 1:
                                              pv.setduration(30);
                                            case 2:
                                              pv.setduration(60);
                                            default:
                                              pv.setduration(14);
                                          };
                                          final tpv = Provider.of<trackDetailTabProvider>(context,listen: false);
                                          tpv.setweek(1);
                                        },
                                      ),
                                    )),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 800,

                              // constraints: BoxConstraints(
                              //   minHeight: MediaQuery.of(context).size.width * 1, // 최소 높이
                              // ),
                              child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  FutureBuilder<List<String>>(
                                    future: fetchDataForTab("14일"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child:
                                            Text('Error: ${snapshot.error}'));
                                      } else {
                                        return Container(
                                          child: routinTab_SF(tablength: 2),
                                        );
                                      }
                                    },
                                  ),
                                  FutureBuilder<List<String>>(
                                    future: fetchDataForTab("30일"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child:
                                            Text('Error: ${snapshot.error}'));
                                      } else {
                                        return Container(
                                          child: routinTab_SF(tablength: 4),
                                        );
                                      }
                                    },
                                  ),
                                  FutureBuilder<List<String>>(
                                    future: fetchDataForTab("60일"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child:
                                            Text('Error: ${snapshot.error}'));
                                      } else {
                                        return Container(
                                          child: routinTab_SF(tablength: 8),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )),
        ),
      );
    });
  }

  // 각 탭에서 데이터를 가져오는 예시 (비동기 함수)
  Future<List<String>> fetchDataForTab(String tab) async {
    // 데이터를 가져오는 비동기 작업 (예: API 호출 등)
    await Future.delayed(Duration(milliseconds: 100)); // 임시로 딜레이 추가
    return ["Item 1", "Item 2", "Item 3"]; // 예시 데이터
  }
}

class routinTab_SF extends StatefulWidget {
  const routinTab_SF({super.key, required this.tablength});

  final tablength;

  @override
  State<routinTab_SF> createState() => _routinTab_SFState();
}

class _routinTab_SFState extends State<routinTab_SF> {
  List<int> week = [1, 2, 3, 4, 5, 6, 7];
  List<int> isClickedWeek = [1, 0, 0, 0, 0, 0, 0];
  int selectedWeek = 1; //1주인지 2주인지 등(1~) - 곱셈에서 사용
  int selectedDay = 1; //일주일에서 월요일 화요일인지(1~) - 곱셈에서 사용

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tablength, // 탭의 개수를 지정
      child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            toolbarHeight: 10,
            // AppBar의 기본 높이를 0으로 설정
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40), // TabBar의 높이 조정
              child: TabBar(
                // dividerColor: Colors.transparent,
                  indicatorColor: Color1BAF79,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelStyle: const TextStyle(
                    fontSize: 14, // 클릭된 탭의 텍스트 크기
                    fontWeight: FontWeight.bold, // 클릭된 탭의 텍스트 두께
                    color: mainBlack, // 클릭된 탭의 텍스트 색상
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14, // 선택되지 않은 탭의 텍스트 크기
                    fontWeight: FontWeight.normal, // 선택되지 않은 탭의 텍스트 두께
                    color: mainBlack.withOpacity(0.8), // 선택되지 않은 탭의 텍스트 색상
                  ),
                  tabs: List.generate(widget.tablength, (index) {
                    return Tab(
                        text:
                        "${index + 1}주"); // 각 탭의 텍스트를 "1주", "2주", ... 형태로 설정
                  }),
                  onTap: (index) {
                    setState(() {
                      selectedWeek = index + 1;
                    });
                    final pv = Provider.of<trackDetailTabProvider>(context,listen: false); //몇 주차인지 저장
                    pv.setweek(selectedWeek);
                  }),
            ),
            elevation: 0, // AppBar의 그림자 제거
          ),
          body: Expanded(
              child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                      widget.tablength,
                          (idx) => FutureBuilder<List<int>>(
                        future:
                        fetchDataForTab(widget.tablength), //몇 일차인지 계산
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Container(
                              child: routinTab_byweek_SF(
                                  selectedWeek: selectedWeek,
                                  selectedDay: selectedDay),
                            );
                          }
                        },
                      ))))),
    );
  }

  // 각 탭에서 데이터를 가져오는 예시 (비동기 함수)
  Future<List<int>> fetchDataForTab(int tab) async {
    // 데이터를 가져오는 비동기 작업 (예: API 호출 등)
    await Future.delayed(Duration(milliseconds: 100)); // 임시로 딜레이 추가
    return List.filled(7, 0);
  }
}

class routinTab_byweek_SF extends StatefulWidget {
  const routinTab_byweek_SF({super.key, this.selectedWeek, this.selectedDay});

  final selectedWeek; //몇 주차(index 1부터 시작함, 곱셈에서 사용)
  final selectedDay; //한 주에서 몇 일차(index 1부터 시작함, 곱셈에서 사용)

  @override
  State<routinTab_byweek_SF> createState() => _routinTab_byweek_SFState();
}

class _routinTab_byweek_SFState extends State<routinTab_byweek_SF> {
  @override
  void initState() {
    super.initState();
    print(widget.selectedWeek);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      routineListup_GET(context);
    });
  }

  List<int> week = [1, 2, 3, 4, 5, 6, 7];
  List<int> isClickedWeek = [1, 0, 0, 0, 0, 0, 0];

  Widget DayWidget(int idx, BuildContext context) => Container(
    padding: EdgeInsets.zero, // 기본 패딩 제거
    width: MediaQuery.sizeOf(context).width / 7,
    height: 70.0,
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(3.0, 8.0, 3.0, 0.0),
      child: Container(
        width: 45.0,
        height: 70.0,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              children: [
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
                                  fontSize: 13,
                                  color:
                                  const Color(0xff1E1E1E).withOpacity(0.3),
                                  fontWeight: FontWeight.bold),
                            );
                          }),
                    )),
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            Text('',  //${fomatDay(idx)}요일
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
    ),
  );
  Future<void> updateTrack_PATCH(BuildContext context) async {
    String? tk = await getTk();
    final pv = Provider.of<OneTrackDetailInfoProvider>(context, listen: false);
    Map<String, dynamic> data = {
      "name": pv.oneTrackInfo['name'],
      "icon": pv.oneTrackInfo['icon'],
      "water": pv.oneTrackInfo['water'],
      "coffee": pv.oneTrackInfo['coffee'],
      "alcohol": pv.oneTrackInfo['alcohol'],
      "duration": pv.oneTrackInfo['duration'],
      "delete": false,
      "alone": true,
      "calorie": pv.oneTrackInfo['calorie'],
      "start_date": today,
      "end_date": today
    };
    print("updateTrack_PATCH : $tk");
    print(data);
    print(pv.oneTrackInfo['tid']);
    try {
      final response = await dio.patch(
        '$url/track/update/${pv.oneTrackInfo['tid']}',
        queryParameters: {
          'cheating_cnt': pv.oneTrackInfo['cheating_cnt']
        },
        data: data,
        options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $tk'
            },
            validateStatus: (status) {
              if (status == 200) {}
              print('update_Track_PATCH : $status');
              return status! < 500;
            }),
      );

      if (response.statusCode == 204) {
        print(pv.oneTrackInfo);
        print(data);
        final tpv = Provider.of<TrackProvider>(context, listen: false);
        tpv.oneTrackUpdate(data, pv.oneTrackInfo['tid']);
        bottomHide(context);
        bottomSheetType500(context, saveTrackSuc(context));
      } else {
        bottomHide(context);
        bottomSheetType500(context, saveTrackFail(context));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 7, // 탭의 개수를 지정
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xffEBFFEE),
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 5,
            // AppBar의 높이 설정
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70), // TabBar의 높이 조정
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 70,
                    child: Column(
                      children: [
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (idx)=> Container(
                            width: 33.0,
                            height: 33.0,
                            decoration: BoxDecoration(
                              color: ColorMainBack,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isClickedWeek[idx] == 1
                              ? Color1BAF79
                                  : ColorMainBack,
                                width: 1,
                              ),
                            ),
                          )),
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (idx)=> Text("${formatDay(idx)}요일",style: Text11Black,)),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    isScrollable: false,
                    // TabBar가 스크롤 가능하게 설정
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    labelStyle: const TextStyle(
                      fontSize: 10, // 클릭된 탭의 텍스트 크기
                      fontWeight: FontWeight.bold, // 클릭된 탭의 텍스트 두께
                      color: mainBlack, // 클릭된 탭의 텍스트 색상
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 10, // 선택되지 않은 탭의 텍스트 크기
                      fontWeight: FontWeight.normal, // 선택되지 않은 탭의 텍스트 두께
                      color: mainBlack.withOpacity(0.8), // 선택되지 않은 탭의 텍스트 색상
                    ),
                    tabs: List.generate(7, (index) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 7,
                        // 각 탭의 너비 설정
                        height: 70,
                        // 원하는 높이
                        padding: EdgeInsets.zero,
                        // 패딩 제거
                        margin: EdgeInsets.zero,
                        // 마진 제거
                        alignment: Alignment.center,
                        // 텍스트 중앙 정렬
                        child: DayWidget(index, context), // 각 탭의 내용
                      );
                    }),
                    onTap: (idx) {
                      // 상태 변경을 먼저 반영
                      setState(() {
                        for (int i = 0; i < isClickedWeek.length; i++) {
                          isClickedWeek[i] = (idx == i) ? 1 : 0;
                        }
                      });

                      // 비동기 작업은 상태 변경 후 처리
                      final tabpv = Provider.of<trackDetailTabProvider>(context, listen: false);
                      tabpv.setDay(idx);
                      routineListup_GET(context);
                      print(isClickedWeek);
                    },
                  )
                ],
              ),
            ),
            elevation: 0, // AppBar의 그림자 제거
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(
                7,(idx) => Padding(
              padding: EdgeInsets.all(15),
              child : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('루틴리스트', style: Text14BlackBold),
                    const SizedBox(height: 10),
                    Consumer<RoutinListProvider>(
                        builder: (context,pv,child){
                          return Column(
                            children: List.generate(
                                pv.routineList.length,
                                    (idx) => idx == 0
                                    ? Column(children: [
                                  routineCreateButton(context),
                                  const SizedBox(height: 5),
                                ])
                                    : Column(children: [
                                  routineButton(context,idx),
                                  //id 넘겨야 함(페이지 이동 시 사용)
                                  const SizedBox(height: 5),
                                ])),
                          );
                        }),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child:
                      ElevatedButton(
                        onPressed: () => updateTrack_PATCH(context),  //트랙 업데이트
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(0),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(280, 44),
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
                              borderRadius: BorderRadius.circular(48),
                            ),
                          ),
                          overlayColor: MaterialStateProperty.all<Color>(
                            Colors.transparent,
                          ),
                        ),
                        child: Container(
                          width: 280,
                          height: 44,
                          child: Center(
                            child: Text(
                              "저장",
                              style: Text23w600white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
          ),
        ));
  }
}


//dialog에 넣어서 사용(CarouselController선언이 필요해서 class안에 넣어둠)
Widget chgTrackIcon(BuildContext context){
  final CarouselSliderController? _controller = CarouselSliderController();
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "아이콘 선택",
          style: Text15Bold,
        ),
        SizedBox(
          width: 200,
          child: CarouselSlider(
            items: List.generate(
                8,
                    (i) => ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(70, 70),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        ColorMainBack, // 버튼 배경색
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                      shadowColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(
                        Colors.transparent, // hover 색상 제거
                      ),
                    ),
                    child: SizedBox(
                      width: 70,
                      child: Image.asset(
                        'assets/icons/track/${icons[i]}.png',
                        fit: BoxFit.cover,
                      ),
                    ))),
            options: CarouselOptions(
              scrollDirection: Axis.horizontal,
              viewportFraction: 0.26,
              // 아이콘의 크기에 맞게 조정
              height: 80,
              // 아이콘의 높이에 맞게 조정
              enlargeCenterPage: true,
              // 중앙 아이콘을 강조
              autoPlay: false,
              // 자동 재생 여부
              onPageChanged: (idx, reason) {
                final pv = Provider.of<OneTrackDetailInfoProvider>(context,
                    listen: false);
                pv.setIcon(icons[idx]);
              },
            ),
            carouselController: _controller,
          ),
        ),
        SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                bottomShow(context);
                Navigator.pop(context);
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
                      "저장",
                      style: Text22BoldBlack,
                    ),
                  )),
            ),
          ),
        )
      ],
    ),
  );
}


//button(루틴 리스트에서 각 버튼 widget)
Widget routineCreateButton(BuildContext context) => ElevatedButton(
  onPressed: () {
    NvgToNxtPage(context, RoutineDetail(type: "생성"));
  },
  style: ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      EdgeInsets.all(0),
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
    height: 65,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Color(0xFFE6E6E6),
        width: 1,
      ),
    ),
    child: Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: Center(child: Icon(Icons.add, size: 25, color: mainBlack)),
    ),
  ),
); //루틴리스트의 최상단 루틴 생성 버튼
Widget routineButton(BuildContext context, int idx) =>
    ElevatedButton(
      onPressed: () {
        bottomHide(context);
        NvgToNxtPage(context, RoutineDetail(type: "상세보기"));
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.all(0),
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
      child: Consumer<RoutinListProvider>(
          builder : (context,pv,child){
            return Container(
              width: double.maxFinite,
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFE6E6E6),
                  width: 1,
                ),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                        child: Text(
                          "${formatDay(pv.routineList[idx]['time']-1)} - ${extractHour(pv.routineList[idx]['clock'])}시",  //루틴 한 요소
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ),
                    ),



                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          Text(
                            "${pv.routineList[idx]['title']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: Color(0xff464646)),
                          ),
                          Spacer(),
                          Text(
                            '${pv.routineList[idx]['calorie']}kcal',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xff464646)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );

//dialog
Widget saveTrackSuc(BuildContext context) => Container(
  child:Consumer<OneTrackDetailInfoProvider>(
      builder : (context,pv, child){
        return  Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            SizedBox(
              width: 170,
              child: Image.asset(
                'assets/icons/dialog/save_suc_1.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "성공적으로 저장하였습니다.",
              style: Text25BoldBlack,
            ),
            SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 340,
                child: ElevatedButton(
                  onPressed: () {
                    bottomShow(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if(pv.pageType == "생성") Navigator.pop(context);
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
        );
      }
  ),
); //트랙 수정 성공
//트랙 수정 실패
//트랙수정 - 아이템 변경
//트랙수정 - 트랙명 변경


Widget saveTrackFail(BuildContext context) => Container(
  child: Consumer<OneTrackDetailInfoProvider>(
    builder: (context,pv,child){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          SizedBox(
            width: 170,
            child: Image.asset(
              'assets/icons/dialog/save_fail_1.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "오류가 발생하였습니다.",
            style: Text25BoldBlack,
          ),
          SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 340,
              child: ElevatedButton(
                onPressed: () {
                  bottomShow(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  if(pv.pageType == "생성")  Navigator.pop(context);
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
      );
    },
  ),
);

