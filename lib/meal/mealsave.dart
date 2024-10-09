import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ieat/moose.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../constants.dart';

class MealSave extends StatefulWidget {
  const MealSave({super.key,this.type});

  final type;
  @override
  State<MealSave> createState() => _MealSaveState();
}

class _MealSaveState extends State<MealSave> {
  TextEditingController _textController = TextEditingController();
  String? nnm;
  bool _loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsyncFunctions();
  }

  Future<void> initAsyncFunctions() async {
    String? nickname = await getNickNm();
    setState(() {  nnm = nickname;  });
  }

  //음식 등록 api
  Future<void> mealSave_POST(BuildContext context) async {
    final mpv = Provider.of<MealSaveProvider>(context,listen: false);
    final opv = Provider.of<OneFoodDetail>(context,listen: false);
    if(opv.foodInfo['image_url'] == "String") return simpleAlert("오류가 발생하였습니다.");
    setupDio();
    String? tk = await getTk();
    String funcname = 'mealSave_POST';
    print('$funcname - 요청시작');
    print('${opv.foodInfo['image_url']}');
    print('${opv.foodInfo['food_info']}');
    print('${mpv.text}');
    DateTime now = DateTime.now();

    int hour = now.hour;
    int minute = now.minute;
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');
    print('$hour$minute');

    String uri = '$url/meal_hour/register_meal/$today${mpv.selectedTime}/$formattedHour$formattedMinute';
    try {
      final response = await dio.request(
        uri,
        options: Options(
          method: 'POST',
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $tk'},
          validateStatus: (status) {
            print('$funcname : $status');
            return status! < 500;
          },
        ),
        data: {
          "file_path" : "${opv.foodInfo['image_url']}",
          "food_info" : "${opv.foodInfo['food_info']}",
          "text" : "null"
        }
      );
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _loading = false;
        });
        popWithSlideAnimation(context, 2);
      } else if (response.statusCode == 401) {
        setState(() {
          _loading = false;
        });
        simpleAlert("로그인을 다시 진행해주세요.");
      } else {
        setState(() {
          _loading = false;
        });
        simpleAlert("오류가 발생하였습니다.");
      }
    } catch (e) {
// 오류 처리
      print('$funcname Error: $e');
      simpleAlert("오류가 발생하였습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Consumer<OneFoodDetail>(
        builder: (context,pv,child){
          return Stack(
            children: [
              Scaffold(
                  appBar: AppBar(
                    scrolledUnderElevation: 0,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: Text(
                      "식단 등록",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        pv.clear();
                      },
                      icon: Icon(Icons.chevron_left, size: 30),
                    ),
                  ),
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
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
                                            child: Text("$nnm",
                                                style: Text14BlackBold),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                                ),
                                pv.foodInfo['image_url'] !="String"
                                    ?Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                    // shape: BoxShape.circle,
                                  ),
                                  child: Image.network(
                                    '${pv.foodInfo['image_url']}',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    :SizedBox(),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: mainGrey.withOpacity(0.1)
                                                )
                                            ),
                                            SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Center(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 30,
                                                    color: mainBlack,
                                                  ),
                                                  style: ButtonStyle(
                                                    overlayColor: MaterialStateProperty.all<Color>(
                                                      Colors.transparent,
                                                    ),
                                                  ),
                                                  onPressed: (){
                                                    pv.foodInfo['image_url'] == "String"
                                                        ?NvgToNxtPageSlide(context, MealSaveCamera())
                                                        :simpleAlert("현재는 한 개의 음식 등록만 지원하고 있습니다.");
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Text("")
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    pv.foodInfo['image_url'] =="String" //한 식단만 등록 가능하게 제어함(추후 변경가능성 있음)
                                        ? SizedBox()
                                        :Column(
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
                                            '${pv.foodInfo['image_url']}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text('${pv.foodInfo['food_info']['name']}', style: Text14Black,)
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE6E6E6),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: TextButton(
                                        onPressed: (){
                                          bottomSheetType500(context, select_MealSave_Time(context));
                                        },
                                        child: Consumer<MealSaveProvider>(
                                          builder: (context,pv,child){
                                            return Text(pv.selectedTime, style: Text14BlackBold,);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                    constraints: BoxConstraints(
                                      minHeight: 170, // 최소 높이
                                    ),
                                    padding:const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:const Color(0xFFE6E6E6),
                                      borderRadius: BorderRadius.circular(30),),
                                    child: Stack(
                                      children: [
                                        TextField(
                                          controller: _textController,
                                          decoration: const InputDecoration(
                                            hintText: 'ex) 오랜만에 먹는 카레라이스',
                                            hintStyle: TextStyle(
                                              color: Colors.grey, // 힌트 텍스트 색상
                                              fontSize: 16, // 힌트 텍스트 크기
                                              fontWeight: FontWeight.bold, // 힌트 텍스트 두께
                                            ),
                                            border: InputBorder.none, // 모든 테두리 제거
                                          ),
                                          keyboardType: TextInputType.text,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                            constraints: BoxConstraints(
                                              minHeight: 170, // 최소 높이
                                            ),
                                          child: Padding(
                                            padding: EdgeInsets.all(0),
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
                                                    Colors.transparent,
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
                                                onPressed: () async {
                                                  final mpv = Provider.of<MealSaveProvider>(context,listen: false);
                                                  final opv = Provider.of<OneFoodDetail>(context,listen: false);
                                                  opv.foodInfo['image_url'] == "String"
                                                      ? simpleAlert("사진을 등록해주세요.")
                                                      : mpv.selectedTime == "시간대"
                                                      ? simpleAlert("시간대를 선택해주세요.")
                                                      :setState(() {
                                                    _loading = true;
                                                    mpv.setText(_textController.text);
                                                    mealSave_POST(context);  //해당 클래스 안에 위치해야 함(로딩 제어)
                                                  });
                                                },
                                                child: Text('저장', style: Text16BoldBlack),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                const SizedBox(height: 20),
                              ],
                            )),
                      ),

                    ],
                  )),
              if(_loading) Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            ],
          );
        },
      )
    );
  }
}








class MealSaveCamera extends StatefulWidget {
  const MealSaveCamera({super.key});

  @override
  State<MealSaveCamera> createState() => _MealSaveCameraState();
}

class _MealSaveCameraState extends State<MealSaveCamera> {
  html.File? _file;
  Map<String, dynamic> res = {};

  void _pickFile() {
    print("_pickFile");
    final html.FileUploadInputElement uploadInput =
    html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      print(files);
      if (files != null && files.isNotEmpty) {
        final pv = Provider.of<OneFoodDetail>(context, listen: false);
        NvgToNxtPageSlide(context, const MooseDetail(type: "영양소 분석", save : true));
        setState(() {
          _file = files[0];
          pv.setfile(_file);
          print("$_file");
        });
      }
    });
  }

  int statusCode = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        //스크롤 내렸을 때 appbar색상 변경되는 거
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Moose'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            bottomShow(context);
          },
          icon: Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text("Pick File"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Container select_MealSave_Time(BuildContext context) {
  late List<String> time_odd=[];
  late List<String> time_even=[];
for(int a = 0; a < timeList.length ; a++){
  int index = a%2;
  index == 0 ? time_even.add(timeList[a]) : time_odd.add(timeList[a]);
}

  return Container(
    width: MediaQuery.of(context).size.width,
    height: 400,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text('시간대 선택',style: Text20BoldBlack,),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(time_even.length,
                      (idx) => Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              final pv = Provider.of<MealSaveProvider>(context, listen: false);
                              pv.setTime("${time_even[idx]}");
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.fromLTRB(10, 5, 10, 5),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                Size(70, 40),
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
                                width: 70,
                                height: 40,
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
                                    "${time_even[idx]}",
                                    style: Text14BlackBold,
                                  ),
                                )),
                          ),
                          SizedBox(height: 10,)
                        ],
                      )),
            ),
            Column(
              children: List.generate(time_odd.length,
                      (idx) => Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              final pv = Provider.of<MealSaveProvider>(context, listen: false);
                              pv.setTime("${time_odd[idx]}");
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
                                width: 70,
                                height: 40,
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
                                    "${time_odd[idx]}",
                                    style: Text14BlackBold,
                                  ),
                                )),
                          ),
                          SizedBox(height: 10,)
                        ],
                      )),
            )
          ],
        )
      ],
    ),
  );
}

