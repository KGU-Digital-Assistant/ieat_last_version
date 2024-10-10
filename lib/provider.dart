
//import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ieat/util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'home/home.dart';

/**
 *
 * 1. Provider는 전부 데이터 삽입 후 추출할 때 양식을 맞춘다.
 *  (2024-01-01 => 1월 1일)
 */

int homeBoardTrackWeekCnt = 2; // 나중에 수정
String MealSave_selectedTime = "시간대";

class BottomBarVisibility with ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  void show() {
    _isVisible = true;
    notifyListeners();
  }
}

void bottomHide(BuildContext context) {
  Provider.of<BottomBarVisibility>(context, listen: false).hide();
}

void bottomShow(BuildContext context) {
  Provider.of<BottomBarVisibility>(context, listen: false).show();
}

//바텀바 관리를 위함 - 상태관리
class CustomNavigator extends StatefulWidget {
  final Widget page;
  final Key navigatorKey;

  const CustomNavigator(
      {Key? key, required this.page, required this.navigatorKey})
      : super(key: key);

  @override
  _CustomNavigatorState createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<CustomNavigator>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (context) => widget.page),
    );
  }
}

class DaySubInfo with ChangeNotifier {
  Map<String, dynamic> _daySubInfoList = {
    "water": 0,
    "coffee": 0,
    "cheating": [0, ""],
  };

  Map<String, dynamic> get daySubInfoList => _daySubInfoList;

  void updateWater(int water) {
    _daySubInfoList["water"] = water;
    notifyListeners();
  }

  void updateCoffee(int coffee) {
    _daySubInfoList["coffee"] = coffee;
    notifyListeners();
  }

  void initCheating(int cheating) {
    _daySubInfoList["cheating"][0] = cheating;
    notifyListeners();
  }

  void updateCheating(String cheating) {
    _daySubInfoList["cheating"][1] = cheating;
    notifyListeners();
  }
}

class HomeSaveTabModel with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

enum HomeType { homeSave, homeBoardCalender, homeBoardTrack }

class HomeboardTabModel with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class HomeboardTrackWeekTabModel with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
/*출력 데이터 provider*/
//트랙 미 진행 시 provider의 디폴트 데이터 출력

//홈화면
class HomeSave with ChangeNotifier {
  bool _isTracking = false; //사용자가 지금 트랙을 진행중인지 여부
  Map<String, dynamic> _trackNmDDay = {"name": "", "dday": 0, "tid": -1};

//선택한 날짜의 주차와 요일
  Map<String, dynamic> _SelctedDay = {
    "week": 1,
    "weekDay": "월",
  };

  Map<int, dynamic> _homeOfTheWeek = {
    //트랙 시작되어야 사용하는 변수
    1: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    2: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    3: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    4: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    5: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    6: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    7: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}},
    8: {"월": {}, "화": {}, "수": {}, "목": {}, "금": {}, "토": {}, "일": {}}
  };

  Map<String, dynamic> _track = {};

  var form = {
    "todayInfo": ["0000-00-00", 0], //0 : 트랙x, 1 : 1주차, 2 : 2주차 ~
    "mainInfo": {
      "carbonate": [0, 300], //[섭취, 목표]
      "protein": [0, 65], //[섭취, 목표 ]
      "fat": [0, 60] //[섭취, 목표 ]
    },
    "subInfo": {
      "water": 0,
      "coffee": 0,
      "cheating": [0, ""],
    },
    "bodyInfo": {
      "todaycalorie": 0,
      "goalcalorie": 0,
      "nowcalorie": 0,
      "burncalorie": 0,
      "weight": 0
    },
    "saveMeal": [
      ["img", "06 : 03"]
    ],
    "routineInfo": [
      //기록페이지 > 루틴 탭에서 사용
      ["mealtime", "savetime", "routineNm", true],
    ]
  };

  // todaySubData의 value =[기록 수치,계획 수치]
  var todayMainData = <String, List<dynamic>>{
    "calorie": [0, 0], //[기록, 계획]
    "carbonate": [0, 300],
    "protein": [0, 65],
    "fat": [0, 60]
  };
  var todayWeightCalories = <String, int>{
    "takeCalorie": 0,
    "burnCalorie": 0,
    "weight": 0
  };
  var todaySaveMeal = <String, dynamic>{
    "saveCnt": 0,
    "saveList": [
      ["img", "06 : 03"],
      ["img", "06 : 03"],
      ["img", "06 : 03"],
      ["img", "06 : 03"]
    ],
  };
  var todayRoutineList = [
    ["mealtime", "savetime", "routineNm", true],
    ["mealtime", "savetime", "routineNm", true],
    ["mealtime", "savetime", "routineNm", true],
    ["mealtime", "savetime", "routineNm", true],
    ["mealtime", "savetime", "routineNm", true]
  ];

  Map<String, dynamic> get SelctedDay => _SelctedDay;

  Map<int, dynamic> get homeOfTheWeek => _homeOfTheWeek;

  Map<String, dynamic> get trackNmDDay => _trackNmDDay;

  Map<String, dynamic> get track => _track;

  bool get isTracking => _isTracking;

//현재 사용자의 트랙 진행 여부 저장
  void setIsTracking(bool data) {
    _isTracking = data;
    notifyListeners();
  }

  //트랙 진행 시 기본 정보 저장
  void setRunningTrackInfo(Map<String, dynamic> data) {
    _trackNmDDay['name'] = data['name'];
    _trackNmDDay['dday'] = data['dday'];
    _trackNmDDay['tid'] = data['track_id'];
    notifyListeners();
  }

  //하루 전체 세팅(한 번 하고 데이터 있으면 set 안 함)
  //weekCnt : ${몇} 주차, weekDay : 월
  void setWeekDay(int weekCnt, String weekDay, String today) {
    if (homeOfTheWeek.containsKey(weekCnt) &&
        homeOfTheWeek[weekCnt][weekDay].isEmpty) {
      homeOfTheWeek[weekCnt][weekDay] = form;
    }
    homeOfTheWeek[weekCnt][weekDay]["todayInfo"] = [today, weekCnt];
    notifyListeners();
  }

  void setMealList(Map<String, List<dynamic>> data) {
    todaySaveMeal['saveCnt'] = data.length;
    todaySaveMeal['saveList'] = data;
    notifyListeners();
  }

  void setBurnCalorie(int data) {
    todayWeightCalories['burnCalorie'] = data;
    notifyListeners();
  } //초기데이터

  void setWeight(int data) {
    todayWeightCalories['weight'] = data;
    notifyListeners();
  } //초기데이터
}

class HomeBoardCalender with ChangeNotifier {
  String selectedDay = "0000-00-00"; //함수에서 변형

  var monthlySummary = <String, List<int>>{
    "savedays": [0, 0],
    "obeyRoutines": [0, 0],
    "averageDailyCalorie": [0, 0],
  };
  var monthlyCalender = []; //api출력 데이터 확인하기

  var selectedDayTrackInfo = ["-", 0]; //트랙명, 일 차
  var selectedDayWeightCalories = <String, int>{
    "takeKacl": 0,
    "burnKacl": 0,
    "weight": 0
  };
  var selectedDayRoutineList = [
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
  ]; //cnt에 따라서 height 길이 변환
  var selectedDaySaveMeal = <String, List<dynamic>>{
    "saveList": [
      ["img", "06 : 03"],
      ["img", "06 : 03"],
      ["img", "06 : 03"],
      ["img", "06 : 03"]
    ]
  };
}

class UserTodayTrack with ChangeNotifier {
  var selectedDay = "0000-00-00"; //함수에서 변형
  var trackInfo = <dynamic>["icon", "-", 0, 0];
  var selectedDayTrackRoutineList = [
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
    ["savetime", "routineNm", true],
  ]; // 선택한 하루의 루틴 리스트(디폴트 : 오늘)
  var trackSubData = <String, List<int>>{
    "water": [0, 0],
    "coffee": [0, 0],
    "cheatingCoupon": [0, 0]
  };
}

//사용자 정보
class User {
  final _storage = const FlutterSecureStorage();
  final _tkKey = 'usertk';
  final _idKey = 'userid';
  final _nmKey = 'usernm';

  Future<void> saveinfo(String token, String nm, int id) async {
    await _storage.write(key: _tkKey, value: token);
    await _storage.write(key: _idKey, value: id.toString());
    await _storage.write(key: _nmKey, value: nm);
  }

  Future<Map<String, dynamic>> getInfo() async {
    String? token = await _storage.read(key: _tkKey);
    String? idString = await _storage.read(key: _idKey);
    String? nm = await _storage.read(key: _nmKey);

    int? id = idString != null ? int.tryParse(idString) : null;

    return {
      'tk': token,
      'id': id,
      'nm': nm,
    };
  }

  Future<void> deleteInfo() async {
    await _storage.delete(key: _tkKey);
    await _storage.delete(key: _idKey);
    await _storage.delete(key: _nmKey);
  }
}

class IsLogined with ChangeNotifier {} //로그인 체크 및 사용자 데이터 세팅

class TrackProvider with ChangeNotifier {
  List<Map<String, dynamic>> _trackList = []; // 빈 리스트로 초기화
  Map<String, dynamic>? _track; // null 값 허용 //안쓸예정 - 작업중

  List<Map<String, dynamic>> get trackList => _trackList;

  Map<String, dynamic>? get track => _track;

  //트랙 리스트 초기 데이터 세팅
  void listInsert(List<Map<String, dynamic>> newTrackList) {
    //초기데이터
    _trackList = newTrackList;
    print(_trackList);
    notifyListeners();
  }

  //트랙 생성시 리스트에 추가_1
  void oneTrackInsert(int tid) {
    Map<String, dynamic> track = {
      "track_id": tid,
      "icon_name": "Melting face",
      "goal_calorie": 0,
      "name": "새로운 식단트랙",
      "using": false
    };

    _trackList.add(track);
    notifyListeners();
  }

  //트랙 생성시 리스트에 추가_2
  void oneTrackInsertNext(Map<String, dynamic> getTrack, int tid) {
    for (var track in _trackList) {
      if (track['track_id'] == tid) {
        track['name'] = getTrack['name'];
        track['icon_name'] = getTrack['icon_name'];
        track['goal_calorie'] = getTrack['goal_calorie'];
        track['using'] = false;
        notifyListeners();
        break;
      }
    }
    print(_trackList);
    notifyListeners();
  }

  //트랙 수정 시 리스트에 업데이트
  void oneTrackUpdate(Map<String, dynamic> getTrack, int tid) {
    for (var track in _trackList) {
      if (track['track_id'] == tid) {
        track['name'] = getTrack['name'];
        track['icon'] = getTrack['icon'];
        track['daily_calorie'] = getTrack['calorie'];
        track['using'] = false;
        break;
      }
    }
    print(_trackList);
    notifyListeners();
  }

  //트랙 삭제
  void removeTrackById(int tid) {
    _trackList.removeWhere((track) => track['track_id'] == tid);
    print(_trackList);
    notifyListeners();
  }
}

//하루에 대한 루틴 리스트
class RoutinListProvider with ChangeNotifier {
  List<Map<String, dynamic>> _routineList = [
    {
      "routine_id": -1,
      "routine_date_id": -1,
      "calorie": 0,
      "weekday": 0,
      "week": 1,
      "time": 1,
      "title": "",
      "clock": "02:59:00.975000"
    }
  ];

  bool _isRoutine = false;

  List<Map<String, dynamic>> get routineList => _routineList;

  bool get isRoutine => _isRoutine;

//루틴 리스트
  void setList(List<Map<String, dynamic>> data) {
    _routineList = data;
    _routineList.insert(0, {}); //index 0인 조건에 루틴 생성 버튼 배치
    _isRoutine = data.isEmpty ? false : true;
    notifyListeners(); // 상태 변경을 알림
  }

  //루틴 리스트 여부
  void setIsRoutine(bool data) {
    _isRoutine = data;
    notifyListeners(); // 상태 변경을 알림
  }

  //루틴 리스트 클리어
  void clear() {
    _routineList = [
      {
        "routine_id": -1,
        "routine_date_id": -1,
        "calorie": 0,
        "weekday": 0,
        "week": 1,
        "time": 1,
        "title": "",
        "clock": "02:59:00.975000"
      }
    ];
    _isRoutine = false;
    notifyListeners(); // 상태 변경을 알림
  }

  //루틴생성으로 리스트에 추가
  void addList(int rid, int rdateid, Map<String, dynamic> data) {
    Map<String, dynamic> getData = {
      "routine_id": rid,
      "routine_date_id": rdateid,
      "calorie": data['calorie'],
      "weekday": data['weekday'],
      "week": data['week'],
      "time": 1, //data['time']가 맞는데 버그라서 1로 하드코딩해둠(수정 필요)
      "title": data['title'],
      "clock": data['clock']
    };
    _routineList.add(getData); //index 0인 조건에 루틴 생성 버튼 배치
    notifyListeners(); // 상태 변경을 알림
  }
}

class TrackTabModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // 상태 변경을 알림
  }
}

class TrackStartDayPickProvider with ChangeNotifier {
  String _monday = "";

  String get monday => _monday;

  List<String> mondays = [];

  void setMonday(int idx) {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    DateTime currentMonday = now.subtract(Duration(days: weekday - 1));
    for (int i = 0; i < 4; i++) {
      DateTime monday = currentMonday.add(Duration(days: 7 * i));
      String formattedMonday = DateFormat('yyyy-MM-dd').format(monday);
      mondays.add(formattedMonday);
    }
    _monday = mondays[idx];
    notifyListeners();
  }
}

//탭구조에 활용하는 주, 데이 정보
class trackDetailTabProvider with ChangeNotifier {
  int _selectedWeek = 1;
  int _selectedDay = 0;

  int get selectedWeek => _selectedWeek;

  int get selectedDay => _selectedDay;

  void setweek(int data) {
    _selectedWeek = data;
    notifyListeners();
  }

  void setDay(int data) {
    _selectedDay = data;
    notifyListeners();
  }
}

//한 트랙 상세정보
class OneTrackDetailInfoProvider with ChangeNotifier {
  String _pageType = "생성";
  Map<String, dynamic> _oneTrackInfo = {
    //초기값 세팅
    "tid": 0,
    "name": "",
    "icon": "Melting face",
    "calorie": 0,
    "track_start_day": null,
    "track_finish_day": null,
    "group_start_day": null,
    "group_finish_day": null,
    "real_finish_day": null,
    "duration": 14,
    "calorie": 0,
    "count": 0,
    "coffee": 0,
    "alcohol": 0,
    "water": 0,
    "cheating_cnt": 0,
    "repeatroutin": [],
    "soloroutin": []
  };

  String get pageType => _pageType;

  Map<String, dynamic> get oneTrackInfo => _oneTrackInfo;

  void setPageType(String type) {
    _pageType = type;
    notifyListeners();
  }

  //생성하기에서 넘어온 경우 초기 세팅
  void setInfoFromCreate(int tid) {
    _oneTrackInfo = {
      //초기값 세팅
      "tid": tid,
      "name": "새로운 식단 트랙",
      "icon": "Melting face",
      "calorie": 0,
      "track_start_day": null,
      "track_finish_day": null,
      "group_start_day": null,
      "group_finish_day": null,
      "real_finish_day": null,
      "duration": 14,
      "calorie": 0,
      "count": 0,
      "coffee": 0,
      "alcohol": 0,
      "water": 0,
      "cheating_cnt": 0,
      "repeatroutin": [],
      "soloroutin": []
    };

    notifyListeners();
  }

  //상세보기에서 넘어온 경우 초기 세팅(리스트에서 클릭 시)
  void setInfoFromDetail(Map<String, dynamic> data) {
    _oneTrackInfo['tid'] = data['track_id'];
    _oneTrackInfo['name'] = "${data['track_name']}";
    _oneTrackInfo['icon'] = "${data['icon']}";
    _oneTrackInfo['calorie'] = data['daily_calorie'] ?? 0;
    _oneTrackInfo['duration'] = data['duration'];
    _oneTrackInfo['water'] = data['water'];
    _oneTrackInfo['coffee'] = data['coffee'];
    _oneTrackInfo['cheating_cnt'] = data['cheating_count'];
    notifyListeners();
  }

//상세보기에서 넘어온 경우 초기 세팅(화면 이동 후 api 데이터 세팅)
  void setInfoFromDetail_GETinfo(Map<String, dynamic> data) {
    //data :
    print("setInfoFromDetail_GETinfo");
    print(data);
    _oneTrackInfo['name'] = "${data['track_name']}";
    _oneTrackInfo['icon'] = "${data['icon']}";
    _oneTrackInfo['calorie'] = data['daily_calorie'] ?? 0;
    _oneTrackInfo['duration'] = data['duration'];
    _oneTrackInfo['water'] = data['water'];
    _oneTrackInfo['coffee'] = data['coffee'];
    _oneTrackInfo['cheating_cnt'] = data['cheating_count'];
    _oneTrackInfo['repeatroutin'] = data['repeatroutin'];
    _oneTrackInfo['soloroutin'] = data['soloroutin'];
    notifyListeners();
  }

  void clear() {
    _oneTrackInfo = {
      "tid": 0,
      "name": "",
      "icon": "Melting face",
      "calorie": 0,
      "track_start_day": today,
      "track_finish_day": today,
      "group_start_day": today,
      "group_finish_day": today,
      "real_finish_day": today,
      "duration": 14,
      "delete": false,
      "alone": true,
      "count": 0,
      "coffee": 0,
      "alcohol": 0,
      "water": 0,
      "cheating_cnt": 0,
      "repeatroutin": [],
      "soloroutin": []
    };

    notifyListeners();
  }

  //아래부터 트랙 수정시에 하나씩 provider에 업데이트하는 함수들
  void settid(int data) {
    print("settid : $data");
    _oneTrackInfo['tid'] = data;
    notifyListeners();
  }

  void setduration(int data) {
    _oneTrackInfo['duration'] = data;
    notifyListeners();
  }

  void setCalorie(int data) {
    _oneTrackInfo['calorie'] = data;
    notifyListeners();
  }

  void setIcon(String data) {
    _oneTrackInfo['icon'] = data;
    notifyListeners();
  }

  void setName(String data) {
    _oneTrackInfo['name'] = data;
    notifyListeners();
  }
}

//달력에서 선택된 일자에 대한 데이터
class CalenderSelectedProvider with ChangeNotifier {
//월마다 바뀌는 데이터
  final Map<String, dynamic> _monthlyInfo = {
    "recordDay": {
      "record_cnt": 0,
      "all_cnt": 31,
    },
    "routine": {
      "success_cnt": 0,
      "all_cnt": 0,
    },
    "avgCalorieOfDay": {
      "save_calorie": 0,
      "goal_calorie": 0,
    },
    "calendar": [
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  };
  final Map<String, dynamic> _dailyInfo = {
    "selectedDay": today, //날짜
    "isTracking": false,
    "selectedDayTrackTitle": {
      "TNm": "", //트랙명
      "TCountingDay": 0 //몇 일차
    }, //트랙명
    "health": {
      "totalCalorie": 0, //이 날의 칼로리
      "goalCalorie": 0, //목표 칼로리
      "saveCalorie": 0, //섭취 칼로리
      "burnCalorie": 0, //소모 칼로리
      "Weight": 0, //몸무게
    },
    "routine": {
      {
        "follow": false, //루틴지킴여부
        "time": "", //시간
        "rNm": "", //루틴명
      },
      {
        "follow": false, //루틴지킴여부
        "time": "", //시간
        "rNm": "", //루틴명
      }
    },
    "save": [] //picture, date
  };

  Map<String, dynamic> get monthlyInfo => _monthlyInfo;

  Map<String, dynamic> get dailyInfo => _dailyInfo;

//[월별데이터] : 기록일
  void setMonthRecordDay(Map<String, dynamic> data) {
    _monthlyInfo['recordDay']['record_cnt'] = data['record_count'];
    _monthlyInfo['recordDay']['all_cnt'] = data['days'];
    notifyListeners();
  }

//[월별데이터] : 지킨 루틴 수
  void setMonthRoutine(Map<String, dynamic> data) {
    _monthlyInfo['calendar'] = data['calendar'];
    _monthlyInfo['routine']['success_cnt'] = data['success_cnt'];
    _monthlyInfo['routine']['all_cnt'] = data['all_cnt'];
    notifyListeners();
  }

//[월별데이터] : 평균 칼로리
  void setAvgCalorie(int data) {
    _monthlyInfo['avgCalorieOfDay']['save_calorie'] = data;
    notifyListeners();
  }

//[월별데이터] : 목표 칼로리
  void setGoalCalorie(int data) {
    _monthlyInfo['avgCalorieOfDay']['goal_calorie'] = data;
    notifyListeners();
  }

//[일별데이터] : 선택한 날짜
  void setSelectedDay(String data) {
    _dailyInfo['selectedDay'] = data;
    notifyListeners();
  }

  //[일별데이터] : 선택한 날짜의 트랙 진행 여부
  void setIsTracking(bool data) {
    _dailyInfo['isTracking'] = data;
    notifyListeners();
  }

//[일별데이터] : 트랙명, 몇 일차
  void setTrackTitle(Map<String, dynamic> data) {
    _dailyInfo['selectedDayTrackTitle']['TNm'] = data;
    _dailyInfo['selectedDayTrackTitle']['TCountingDay'] = data;
    notifyListeners();
  }

//[일별데이터] : 건강정보
  void setHealth(Map<String, dynamic> data) {
    _dailyInfo['health']['totalCalorie'] =
        data['todaycalorie'] == null ? 0 : data['todaycalorie'];
    _dailyInfo['health']['goalCalorie'] =
        data['goalcalorie'] == null ? 0 : data['goalcalorie'];
    _dailyInfo['health']['saveCalorie'] =
        data['nowcalorie'] == null ? 0 : data['nowcalorie'];
    _dailyInfo['health']['burnCalorie'] =
        data['burncalorie'] == null ? 0 : data['burncalorie'];
    _dailyInfo['health']['Weight'] =
        data['weight'] == null ? 0 : data['weight'];
    notifyListeners();
  }

//[일별데이터] : 식단 기록 리스트
  void setSave(List<Map<String, String>> data) {
    _dailyInfo['save'] = data;
    notifyListeners();
  }
}

//한 루틴상세정보(비우고 사용하고 비우고 사용하고 함)
class OneRoutineDetailInfoProvider with ChangeNotifier {
  String _pageType = "생성";
  Map<String, dynamic> _oneRoutineInfo = {
    //초기값 세팅
    "rid": 0,
    "rdateid": 0,
    "title": "새로운 루틴",
    "clock": "01:00:00.975Z",
    "weekday": "월",
    "time": "아침",
    "calorie": 100,
    "repeat": true,
    "alarm": true
  };

  String get pageType => _pageType;

  Map<String, dynamic> get oneRoutineInfo => _oneRoutineInfo;

  void setPageType(String type) {
    _pageType = type;
    notifyListeners();
  }

  //상세보기에서 넘어온 경우 초기 세팅 리스트에서 클릭 후, api 호출 res데이터
  void setInfoFromDetail(Map<String, dynamic> data, int rid, int rdateid) {
    print("setInfoFromDetail");
    print(data);
    print(rid);
    print(rdateid);
    _oneRoutineInfo['rid'] = rid;
    _oneRoutineInfo['rdateid'] = rdateid;
    _oneRoutineInfo['title'] = data['title'];
    _oneRoutineInfo['clock'] = data['clock'];
    _oneRoutineInfo['weekday'] = data['weekday'];
    _oneRoutineInfo['time'] = data['time'];
    _oneRoutineInfo['calorie'] = data['calorie'];
    _oneRoutineInfo['repeat'] = data['repeat'];
    _oneRoutineInfo['alarm'] = data['alarm'];
    notifyListeners();
  }

  void clear() {
    _oneRoutineInfo = {
      //초기값 세팅
      "rid": 0,
      "rdateid": 0,
      "title": "새로운 루틴",
      "clock": "01:00:00.975Z",
      "weekday": "월",
      "time": "아침",
      "calorie": 100,
      "repeat": true,
      "alarm": true
    };
    _pageType = "생성";
    notifyListeners();
  }

  String hour = "00";
  String minute = "00";

  //[루틴 수정] 루틴명
  void setRoutineNm(String data) {
    _oneRoutineInfo['title'] = data;
    notifyListeners();
  }

  //[루틴 수정] 루틴명
  void setColock(String type, int value) {
    switch (type) {
      case "hour":
        {
          String formatHour = value <= 9 ? "0${value}" : "${value}";
          hour = "$formatHour";
        }
      case "minute":
        {
          String formatMinute = value <= 9 ? "0${value}" : "${value}";
          minute = formatMinute;
        }
    }
    _oneRoutineInfo['clock'] = "$hour:$minute:00.975Z";
    print(_oneRoutineInfo['clock']);
    notifyListeners();
  }
}

//달력에서 선택된 일자에 대한 데이터
class RunningTrack with ChangeNotifier {
  String _startDate = "";
  int _tid = -1;
  int _goalCalorie = 0;

  String get startDate => _startDate;

  int get goalCalorie => _goalCalorie;

  int get tid => _tid;

// void setPageType(String type){
//   _pageType = type;
//   notifyListeners();
// }
}


//무스 분석 후 한 음식에 대한 디테일provider
class OneFoodDetail with ChangeNotifier {
  Map<String, dynamic> _foodInfo = {
    "file_path": "",  //url 경로 형태
    "food_info": {
      "name": "String",
      "date": "String",          // 분초까지
      "heart": false,
      "carb": 0.0,
      "protein": 0.0,
      "fat": 0.0,
      "calorie": 0.0,
      "unit": "gram",
      "size": 0.0,
      "daymeal_id": -1
    },
    "image_url": "String"  //[image_url 주의 필요] String일 경우에 api호출이 비정상이거나 비어있는 상태로 판단 후 화면을 다르게 보이는 부분이 있음
  };
  // html.File? _file;
  bool _moosesuc = false;

  Map<String,dynamic> get foodInfo => _foodInfo;
  // html.File? get file=>_file;
  bool get moosesuc => _moosesuc;
  //provider 비우기
  void clear(){
    _foodInfo = {
      "file_path": "",
      "food_info": {
        "name": "String",
        "date": "String",
        "heart": false,
        "carb": 0.0,
        "protein": 0.0,
        "fat": 0.0,
        "calorie": 0.0,
        "unit": "gram",
        "size": 0.0,
        "daymeal_id": -1
      },
      "image_url": "String"
    };
    // _file = null;
    _moosesuc = false;
  notifyListeners();
  }


  //provider에 데이터 세팅
  void setInfo(Map<String,dynamic> data){
    _foodInfo = data;
    notifyListeners();
  }
//provider에 파일 데이터 세팅(식단 등록이 아닌 무스에서 오는 경우 파일을 Provider에 저장하고 페이지 이동 후 API 요청을 보냄)
//   void setfile(html.File? data){
//     _file = data;
//     notifyListeners();
//   }
  void setMooseSuc(bool res){
    _moosesuc = res;
    notifyListeners();
  }
}


//달력에서 선택된 일자에 대한 데이터
class MealSaveProvider with ChangeNotifier {
  String _selectedTime = "시간대";
  String _text = "";
  String get selectedTime => _selectedTime;
  String get text => _text;


  void setTime(String data){
    _selectedTime= data;
    notifyListeners();
  }
  void setText(String data){
    _text= data;
    notifyListeners();
  }
}
