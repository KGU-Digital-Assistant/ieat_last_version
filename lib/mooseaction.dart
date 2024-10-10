import 'dart:convert';

import 'package:http_parser/http_parser.dart' as htpar;

import 'package:http/http.dart' as http;
//import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'package:provider/src/provider.dart' as pcgpv;

import 'dart:io';
import 'package:http_parser/http_parser.dart' as htpr;
import 'package:mime/mime.dart' as mime;
import 'main.dart';
import 'moose.dart';

Future<void> runMoose(String imagePath) async {
  String? tk = await getTk();
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $tk',
  };

  const String apiUrl = '$url/meal_hour/upload_temp';
// 앱(Android/iOS) 환경에서의 처리
  final File imageFile = File(imagePath);

  // 파일의 MIME 타입 가져오기
  final mimeType = mime.lookupMimeType(imageFile.path) ??
      'application/octet-stream'; // 기본값 설정

  var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
    ..headers.addAll(headers)
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: htpr.MediaType('image', 'jpeg'), // 파일의 MIME 타입 설정
    ));

  final response = await request.send();

  if (response.statusCode == 200) {
    print('이미지 업로드 성공');
    final responseData = await http.Response.fromStream(response);
    print('Response body: ${responseData.body}');
  } else {
    print('업로드 실패: ${response.statusCode}');
  }
}

Future<void> uploadFile(BuildContext context) async {
  final pv = pcgpv.Provider.of<OneFoodDetail>(context, listen: false);
  //
  // // html.File? file = pv.file;
  // print("$file");
  // // bottomSheetType500(context, loadingMoose(context));
  // if (file == null) return;
  // print('_uploadFile');
  // pv.clear();
  // final uri = Uri.parse('$url/meal_hour/upload_temp');
  // final request = http.MultipartRequest('POST', uri);
  //
  // // 파일을 `http.MultipartFile`로 변환
  // final reader = html.FileReader();
  // reader.readAsArrayBuffer(file!);

  // reader.onLoadEnd.listen((e) async {
  //   List<int> bytes = reader.result as List<int>;
  //
  //   final multipartFile = http.MultipartFile.fromBytes(
  //     'file',
  //     bytes,
  //     filename: file!.name,
  //     contentType: htpar.MediaType('image', 'png'), // MIME 타입 지정
  //   );
  //   String? tk = await getTk();
  //
  //   request.headers['Authorization'] = 'Bearer $tk';
  //   request.headers['accept'] = 'application/json';
  //   request.headers['Content-Type'] = 'multipart/form-data';
  //   request.files.add(multipartFile);
  //
  //   final response = await request.send();
  //   final resFS = await http.Response.fromStream(response);
  //   try {
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> jsonData = jsonDecode(resFS.body);
  //       pv.setInfo(jsonData);
  //       pv.setMooseSuc(true);
  //       //OneMooseDetail
  //       // {"file_path":"temp/2_2024-10-08-161810",
  //       // "food_info":{"name":"Oatmeal",
  //       // "date":"2024-06-27T07:30:00","heart":true,
  //       // "carb":50.0,"protein":10.0,"fat":5.0,
  //       // "calorie":300.0,"unit":"gram","size":200.0,"daymeal_id":1},
  //       // "image_url":"https://storage.googleapis.com/ieat-76bd6.appspot.com/temp/2_2024-10-08-161810?Expires=1728375491&GoogleAccessId=firebase-adminsdk-eigep%40ieat-76bd6.iam.gserviceaccount.com&Signature=dKCRITjPcfHrN8%2Bf9QOOxDG2Y%2F2VE%2FjrJea4ySowMgD0pD0%2Bo8pWChpx%2FebsuCY%2FcLac305uKqkwYb0XSN%2BUeSsl1EMLF2Ih5XEIz5K9jVp9OfJ%2BNznGeWLze%2F9kGDHOZx%2B5MQA0t58kO6QundU5cWD9yKc1tZBOJ4xPg5mp%2F%2Flxo%2BTdLRiHFNfU6718o1C83Td2DVHnfOGL9PCXEBDEagaCgEBGUZmD2AaeV29puWTEXu%2BxgWIX0nyRShJ5jjQx%2BShH3m9y%2FoildNeYTwUrbm2RuluezEv8SGm8FAqmGEm5O9W5zyZdnxQMHjNFB7jNbdV38Ep%2Bx11WmVsNUx0TGQ%3D%3D"}
  //       print("File uploaded successfully");
  //     } else {
  //       print("File upload failed: ${response.statusCode}");
  //       // simpleAlert("문제가 발생하였습니다. 잠시 후 다시 이용해주세요.");
  //     }
  //   } catch (e) {
  //     print("Error uploading file: $e");
  //     // simpleAlert("문제가 발생하였습니다. 잠시 후 다시 이용해주세요.");
  //   }
  // });
}




