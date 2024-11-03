//import 'dart:html' as html;
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
import '../home/homemainaction.dart';
import '../mooseaction.dart';

class MealSave extends StatefulWidget {
  const MealSave({super.key, this.type}); //type : 어디서 넘어왔는지(moose,home)

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
    setState(() {
      nnm = nickname;
    });
  }

  //음식 등록 api
  Future<void> mealSave_POST(BuildContext context) async {
    final mpv = Provider.of<MealSaveProvider>(context, listen: false);
    final opv = Provider.of<OneFoodDetail>(context, listen: false);
    if (opv.foodInfo['image_url'] == "String")
      return simpleAlert("오류가 발생하였습니다.");
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
    String? result_image_url =
        'temp/${extractIdFromUrl('${opv.foodInfo['image_url']}')}';
    String uri =
        '$url/meal_hour/register_meal/$today${mpv.selectedTime}/$formattedHour$formattedMinute';
    try {
      final response = await dio.request(uri,
          options: Options(
            method: 'POST',
            headers: {
              'accept': '*/*',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'Bearer $tk'
            },
            validateStatus: (status) {
              print('$funcname : $status');
              return status! < 500;
            },
          ),
          data: {
            "file_path": "${result_image_url}",
            "food_info":
                '{"is_success":true,"name":"${opv.foodInfo['food_info']['name']}","weight":"${opv.foodInfo['food_info']['weight']}","kcal":"${opv.foodInfo['food_info']['kcal']}","carb":"${opv.foodInfo['food_info']['carb']}","sugar":"${opv.foodInfo['food_info']['sugar']}","fat":"${opv.foodInfo['food_info']['fat']}","protein":"${opv.foodInfo['food_info']['protein']}","calcium":"${opv.foodInfo['food_info']['calcium']}","p":"${opv.foodInfo['food_info']['p']}","salt":"${opv.foodInfo['food_info']['salt']}","mg":"${opv.foodInfo['food_info']['mg']}","irom":"${opv.foodInfo['food_info']['irom']}","zinc":"${opv.foodInfo['food_info']['zinc']}","chol":"${opv.foodInfo['food_info']['chol']}","trans":"${opv.foodInfo['food_info']['trans']}","labels":["${opv.foodInfo['food_info']['labels'][0]}"]}',
            "text": "text"
          });
      print("${opv.foodInfo['food_info']}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _loading = false;
        });
        await homeMainTopPart(context);
        await homeMainBottomPart(context,today);
        popWithSlideAnimation(context, 2);
        bottomShow(context);
      } else if (response.statusCode == 400) {
        setState(() {
          _loading = false;
        });
        print("response.statusMessage : ${response.statusMessage}");
        switch (response.statusMessage) {
          case "Invalid mealtime":
            simpleAlert("잘못된 시간대 값입니다."); // ex) 아침 O, 아치 X
          case "Invalid date format":
            simpleAlert("인식할 수 없는 날짜입니다."); // ex) 20245-10-31
          case "Invalid hourminute":
            simpleAlert("등록하는 시간에 오류가 발생하였습니다."); // ex)05311
          case "Already registered mealhour":
            simpleAlert(
                "해당 시간대에는 등록된 음식이 있습니다."); //같은시간대 음식 중복입력 ex) 아침을 이미 등록햇는데 또 아침등록함
          case "Temporary file does not exist":
            simpleAlert("존재하지 않는 음식사진입니다."); // 서버의 file_path에 입력한 임시사진파일이 없음
        }
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
        onTap: () {},
        child: Consumer<OneFoodDetail>(
          builder: (context, pv, child) {
            return Stack(
              children: [
                Scaffold(
                    appBar: AppBar(
                      scrolledUnderElevation: 0,
                      automaticallyImplyLeading: false,
                      centerTitle: true,
                      title: Text(
                        "식단 등록",
                        style: TextAppbar,
                      ),
                      leading: IconButton(
                        onPressed: () {
                          bottomShow(context);
                          removeTempMeal_POST(context);
                          popWithSlideAnimation(
                              context, widget.type == "moose" ? 3 : 2);
                        },
                        style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        )),
                        icon: Icon(Icons.chevron_left, size: 30),
                      ),
                    ),
                    body: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Container(
                              padding: EdgeInsets.all(0),
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
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                  pv.foodInfo['image_url'] != "String"
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height:
                                              MediaQuery.of(context).size.width,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                            // shape: BoxShape.circle,
                                          ),
                                          child: Image.network(
                                            '${pv.foodInfo['image_url']}',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Row(
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
                                                        color: mainGrey
                                                            .withOpacity(0.1))),
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
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Colors.transparent,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        pv.foodInfo['image_url'] ==
                                                                "String"
                                                            ? NvgToNxtPageSlide(
                                                                context,
                                                                Camera(
                                                                    type:
                                                                        "save")) //MealSaveCamera
                                                            : simpleAlert(
                                                                "현재는 한 개의 음식 등록만 지원하고 있습니다.");
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
                                        pv.foodInfo['image_url'] ==
                                                "String" //한 식단만 등록 가능하게 제어함(추후 변경가능성 있음)
                                            ? SizedBox()
                                            : Column(
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              '${pv.foodInfo['image_url']}'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        color: ColorBackGround,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFFE6E6E6),
                                                          width: 1,
                                                        )),
                                                  ),
                                                  Text(
                                                    '${pv.foodInfo['food_info']['name']}',
                                                    style: Text14Black,
                                                  )
                                                ],
                                              )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE6E6E6),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              bottomHide(context);
                                              showTimeSelectDialog(context);
                                            },
                                            child: Consumer<MealSaveProvider>(
                                              builder: (context, pv, child) {
                                                return Text(
                                                  pv.selectedTime,
                                                  style: Text14BlackBold,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Container(
                                        constraints: BoxConstraints(
                                          minHeight: 100, // 최소 높이
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6E6E6),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(15),
                                              child: TextField(
                                                controller: _textController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'ex) 오랜만에 먹는 카레라이스',
                                                  hintStyle: TextStyle(
                                                    color: Colors
                                                        .grey, // 힌트 텍스트 색상
                                                    fontSize: 16, // 힌트 텍스트 크기
                                                    fontWeight: FontWeight
                                                        .bold, // 힌트 텍스트 두께
                                                  ),
                                                  border: InputBorder
                                                      .none, // 모든 테두리 제거
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              constraints: BoxConstraints(
                                                minHeight: 100, // 최소 높이
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      padding:
                                                          MaterialStateProperty
                                                              .all<EdgeInsets>(
                                                        EdgeInsets.fromLTRB(
                                                            10, 5, 10, 5),
                                                      ),
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all<ui.Size>(
                                                        ui.Size(90, 55),
                                                      ),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors.transparent,
                                                      ),
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all<double>(0),
                                                      shadowColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors.black,
                                                      ),
                                                      shape: MaterialStateProperty
                                                          .all<OutlinedBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      overlayColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors.transparent,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      final mpv = Provider.of<
                                                              MealSaveProvider>(
                                                          context,
                                                          listen: false);
                                                      final opv = Provider.of<
                                                              OneFoodDetail>(
                                                          context,
                                                          listen: false);
                                                      opv.foodInfo[
                                                                  'image_url'] ==
                                                              "String"
                                                          ? simpleAlert(
                                                              "사진을 등록해주세요.")
                                                          : mpv.selectedTime ==
                                                                  "시간대"
                                                              ? simpleAlert(
                                                                  "시간대를 선택해주세요.")
                                                              : setState(() {
                                                                  _loading =
                                                                      true;
                                                                  mpv.setText(
                                                                      _textController
                                                                          .text);
                                                                  mealSave_POST(
                                                                      context); //해당 클래스 안에 위치해야 함(로딩 제어)
                                                                });
                                                    },
                                                    child: Text('저장',
                                                        style: Text16BoldBlack),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              )),
                        ),
                      ],
                    )),
                if (_loading)
                  Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            );
          },
        ));
  }
}

//
// class MealSaveCamera extends StatefulWidget {
//   const MealSaveCamera({super.key});
//
//   @override
//   State<MealSaveCamera> createState() => _MealSaveCameraState();
// }
//
// class _MealSaveCameraState extends State<MealSaveCamera> {
//   html.File? _file;
//   Map<String, dynamic> res = {};
//
//   void _pickFile() {
//     print("_pickFile");
//     final html.FileUploadInputElement uploadInput =
//     html.FileUploadInputElement();
//     uploadInput.accept = 'image/*';
//     uploadInput.click();
//
//     uploadInput.onChange.listen((e) {
//       final files = uploadInput.files;
//       print(files);
//       if (files != null && files.isNotEmpty) {
//         final pv = Provider.of<OneFoodDetail>(context, listen: false);
//         NvgToNxtPageSlide(context, const MooseDetail(type: "영양소 분석", save : true));
//         setState(() {
//           _file = files[0];
//           pv.setfile(_file);
//           print("$_file");
//         });
//       }
//     });
//   }
//
//   int statusCode = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         //스크롤 내렸을 때 appbar색상 변경되는 거
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: Text('Moose'),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//             bottomShow(context);
//           },
//           icon: Icon(Icons.chevron_left, size: 30),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _pickFile,
//               child: Text("Pick File"),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

void showTimeSelectDialog(BuildContext context) {
  final List<String> timeList = ['아침', '아점', '점심', '점저', '저녁', '야식', '간식'];

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Color(0xFFE6E6E6),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(20),
        width: getWidthRatioFromScreenSize(context, 1),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '시간대 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: timeList.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // onSelect(timeList[index]);
                      final pv =
                          Provider.of<MealSaveProvider>(context, listen: false);
                      pv.setTime("${timeList[index]}");
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeList[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
