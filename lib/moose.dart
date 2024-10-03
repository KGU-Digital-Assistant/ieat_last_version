import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ieat/init.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';

class MooseSelectImg_Sf extends StatefulWidget {
  const MooseSelectImg_Sf({super.key});

  @override
  State<MooseSelectImg_Sf> createState() => _MooseSelectImg_SfState();
}

class _MooseSelectImg_SfState extends State<MooseSelectImg_Sf> {
  Map<String, dynamic> res = {};
  PlatformFile? filePath = null;

  int statusCode = 0;



  Future<void> readFile(File file) async {
    final contents = await file.readAsString();
    print('File contents: $contents');
  }

  void _uploadFile() async {
    String? tk = await getTk();
    // Loading_Bottom_ALert(context);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('No file selected');
      return;
    }

    final file = File(pickedFile.path);

    final uri = Uri.parse('$url/meal_hour/upload_temp');
    final request = http.MultipartRequest('POST', uri);

    // 파일을 `http.MultipartFile`로 변환
    final multipartFile = http.MultipartFile(
      'file',
      file.readAsBytes().asStream(),
      await file.length(),
      filename: file.uri.pathSegments.last,
      contentType: MediaType('image', 'png'), // MIME 타입 지정
    );

    request.headers['Authorization'] = 'Bearer $tk';
    request.headers['accept'] = 'application/json';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final resFS = await http.Response.fromStream(response);

      setState(() {
        res = jsonDecode(resFS.body);
      });

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        print(response);
        setState(() {
          statusCode = 200;
        });
        print(res);
        print("File uploaded successfully");
        Fin_Moose_Bottom_ALert(context, res, false);
      } else {
        print("File upload failed: ${response.statusCode}");
        Fin_Moose_Bottom_ALert(context, res, false);
      }
    } catch (e) {
      print("Error uploading file: $e");
      Fin_Moose_Bottom_ALert(context, res, false);
    }
  }

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

  Future<void> Fin_Moose_Bottom_ALert(
      BuildContext context, Map<String, dynamic> res, bool issuc) async {
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
                                child: Text(
                                  '식단 등록하기',
                                  style: Text20BoldBlack,
                                )),
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
  void initState() {
    // TODO: implement initState
    super.initState();
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
              onPressed: _uploadFile,
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
}


class Moose extends StatefulWidget {
  const Moose({super.key});

  @override
  State<Moose> createState() => _MooseState();
}

class _MooseState extends State<Moose> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("구현 중"),
            TextButton(onPressed: (){
              bottomSheetType500(context, loadingMoose(context));
            }, child: Text("촬영 이후 화면 미리보기"))
          ],
        ),
      ),
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
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(40, 40),
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