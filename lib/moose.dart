
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ieat/init.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

/**
 * loadingMoose() : 사진 촬영 후 로딩 화면(he 500)
 * Moose() : 무스 화면 총체[Camera(),SearchMeal()]
 * */



class Moose extends StatefulWidget {
  const Moose({super.key});

  @override
  State<Moose> createState() => _MooseState();
}

class _MooseState extends State<Moose>  with SingleTickerProviderStateMixin {
  late AnimationController _modeController;
  late Animation<double> _modeAnimation;
  late Animation<double> _modeLeftPageAnimation;
  late Animation<double> _modeRightPageAnimation;
  bool _isMoved = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _modeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _modeAnimation = Tween<double>(begin: 0, end: 78).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _modeLeftPageAnimation = Tween<double>(begin: 0, end: -1000).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
    _modeRightPageAnimation = Tween<double>(begin: 1000, end: 0).animate(
      CurvedAnimation(parent: _modeController, curve: Curves.easeInOut),
    );
  }

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
    return Scaffold(
      body: SizedBox(
        width:  MediaQuery.sizeOf(context).width,
        height:  MediaQuery.sizeOf(context).height,
        child: Stack(
          children: [
            Stack(
              children: [
                Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _modeLeftPageAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_modeLeftPageAnimation.value, 0),
                          child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                width:  MediaQuery.sizeOf(context).width,
                                height:  MediaQuery.sizeOf(context).height,
                                child: const Camera(),
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
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                width:  MediaQuery.sizeOf(context).width,
                                height:  MediaQuery.sizeOf(context).height,
                                child: const SearchMeal(),
                              )),
                        );
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(padding:
                  EdgeInsets.all(5),
                      child: IconButton(
                        onPressed: () {
                          bottomShow(context);
                        },
                        icon: Icon(Icons.chevron_left, size: 30,color: mainBlack,),
                      )),
                ),
      SizedBox(
        width:  MediaQuery.sizeOf(context).width,
        height:  MediaQuery.sizeOf(context).height,
                child : Padding(
                  padding: EdgeInsets.only(
                    bottom: getHeightRatioFromScreenSize(context, 0.02),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child:Stack(
                      children: [
                        Container(
                          height: 60,
                          width: 150,
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
                                    height: 54,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD0FFCF),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  )),
                            );
                          },
                        ),
                        Container(
                          height: 60,
                          width: 150,
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
                                  "촬영",
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
                                    "검색",
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
      )
              ],
            )
          ],
        ),
      )
    );
  }
}


Widget loadingMoose(BuildContext context) {
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context);
    bottomSheetType90per(context, newMealSave(context));
  });

  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width*0.6,
          height: MediaQuery.of(context).size.width*0.6,
          child: Image.asset('assets/pixcap/gifs/waves.gif', fit: BoxFit.cover,),
        ),
        Text("무스가 음식을 스캔하고 있어요.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        Text("잠시만 기다려 주세요.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 280,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.fromLTRB(10, 5, 10, 5),
                ),
                minimumSize: MaterialStateProperty.all<ui.Size>(
                  ui.Size(40, 40),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.white, // ColorMainBack에 해당하는 색으로 변경
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
                    "취소",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    ),
  );
}
Widget newMealSave(BuildContext context){
  bottomHide(context);
  return Consumer<OneMealDetailInfoProvider>(
    builder : (context,pv,child){
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorBackGround,
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: 50,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.chevron_left, size: 40),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            '새로운 식단 등록',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Container(
                  height: 60,
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Row(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                          width: 30,
                          child: Image.asset(
                            'assets/pixcap/gifs/Laptop3D.gif',
                            fit: BoxFit.cover,
                          )),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "${getNowTime()}",
                              style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text("닉네임",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
                SizedBox(height: 7),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    // shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'assets/test/${pv.mealInfo['img']}.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 50,
                          decoration: BoxDecoration(
                              color: ColorBackGround,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Color(0xFFE6E6E6),
                                width: 1,
                              )),
                          child: Image.network(
                            'image_url',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text("name")
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: ColorMainBack,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Color(0xFFE6E6E6),
                                  width: 1,
                                )),
                            child: Icon(
                              Icons.add,
                              size: 30,
                            )),
                        Text("")
                      ],
                    )
                  ],
                ),
                SizedBox(height: 15),
                Expanded(
                    child: Container(
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: '문구 작성',
                            hintStyle: TextStyle(
                              color: Colors.grey, // 힌트 텍스트 색상
                              fontSize: 16, // 힌트 텍스트 크기
                              fontWeight: FontWeight.bold, // 힌트 텍스트 두께
                            ),
                            border: InputBorder.none, // 모든 테두리 제거
                          ),
                          keyboardType: TextInputType.text,
                        ))),
              ],
            )
          ),
          Container(
            decoration: BoxDecoration(
              color: ColorBackGround,
            ),
            padding: EdgeInsets.all(10),
            child: SizedBox(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.fromLTRB(10, 5, 10, 5),
                  ),
                  minimumSize: MaterialStateProperty.all<ui.Size>(
                    ui.Size(90, 55),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    priColor1BAF79,
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
                onPressed: () async{
                  await simpleAlert("오류가 발생하였습니다.");
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('등록', style: Text16BoldWhite),
              ),
            ),
          )
        ],
      );
    }
  );
}





class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}
class _CameraState extends State<Camera> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container( //카메라
          width:  MediaQuery.sizeOf(context).width,
          height:  MediaQuery.sizeOf(context).height,
          color: Colors.amberAccent,
        ),
        Align(  //stack으로 텍스트 및 버튼 배치
            alignment: Alignment.topCenter,
            child: Container(
              width:  MediaQuery.sizeOf(context).width,
              height:  MediaQuery.sizeOf(context).height,
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(height: getHeightRatioFromScreenSize(context, 0.08),),
                  // Text("무엇이든 스캔 가능!", style: Text10w500Grey),
                  // Text("너의 영양소가 궁금해!", style: Text20BoldGrey),
                  // SizedBox(height: getHeightRatioFromScreenSize(context, 0.58)),
                  SizedBox(height: getHeightRatioFromScreenSize(context, 0.67)),
                  ElevatedButton(
                      onPressed: (){simpleAlert("사진 촬영");},
                      style :  ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(0),
                        ),
                        minimumSize: MaterialStateProperty.all<ui.Size>(
                          ui.Size(65, 65),
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
                            borderRadius: BorderRadius.circular(48),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                      ),
                      child: Icon(Icons.document_scanner,size: 30,color: Color(0xff20C387),)),
                  SizedBox(height: 15),
                ],
              ),
            )
        ),
      ],
    );
  }
}



class SearchMeal extends StatefulWidget {
  const SearchMeal({super.key});
  @override
  State<SearchMeal> createState() => _SearchMealState();
}
class _SearchMealState extends State<SearchMeal> {
  TextEditingController _searchTextController = TextEditingController();
  bool isSearchTextonChanged = false;
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("식단검색", style: Text14BlackBold,),
      ),
      body: Container(
        width:  MediaQuery.sizeOf(context).width,
        height:  MediaQuery.sizeOf(context).height,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: getWidthRatioFromScreenSize(context, 0.95),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xffF2F4F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xffF2F4F5),
                      width: 1,
                    ),
                  ),
                ),
                Container(
                  width: getWidthRatioFromScreenSize(context, 0.95),
                  height: 40,
                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,size: 20),
                      Expanded(child: Padding(padding: EdgeInsets.only(
                          left: 5,
                          bottom: 20
                      ),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.grey, // 힌트 텍스트 색상
                            fontSize: 16, // 힌트 텍스트 크기
                            fontWeight: FontWeight.w500, // 힌트 텍스트 두께
                          ),
                          controller: _searchTextController,
                          decoration: InputDecoration(
                            hintText: '음식이름을 입력해주세요',
                            hintStyle: TextStyle(
                              color: Colors.grey, // 힌트 텍스트 색상
                              fontSize: 16, // 힌트 텍스트 크기
                              fontWeight: FontWeight.w500, // 힌트 텍스트 두께
                            ),
                            border: InputBorder.none, // 모든 테두리 제거
                          ),
                          onChanged: (value){
                            setState(() {
                              _isloading = true;
                            });
                          },
                          keyboardType: TextInputType.number,
                        ),))
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(child: SingleChildScrollView(
              child:_isloading
              ? Container(
                width:  MediaQuery.sizeOf(context).width,
                height:  MediaQuery.sizeOf(context).height,
                child : Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: getWidthRatioFromScreenSize(context, 0.1)
                    ),
                    child: CircularProgressIndicator(),
                  )
                )
              )
              : Container(
                width:  MediaQuery.sizeOf(context).width,
                height:  MediaQuery.sizeOf(context).height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(14, 15, 10, 5),
                      child: Text("최근 검색한 음식",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff818181),
                          fontWeight: FontWeight.bold,
                        ),),),
                    Column(
                      children: List.generate(1,
                              (idx) => Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.fromLTRB(0, 5, 15, 5),
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
                                  Size(getWidthRatioFromScreenSize(context, 0.95), 60),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorMainBack, // 버튼 배경색
                                ),
                                elevation: MaterialStateProperty.all<double>(2),
                                shadowColor: MaterialStateProperty.all<Color>(mainBlack.withOpacity(0.5)),
                                shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Color(0xffCDCFD0), // 테두리 색상
                                      width: 1, // 테두리 두께
                                    ),
                                  ),
                                ),
                                overlayColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent, // hover 색상 제거
                                ),
                              ),
                              onPressed: () {},
                              child: SizedBox(
                                width: getWidthRatioFromScreenSize(context, 0.86),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                                  children: [
                                    Text("음식명", style: Text16BoldBlack),
                                    Text("음식정보", style: Text14w500Grey),
                                  ],
                                ),
                              ),
                            )
                              )),
                    )
                  ],
                ),
              ),
            ))
          ],
        ),
      )
    );
  }
}
