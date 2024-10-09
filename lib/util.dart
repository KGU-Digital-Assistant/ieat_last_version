
//화면 길이로 가로 길이 비율 가져오기
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:intl/intl.dart';

String today = getCurrentDateAsString();
String todayStrkr = getCurrentDateAsStringkr();
List<String> timeList = ['아침','아점','점심','점저','저녁','야식','간식'];
// List<String> mealSaveHintText = ['오랜만에 먹는 카레라이스','',''];

var dio = Dio();



void setupDio() {
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print(
          'REQUEST[${options.method}] => PATH: ${options.path} => DATA: ${options.data}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
      return handler.next(response);
    },
    onError: (DioError error, handler) {
      print(
          'ERROR[${error.response?.statusCode}] => DATA: ${error.response?.data}');
      return handler.next(error);
    },
  ));
}

//오늘 날짜 출력
String getCurrentDateAsString() {
  // 현재 날짜와 시간을 가져옴
  DateTime now = DateTime.now();

  // 날짜를 문자열로 포맷
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);

  return formattedDate;

}
//오늘 날짜 출력
String getCurrentDateAsStringkr() {
  // 현재 날짜와 시간을 가져옴
  DateTime now = DateTime.now();

  // 날짜를 문자열로 포맷
  String formattedDate = DateFormat('yyyy년 MM월 dd일').format(now);

  return formattedDate;

}
//이번 주 날짜 출력 int 넣으면 그 날의 date(yyyy-mm-dd)출력 > 하단 getTodayWeekday()참고
String getDateOfWeek(int day) {
  // 현재 날짜와 시간을 가져옴
  DateTime now = DateTime.now();
  // 입력된 day가 유효한 요일인지 확인
  int difference = (day+1) - now.weekday;

  // 현재 날짜에서 차이만큼 더하거나 뺌
  DateTime targetDay = now.add(Duration(days: difference));

  // 날짜를 문자열로 포맷 (yyyy-MM-dd 형식)
  String formattedDate = DateFormat('yyyy-MM-dd').format(targetDay);
  return formattedDate;
}


//String(yyyy-mm-dd) 넣으면 년도와 월을 List<int>로 반환
List<int> getYearAndMonth(String date) {
  // 날짜 문자열을 '-'로 분리
  List<String> parts = date.split('-');

  // 년도와 월을 정수로 변환하여 리스트에 저장
  int year = int.parse(parts[0]);
  int month = int.parse(parts[1]);

  return [year, month];
}

// 이번 주 월요일 구하기
String getMondayOfCurrentWeek(DateTime date) {
  // date의 요일을 가져옴 (0: 일요일, 1: 월요일, ..., 6: 토요일)
  int weekday = date.weekday;

  // date에서 요일(weekday) 만큼 빼면 이번 주 월요일이 됨
  DateTime monday = date.subtract(Duration(days: weekday - 1));
  String formattedDate = DateFormat('MM월 dd일').format(monday);
  return formattedDate;
}

// 주차를 더해서 다음 주 월요일 계산
List<String> getMondaysForNextWeeks() {
  DateTime now = DateTime.now();
  int weekday = now.weekday;
  DateTime currentMonday = now.subtract(Duration(days: weekday - 1));

  List<String> mondays = [];

  // 이번 주, 다음 주, 다다음 주, 다다다음 주 월요일의 날짜를 계산
  for (int i = 0; i < 4; i++) {
    DateTime monday = currentMonday.add(Duration(days: 7 * i));
    String formattedMonday = DateFormat('MM월 dd일').format(monday);
    mondays.add(formattedMonday);
  }
  mondays.removeAt(0);  //이번주 선택불가하게 함
  return mondays;
}
//Moose에서 받은 데이터를 2024-06-27T07:30:00 오전 7시 30분 형태로 변환
String formattMooseDate(String dateTimeString){
  DateTime dateTime = DateTime.parse(dateTimeString);

  //시간 구하기
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  String period = hour >= 12 ? "오후" : "오전";
  hour = hour % 12 == 0 ? 12 : hour % 12;

  return '$period $hour시 ${minute}분';
}


String extractLastTwoChars(String input) {
  return input.substring(input.length - 2);
}


double getWidthRatioFromScreenSize(BuildContext context, double percentage) {
  double screenWidth = MediaQuery.of(context).size.width;
  double containerWidth = screenWidth * percentage;
  return containerWidth;
}

//화면 길이로 새로 길이 비율 가져오기
double getHeightRatioFromScreenSize(BuildContext context, double percentage) {
  double screenWidth = MediaQuery.of(context).size.height;
  double containerWidth = screenWidth * percentage;
  return containerWidth;
}



//메인화면 도넛차트(util.dart)
class PieModel {
  final int count;
  final Color color;
  final double thickness; // 추가된 두께 속성

  PieModel( {required this.count, required this.color,required  this.thickness});

}

//페이지 이동 함수(context, 이동할 페이지)
void NvgToNxtPage(BuildContext context, Widget nextPage) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => nextPage),
  );
}

//페이지 이동 함수 - 애니메이션 적용(context, 이동할 페이지)
void NvgToNxtPageSlide(BuildContext context, Widget nextPage){
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 슬라이드 애니메이션
        const begin = Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}

var repeatDayBoolList_Str = ["일", "월", "화", "수", "목", "금", "토"];
var repeattimeBoolList_Str = [
  "아침",
  "아점",
  "점심",
  "점저",
  "저녁",
  "야식",
  "오전간식",
  "오후간식"
];


String getIconNm(trackIconIdx){
  String trackIconNm="";
  switch (trackIconIdx) {
    case 0:
      trackIconNm = "Melting face";
      break; // 케이스 1에 대한 처리가 끝나면 탈출
    case 1:
      trackIconNm = "Cat with wry smile";
      break; // 케이스 2에 대한 처리가 끝나면 탈출
    case 2:
      trackIconNm = "Disguised face";
      break; // 케이스 3에 대한 처리가 끝나면 탈출
    case 3:
      trackIconNm = "Dotted line face";
      break; // 케이스 3에 대한 처리가 끝나면 탈출
    case 4:
      trackIconNm = "Speak-no-evil monkey";
      break; // 케이스 3에 대한 처리가 끝나면 탈출
    case 5:
      trackIconNm = "Pink heart";
      break; // 케이스 3에 대한 처리가 끝나면 탈출
    case 6:
      trackIconNm = "Black heart";
      break; // 케이스 3에 대한 처리가 끝나면 탈출
    default:
      trackIconNm = "Melting face"; // 예상치 못한 값에 대한 처리
  }
  return trackIconNm;
}

String formatNumberWithComma(int number) {
  // 숫자를 문자열로 변환
  String numberString = number.toString();

  // 결과를 저장할 버퍼를 생성
  StringBuffer buffer = StringBuffer();

  int length = numberString.length;
  int start = length % 3; // 처음 몇 자리는 쉼표가 없을 경우

  if (start > 0) {
    buffer.write(numberString.substring(0, start));
    if (length > 3) {
      buffer.write(',');
    }
  }

  // 3자리씩 처리
  for (int i = start; i < length; i += 3) {
    buffer.write(numberString.substring(i, i + 3));
    if (i + 3 < length) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}
void bottomSheetType300(BuildContext context, Widget wg) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(
              color: ColorMainBack,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(0xFFE6E6E6),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(10.0),
            width: getWidthRatioFromScreenSize(context, 1),
            height: 300,
            child: wg);
      }).then((_) {
    // 모달이 닫힌 후 호출할 함수
    bottomShow(context); // 호출할 함수 이름
  });
}

void bottomSheetType500(BuildContext context, Widget wg) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(
              color: ColorMainBack,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(0xFFE6E6E6),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(10.0),
            width: getWidthRatioFromScreenSize(context, 1),
            height: 500,
            child: wg);
      }).then((_) {
    // 모달이 닫힌 후 호출할 함수
    bottomShow(context); // 호출할 함수 이름
  });
}

void bottomSheetType90per(BuildContext context, Widget wg) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(
              color: ColorBackGround,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(0xFFE6E6E6),
                width: 1,
              ),
            ),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
            width: getWidthRatioFromScreenSize(context, 1),
            height: getHeightRatioFromScreenSize(context,0.96),
            child: wg);
      }).then((_) {
    Navigator.pop(context);
  });
}


//오늘 월화수목금토일 int 출력 (요일)
int getTodayWeekday() {
  DateTime now = DateTime.now(); // 현재 날짜와 시간 가져오기
  List<String> weekdays = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일'
  ];

  return now.weekday - 1;
}
//오늘 월화수목금토일 String 출력
String getTodayWeekdayStr() {
  DateTime now = DateTime.now(); // 현재 날짜와 시간 가져오기
  List<String> weekdays = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일'
  ];

  return weekdays[now.weekday - 1];
}


//식단 기록
String getNowTime() {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('hh : mm a').format(now);
  return formattedTime;
}






Future<void> simpleAlert(String text) async {
  Get.defaultDialog(
    title: "",
    content: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Get.back(); // 다이얼로그 닫기
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
          child: Text('닫기', style: Text14BlackBold),
        ),
      ],
    ),
    barrierDismissible: false, // 바깥 영역 클릭 시 닫히지 않도록 설정
    backgroundColor: Colors.white, // 다이얼로그 배경색
    radius: 10, // 모서리 둥글기
  );
}


Future<void> simpleAlert2Pop(String text) async {
  Get.defaultDialog(
    title: "",
    content: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Get.back(); // 다이얼로그 닫기
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
          child: Text('닫기', style: Text14BlackBold),
        ),
      ],
    ),
    barrierDismissible: false, // 바깥 영역 클릭 시 닫히지 않도록 설정
    backgroundColor: Colors.white, // 다이얼로그 배경색
    radius: 10, // 모서리 둥글기
  );
}



void popWithSlideAnimation(BuildContext context, int cnt) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Container(), // 빈 페이지를 사용하여 애니메이션만 적용
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 반대 슬라이드 애니메이션
      const begin = Offset.zero;
      const end = Offset(1.0, 0.0); // 왼쪽에서 오른쪽으로
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 300), // 애니메이션 속도 조절
  ));

  // 실제로 pop을 호출하여 페이지를 뒤로 이동
  Future.delayed(Duration(milliseconds: 100), () {
    for(int a = 0; a < cnt ; a++){
      Navigator.pop(context);
    }
  });
}