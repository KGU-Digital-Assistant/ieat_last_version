// import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/track/track.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'home/homemain.dart';
import 'home/homemainaction.dart';
import 'init.dart';
import 'moose.dart';
import 'mooseaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter의 위젯 바인딩 보장
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화
  // );

  //first카메라가 아닌 특정 카메라 선택(전면 카메라 등)
  //final CameraDescription frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

  // await Firebase.initializeApp();  - fcm
  runApp(Provider()); //fstCamera
}

class testmain extends StatelessWidget {
  const testmain({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.pink,
          child: Center(
            child: Text('test'),
          ),
        ),
      ),
    );
  }
}

//
class Provider extends StatelessWidget {
  const Provider({super.key}); // required this.fstCamera

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeSave()), //사용
        ChangeNotifierProvider(create: (_) => MealSaveProvider()), //사용
        ChangeNotifierProvider(create: (_) => BottomBarVisibility()), //바텀바
        ChangeNotifierProvider(
            create: (_) => CalenderSelectedProvider()), //사용(홈보드 달력)
        ChangeNotifierProvider(create: (_) => UserTodayTrack()), //사용(홈보드 트랙)
        ChangeNotifierProvider(create: (context) => TrackProvider()),
        ChangeNotifierProvider(
            create: (_) => trackDetailTabProvider()), //사용(선택한 날짜의 주차, 요일 저장)
        ChangeNotifierProvider(
            create: (_) => OneTrackDetailInfoProvider()), //사용(트랙 상세)
        ChangeNotifierProvider(
            create: (context) => OneRoutineDetailInfoProvider()), //사용(루틴 상세)
        ChangeNotifierProvider(create: (_) => TrackStartDayPickProvider()),
        ChangeNotifierProvider(
            create: (context) => RoutinListProvider()), //사용(루틴 리스트) ?
        ChangeNotifierProvider(create: (context) => DaySubInfo()),
        ChangeNotifierProvider(create: (context) => TrackTabModel()),
        ChangeNotifierProvider(
            create: (context) => RunningTrack()), //사용(현재 사용자가 진행중인 트랙)
        ChangeNotifierProvider(
            create: (context) => OneFoodDetail()), //사용(한 음식 디테일)
      ],
      child: Ieat(),
      // child: Ieat(),
    );
  }
}

class Ieat extends StatefulWidget {
  const Ieat({super.key}); //required this.fstCamera

  @override
  State<Ieat> createState() => _IeatState();
}

class _IeatState extends State<Ieat> with SingleTickerProviderStateMixin {
  late List<Widget> _userpages;
  bool isLoading = false;
  String initialRouteStr = "login";

  //바텀바
  final _userNavigatorKeyList =
      List.generate(3, (index) => GlobalKey<NavigatorState>());
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    todayMealSet_POST();
    // loginTest();
    // _userpages = [const Home_Sf(),Moose(), const TrackSf()];
    _userpages = [
      const Home_Sf(),
      Moose(),
      const TrackSf()
    ]; //MealMain_Sf  TrackSf
  }

//
  // 인스턴스 생성
  final storage = const FlutterSecureStorage();

// //임시 로그인
  Future<void> loginTest() async {
    //TEST용도
    var testLoginData = {'username': 'skdus', 'password': 'skdus1026@12'};
    String uri = '$url/user/login';
    try {
      final response = await dio.post(
        uri,
        data: testLoginData,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          validateStatus: (status) {
            print('loginTest : $status');
            return status! < 500;
          },
        ),
      );
      //{access_token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJza2R1cyIsImV4cCI6MTcyNjM3NjIyNH0.0pqN95I5w-_Dy86hf_UApoJpHb08pvqLp9SDvKZF23A,
      // token_type: bearer, username: skdus, user_id: 1, nickname: 복숭아엎드려납작}
      if (response.statusCode == 200) {
        print(response.data['nickname']);
        // await storage.write(key: 'user_id', value: response.data['user_id'].toString());
        // await storage.write(key: 'access_token', value: response.data['access_token']);
        // await storage.write(key: 'nickname', value: response.data['nickname']);
        await saveUserId(response.data['user_id']);
        await saveNickNm(response.data['nickname']);
        await saveTk(response.data['access_token']);
      }
    } catch (e) {
      print('loginTest Error: $e');
    }
  }

  DateTime? _lastTapped; // 마지막 탭 클릭 시간을 기록하는 변수
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      //로딩화면
      // return MaterialApp(
      //   debugShowCheckedModeBanner: false,
      //   title: 'loading',
      //   theme: ThemeData(
      //     // 테마 설정
      //   ),
      //   home: Scaffold(
      //     body: Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   ),
      // );
    }

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iEAT',
        //notosans
        theme: ThemeData(
            textTheme: GoogleFonts.notoSansTextTheme(Theme.of(context).textTheme.copyWith(
                // // 기본 스타일 정의
                // headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                // headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                // bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
                )),
            scaffoldBackgroundColor: ColorMainBack,
            iconTheme: IconThemeData(color: ColorBlack),
            appBarTheme: AppBarTheme(backgroundColor: ColorMainBack)),
        initialRoute: '/$initialRouteStr',
        routes: {
          '/': (context) => const Init_Sf(),
          '/login': (context) => const loginMain_Sf(),
          '/home': (context) => WillPopScope(
              onWillPop: () async {
                // 각 탭의 내비게이션 상태를 관리하는 기존 로직
                return !(await _userNavigatorKeyList[_currentIndex]
                    .currentState!
                    .maybePop());
              },
              child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: _userpages.map(
                      (page) {
                        int index = _userpages.indexOf(page);
                        return CustomNavigator(
                          page: page,
                          navigatorKey: _userNavigatorKeyList[index],
                        );
                      },
                    ).toList(),
                  ),
                  bottomNavigationBar: Consumer<BottomBarVisibility>(
                    builder: (context, bottomBarVisibility, child) {
                      return bottomBarVisibility.isVisible
                          ? Stack(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: ColorMainStroke,
                                        width: 1,
                                      ), // 위쪽 테두리
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TabBar(
                                        overlayColor: null,
                                        dividerColor: Colors.transparent,
                                        isScrollable: false,
                                        automaticIndicatorColorAdjustment: true,
                                        indicatorColor: Colors
                                            .transparent, // Remove the bottom line
                                        indicator: const BoxDecoration(),
                                        labelColor: Colors.black,
                                        onTap: (index) async{
                                          print('tapclick idx : $index');
                                          if (index == 0)
                                            homeMainTopPart(context);
                                          removeTempMeal_POST(context);

                                          DateTime now = DateTime.now();
                                          // 더블 클릭 감지 (1초 이내에 동일한 탭을 두 번 클릭했는지 확인)
                                          if (_currentIndex == index &&
                                              _lastTapped != null &&
                                              now.difference(_lastTapped!) <
                                                  Duration(seconds: 1)) {
                                            print(
                                                'tap double click idx: ${index}');
                                            // 더블 클릭 처리 - 해당 탭의 메인 페이지로 돌아감
                                            removeTempMeal_POST(context);
                                            await homeMainBottomPart(context,today);
                                            _userNavigatorKeyList[index]
                                                .currentState
                                                ?.popUntil(
                                                    (route) => route.isFirst);
                                          }

                                          // 현재 탭을 기록
                                          _currentIndex = index;
                                          _lastTapped = now;
                                        },
                                        tabs: const [
                                          Tab(
                                            icon: Icon(
                                              Icons.home,
                                              size: 25,
                                            ),
                                          ),
                                          Tab(
                                            icon: Icon(
                                              Icons.camera_alt,
                                              size: 25,
                                            ),
                                          ),
                                          Tab(
                                            icon: Icon(
                                              Icons.run_circle_outlined,
                                              size: 25,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox();
                    },
                  ),
                ),
              )),
        });
  }
}

class Init_Sf extends StatefulWidget {
  const Init_Sf({super.key});

  @override
  State<Init_Sf> createState() => _Init_SfState();
}

class _Init_SfState extends State<Init_Sf> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

//트랙 시작
Future<void> todayMealSet_POST() async {
  String? tk = await getTk();
  String funcname = 'todayMealSet_POST';
  String uri = '$url/meal_day/post/meal_day/$today';
  try {
    final response = await dio.request(
      uri,
      options: Options(
        method: 'POST',
        headers: {'accept': '*/*', 'Authorization': 'Bearer $tk'},
        validateStatus: (status) {
          print('$funcname : $status');
          return status! < 500;
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('금일 음식정보 서버 세팅 성공');
    } else {}
  } catch (e) {
// 오류 처리
    print('$funcname Error: $e');
  }
}
