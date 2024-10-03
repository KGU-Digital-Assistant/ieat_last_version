import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // jsonDecode 사용을 위해 필요
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ieat/moose.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';


class MealSaveSf extends StatefulWidget {
  const MealSaveSf({super.key});

  @override
  State<MealSaveSf> createState() => _MealSaveSfState();
}

class _MealSaveSfState extends State<MealSaveSf> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  Map<String, dynamic> res = {};
  PlatformFile? filePath = null;

  int statusCode = 0;

  Future<void> readFile(File file) async {
    final contents = await file.readAsString();
    print('File contents: $contents');
  }

  // void _uploadFile() async {
  //   Loading_Bottom_ALert(context);
  //
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile == null) {
  //     print('No file selected');
  //     return;
  //   }
  //
  //   final file = File(pickedFile.path);
  //
  //   final uri = Uri.parse('$url/meal_hour/upload_temp');
  //   final request = http.MultipartRequest('POST', uri);
  //
  //   String? tk = await getTk();
  //   // 파일을 `http.MultipartFile`로 변환
  //   final multipartFile = http.MultipartFile(
  //     'file',
  //     file.readAsBytes().asStream(),
  //     await file.length(),
  //     filename: file.uri.pathSegments.last,
  //     contentType: MediaType('image', 'png'), // MIME 타입 지정
  //   );
  //
  //   request.headers['Authorization'] = 'Bearer $tk';
  //   request.headers['accept'] = 'application/json';
  //   request.headers['Content-Type'] = 'multipart/form-data';
  //   request.files.add(multipartFile);
  //
  //   try {
  //     final response = await request.send();
  //     final resFS = await http.Response.fromStream(response);
  //
  //     setState(() {
  //       res = jsonDecode(resFS.body);
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Navigator.of(context).pop();
  //       print(response);
  //       setState(() {
  //         statusCode = 200;
  //       });
  //       print(res);
  //       print("File uploaded successfully");
  //       Fin_Moose_Bottom_ALert(context, res, false);
  //     } else {
  //       print("File upload failed: ${response.statusCode}");
  //       Fin_Moose_Bottom_ALert(context, res, false);
  //     }
  //   } catch (e) {
  //     print("Error uploading file: $e");
  //     Fin_Moose_Bottom_ALert(context, res, false);
  //   }
  // }

  Future<void> Loading_Bottom_ALert(BuildContext context) async {
    // 생성, 수정, 생성실패,수정실패
    bool _isLoading = true;
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        if (_isLoading) {
          return Container(
              width: double.maxFinite,
              height: getHeightRatioFromScreenSize(context, 0.7),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 2.5), // 위쪽 테두리
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: Container(
                  width: getWidthRatioFromScreenSize(context, 0.7),
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      // Image.asset(
                      //   'assets/gif/mooseloading.gif',
                      //   width: 200,
                      //   height: 200,
                      //   fit: BoxFit.cover,
                      // ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        '영양소를 분석하고 있어요.',
                        style: Text35Bold,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '잠시만 기다려주세요.',
                        style: Text15BoldGrey,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )));
        }
      },
    );
  }
  Future<void> Fin_Moose_Bottom_ALert(BuildContext context, Map<String, dynamic> res, bool issuc) async {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
            width: double.maxFinite,
            height: getHeightRatioFromScreenSize(context, 0.7),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.white, width: 2.5), // 위쪽 테두리
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )),
            child: Container(
                width: getWidthRatioFromScreenSize(context, 0.7),
                child: issuc
                    ? Column(
                  //수정
                  children: [
                    SizedBox(height: 40),
                    Image.asset(
                      'assets/alertimg/qrcode.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '영양소 분석에 성공하였습니다.',
                      style: Text25BoldBlack,
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      width: getWidthRatioFromScreenSize(context, 0.8),
                      child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            //widget.pageType == 0?NvgToNxtPage(context, Moose_Detail_Sf(res: res)):NvgToNxtPage(context, MealDetail_Sf(res: res));
                          },
                          style: OutBtnSty,
                          child:Text(
                            '식단 등록하기',
                            style: Text20BoldBlack,
                          )
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                )
                    : Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/alertimg/fail.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '문제가 발생하였습니다.',
                      style: Text25BoldBlack,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '잠시 후 다시 이용해주세요.',
                      style: Text20BoldBlack,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: getWidthRatioFromScreenSize(context, 0.8),
                      child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            bottomShow(context);
                          },
                          style: OutBtnSty,
                          child: Text(
                            '닫기',
                            style: Text20BoldBlack,
                          )),
                    ),
                    SizedBox(height: 20),
                  ],
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        //스크롤 내렸을 때 appbar색상 변경되는 거
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Moose'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){},
              child: Text("Upload File"),
            ),
            statusCode == 200
                ? OutlinedButton(
              onPressed: () {
                print('성공');
              },
              child: Text('상세페이지로 이동'),
              style: OutBtnSty,
            )
                : Text('업로드 전')
          ],
        ),
      ),
    );
  }


  String nnm = "";
  Widget newMealSave(BuildContext context, Map<String,dynamic> data) => Stack(
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
                        'assets/icons/track/Melting face.png',
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
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ]),
            ),
            SizedBox(height: 7),
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
                        '${data['food_info']['image_url']}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text("${data['food_info']['name']}")
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
                        hintText: '내용',
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
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: ColorBackGround,
        ),
        padding: EdgeInsets.all(10),
        child: SizedBox(),
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 0, 15, 20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.fromLTRB(10, 5, 10, 5),
              ),
              minimumSize: MaterialStateProperty.all<Size>(
                Size(90, 55),
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
            onPressed: (){},
            child: Text('등록', style: Text16BoldWhite),
          ),
        ),)
    ],
  );

  //
  // @override
  // Widget build(BuildContext context) {
  //
  //   return GestureDetector(
  //     onTap: () => FocusScope.of(context).unfocus(),
  //     child: Scaffold(
  //       body: Center(
  //         child: ElevatedButton(
  //           child: Text(''),
  //           onPressed: () async{
  //             String? nickname = await getNickNm();
  //             setState(() {
  //               nnm = nickname;
  //             });
  //             Map<String, dynamic> testdata = {
  //               "file_path": "temp/1_2024-09-17-215711",
  //               "food_info": {
  //                 "name": "Oatmeal",
  //                 "date": "2024-06-27T07:30:00",
  //                 "heart": true,
  //                 "carb": 50,
  //                 "protein": 10,
  //                 "fat": 5,
  //                 "calorie": 300,
  //                 "unit": "gram",
  //                 "size": 200,
  //                 "daymeal_id": 1
  //               },
  //               "image_url": "https://storage.googleapis.com/ieat-76bd6.appspot.com/temp/1_2024-09-17-215711?Expires=1726581433&GoogleAccessId=firebase-adminsdk-eigep%40ieat-76bd6.iam.gserviceaccount.com&Signature=T2T4mqNv8MJytZTchoj3ne8ubwvhhA6IEgLodnokmq%2FSWmtESHJzaSv%2F9cy2G1VWbQZ45214yRQEiPop9CKGEuxqdcUBerXiA%2BRWV7y%2Fa8ttw8zHk4IUH%2BxoHJY9S%2FScR%2BVYQ0Lke39Vb36CcpvJVcioz71wyuQhJvVofBmSfzpWEqTsSbruaSFOjjkj6rKYUgq6DeLyotsCQsCY2t%2BOYTxeph9HPm1JcDSW7CKcVmNos4TLy3tUV0q9B8Ajx0NF%2F20uu1pX5M8r6580nx%2BJKLK7qYF0UsqZVYwBold2J7T5JwosPuRdR%2BAGYBxV%2FdpcGGDkX3He8bXbHBLKq9sKxg%3D%3D"
  //             };
  //             bottomHide(context);
  //             bottomSheetType90per(context, newMealSave(context, testdata));
  //           },
  //         ),
  //       ),
  //     )
  //   );
  // }
}
