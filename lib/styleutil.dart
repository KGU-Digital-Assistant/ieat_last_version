import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/provider.dart';

/*컬러*/

//아이잇 로고에 사용된 컬러
const Color priColorD9D9D9 = Color(0xFFD9D9D9);
const Color priColorC9FF80 = Color(0xFFC9FF80);
const Color priColor4FCCD8 = Color(0xFF4FCCD8);
const Color priColor1BAF79 = Color(0xFF1BAF79);
const Color priColor20C387 = Color(0xFF20C387);
//배경색
const Color ColorMainBack = Color(0xFFffffff);
const Color ColorBackGround = Color(0xFFF3F3F3);
const Color ColorBlack = Color(0xFF000000);
const Color ColorMainStroke = Color(0xFFD8D8D8);
const Color colorMainBolder = Color(0xFFCDCFD0);
const Color mainGrey = Color(0xff818181);
const Color mainBlack = Color(0xff464646);
const Color mainGreen = Color(0xff1CAB1C);


const Color Color33FF33 = Color(0xFF33FF33);
const Color Color078C03 = Color(0xFF078C03);
const Color Color0ABF04 = Color(0xFF0ABF04);
const Color Color191919 = Color(0xFF191919);
const Color ColorEAF57C = Color(0xFFEAF57C);
const Color Color50B450 = Color(0xFF50B450);
const Color ColorCBD2BD = Color(0xFFCBD2BD);
const Color Colorf5f5f7 = Color(0xFFf5f5f7);
Color Color1BAF79 = Color(0xFF1BAF79);

const Color settingBackGround = Color(0xFFE6E6E6);
const Color Colorkakao = Color(0xFFF9E000);
const Color ColorMealMainBodyBack = Color(0xFFD8D8D8);

var Text10 = TextStyle(fontSize: 10);
var Text10Black =  TextStyle(fontSize: 10, color: Colors.black);
var Text10BoldBlack = TextStyle(fontSize: 10,fontWeight: FontWeight.bold, color: Colors.black);
var Text17 = TextStyle(fontSize: 17);
var TextBold = TextStyle(fontWeight: FontWeight.bold);
var Text13_5Bold = TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold);
var Text15Bold = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: mainBlack);
var Text15BoldGrey = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey);

var Text15BoldPriGreen = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: priColor1BAF79);
var Text16Bold = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
var Text16BoldBlack = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainBlack);
var Text16BoldWhite = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
var Text17Bold = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
var Text17BoldBlack = TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: mainBlack);
var Text17Boldwhite = TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white);
var Text17BoldGrey = TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.grey);
var Text18Bold = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
var Text25BoldPriGreen = TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: priColor1BAF79);
var Text20Bold = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
var Text20w600white = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);
var Text20BoldBlack = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainBlack);
var Text20BoldGrey = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey);

var Text22BoldBlack = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black);
var Text23w600white = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);

var Text24BoldBlack = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainBlack);
var Text25 = TextStyle(fontSize: 25);
var Text25Bold = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
var Text25BoldBlack = TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black);
var Text35Bold = TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: mainBlack);
var TextTitle =
TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold);
var TextTrackNm = TextStyle(color: priColor1BAF79, fontSize: 25, fontWeight: FontWeight.bold);
var TextTrackNm_40 = TextStyle(color: priColor1BAF79, fontSize: 40, fontWeight: FontWeight.bold);
var TextRoutineNm_40 = TextStyle(color: priColor1BAF79, fontSize: 40, fontWeight: FontWeight.bold);
var TextTrackSmall = TextStyle(color: priColor1BAF79, fontSize: 15, fontWeight: FontWeight.bold);

var TextSubTitle =
TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
var TextMealMainCal = TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold);


var redAlertText = TextStyle(color: Colors.red, fontSize: 14);
var OutlinedButtonTextSty_1 = TextStyle(color: Colors.black, fontSize: 17);


var Text14Black = TextStyle(color: mainBlack, fontSize: 14);
var Text14BlackBold = TextStyle(color: mainBlack, fontSize: 14, fontWeight: FontWeight.bold);

var TextHomeNuTitle = TextStyle(
  color: mainBlack, // 폰트 색상
  fontFamily: 'IBMPlexSansKR',
  fontSize: 27,
  fontWeight: FontWeight.bold,
);


//캘린더 오늘 날짜
var TextCalenderToday = TextStyle(
  fontSize: 20, // 폰트 크기 조정
  fontWeight: FontWeight.bold, // 필요 시 굵게
);

//캘린더 월별데이터 타이틀
var TextCalenderMonthlyInfoTitle = TextStyle(
  color : mainGrey,
  fontSize: 10,
  letterSpacing: 0.0,
  fontWeight: FontWeight.bold,
);


var OutlinedButton_borderGrey = OutlinedButton.styleFrom(
    side: BorderSide(width: 1, color: Colors.black),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));

//버튼 스타일 : 알림창에서 사용, 흰색
var OutBtnSty_alert = OutlinedButton.styleFrom(
    backgroundColor: priColorD9D9D9,
    padding:
    EdgeInsets.symmetric(horizontal: 13, vertical: 0),
    side: BorderSide(width: 1, color: settingBackGround),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)),
    minimumSize: Size(double.maxFinite, 50));

//버튼 스타일 : 좌우 길게 , 회색
var OutBtnSty = OutlinedButton.styleFrom(
    backgroundColor: priColorD9D9D9,
    padding:
    EdgeInsets.symmetric(horizontal: 13, vertical: 0),
    side: BorderSide(width: 1, color: settingBackGround),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)),
    minimumSize: Size(double.maxFinite, 65));


//버튼 스타일 : 좌우 길게 , 흰색
var OutBtnSty_white = OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    padding:
    EdgeInsets.symmetric(horizontal: 13, vertical: 0),
    side: BorderSide(width: 1, color: Colors.black,),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)),
    minimumSize: Size(double.maxFinite, 65));

//버튼 스타일 : 좌우 길게 , 흰색
var OutBtnSty_black = OutlinedButton.styleFrom(
    backgroundColor: Colors.black,
    padding:
    EdgeInsets.symmetric(horizontal: 13, vertical: 0),
    side: BorderSide(width: 1, color: Colors.black),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)),
    minimumSize: Size(double.maxFinite, 65));







/*입력칸*/

//입력칸 밑줄 제거
var textFieldRemoveUnderline = InputDecoration(
  border: InputBorder.none,
);

var cheatingImg = Image.asset(
'cheating_icon.png',
width: 126, // 너비
height: 33, // 높이
fit: BoxFit.cover, // 이미지가 지정된 크기에 맞게 잘리거나 확대됨
);






Widget suc500_1(BuildContext context) => Container(
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
      Text("성공적으로 저장하였습니다.", style: Text25BoldBlack,),
      SizedBox(height: 40),
      Center(
        child: SizedBox(
          width: 340,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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



Widget fail500_1(BuildContext context) => Container(
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
      Text("오류가 발생하였습니다.", style: Text25BoldBlack,),
      SizedBox(height: 40),
      Center(
        child: SizedBox(
          width: 340,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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