import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginMain_Sf extends StatefulWidget {
  const loginMain_Sf({super.key});

  @override
  State<loginMain_Sf> createState() => _loginMain_SfState();
}

class _loginMain_SfState extends State<loginMain_Sf> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String usernameErrorMessage = '';
  String passwordErrorMessage = '';
  String generalErrorMessage = '';


  final User _UserStorage = User();

  Future<void> login(BuildContext context) async {
    var _LoginData = {
      'username': _usernameController.text,
      'password': _passwordController.text
    };
    String uri = url + '/user/login';
    print(
        'Login attempt with username: ${_usernameController.text}, password: ${_passwordController.text}');
    var response ;
    try {
      response = await dio.post(
        uri,
        data: _LoginData,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
    } catch (e) {
      // 오류 처리
      print('login Error: $e');
      setState(() {
        generalErrorMessage = '로그인 중 오류가 발생했습니다.';
      });
    }
    print('Response status code: ${response.statusCode}');
    print('Response data: ${response.data}');
    //{access_token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTcyMzAwNDc4NX0.xaHeCrmCHsHWcrV2R1W__pSvOl0ax-3MBpbADwxERvA,
    // token_type: bearer, username: admin, user_id: 1, nickname: 관리자}
    if (response.statusCode == 200) {
      print(response.data);

      await saveUserId(response.data['user_id']);
      await saveNickNm(response.data['nickname']);
      await saveTk(response.data['access_token']);


      bottomShow(context);
      Future.delayed(Duration(seconds: 1,milliseconds: 500),(){
        //NvgToNxtPage(context, routTohome_Sf());
        Navigator.pushReplacementNamed(context, '/home');
      });
    } else if (response.statusCode == 401) {
      setState(() {
        generalErrorMessage = '아이디 또는 비밀번호가 잘못되었습니다.';
      });
    } else {
      setState(() {
        generalErrorMessage = '로그인 중 오류가 발생했습니다.';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(35),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 130,
                  ),
                  Image.asset(
                    'i-eat_Text_Logo.png', // 여기에 이미지 경로를 입력하세요.
                    fit: BoxFit.cover, // 이미지가 화면을 꽉 채우도록 설정
                    width: 130, // 이미지의 가로 길이를 설정
                    height: 35, // 이미지의 세로 길이를 설정
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: "아이디",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '아이디를 입력해주세요';
                            }
                            // 정규 표현식으로 아이디 유효성 검사
                            String pattern = r'^[a-zA-Z0-9@_-]+$';
                            RegExp regex = RegExp(pattern);
                            if (!regex.hasMatch(value)) {
                              return '아이디는 대소문자, 숫자, @, _, - 만 사용 가능합니다.';
                            }
                            return null;
                          })),
                  Text(usernameErrorMessage,
                      textAlign: TextAlign.left, style: redAlertText),
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "비밀번호",
                          border: InputBorder.none,
                        ),
                      )),
                  Text(passwordErrorMessage,
                      textAlign: TextAlign.left, style: redAlertText),
                  SizedBox(height: 10),
                  Text(generalErrorMessage,
                      textAlign: TextAlign.left, style: redAlertText),
                  Center(
                    child: OutlinedButton(
                        onPressed: () async {
                          print('로그인 함수 호출');
                          await login(context);
                        },
                        child: Text(
                          '로그인',
                          style: Text15Bold,
                        ),
                        style: OutlinedButton.styleFrom(
                            backgroundColor: priColorD9D9D9,
                            padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 0),
                            side: BorderSide(width: 1, color: settingBackGround),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            minimumSize: Size(double.maxFinite, 60))),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: getWidthRatioFromScreenSize(context, 0.35),
                          decoration: BoxDecoration(
                            color: ColorMealMainBodyBack,
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey, width: 0.5), // 위쪽 테두리
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Text("또는"),
                      ),
                      Container(
                          width: getWidthRatioFromScreenSize(context, 0.35),
                          decoration: BoxDecoration(
                            color: ColorMealMainBodyBack,
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey, width: 0.5), // 위쪽 테두리
                            ),
                          ))
                    ],
                  ),
                  SizedBox(height: 15),
                  OutlinedButton(
                      child: Text(
                        '카카오 간편 로그인',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        await simpleAlert("연내 제공 예정인 서비스입니다.");
                      },
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colorkakao,
                          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 0),
                          side: BorderSide(width: 1, color: Colorkakao),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          minimumSize: Size(double.maxFinite, 60))),
                  SizedBox(height: 10),
                  Text(
                    "계정이 없으신가요?",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  TextButton(
                      onPressed: () {
                        NvgToNxtPage(context, CreateID_1_IdentityChk());
                      },
                      style: ButtonStyle().copyWith(
                        overlayColor: MaterialStateProperty.all(Colors.transparent), // overlayColor 설정
                      ),
                      child: Text(
                        "새로운 ID 생성",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}


class routTohome_Sf extends StatefulWidget {
  const routTohome_Sf({super.key});

  @override
  State<routTohome_Sf> createState() => _routTohome_SfState();
}

class _routTohome_SfState extends State<routTohome_Sf> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("dffdfdf");
    Navigator.pushReplacementNamed(context, '/home');
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class CreateID_1_IdentityChk extends StatefulWidget {
  const CreateID_1_IdentityChk({super.key});

  @override
  State<CreateID_1_IdentityChk> createState() => _CreateID_1_IdentityChkState();
}

class _CreateID_1_IdentityChkState extends State<CreateID_1_IdentityChk> {
  final dio = Dio();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool showCodeInput = false;
  String phoneErrorMessage = '';
  String verificationErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_formatPhoneNumber);
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // Automatically format the phone number input
  void _formatPhoneNumber() {
    String currentText = _phoneController.text;
    String formattedText = '';

    // Remove any non-digit characters
    currentText = currentText.replaceAll(RegExp(r'[^0-9]'), '');

    // Add hyphens
    if (currentText.length > 3) {
      formattedText += currentText.substring(0, 3) + '-';
      if (currentText.length > 7) {
        formattedText += currentText.substring(3, 7) + '-';
        if (currentText.length > 11) {
          formattedText += currentText.substring(7, 11);
        } else {
          formattedText += currentText.substring(7);
        }
      } else {
        formattedText += currentText.substring(3);
      }
    } else {
      formattedText = currentText;
    }

    // Only update the text if it's different from the current one
    if (formattedText != currentText) {
      _phoneController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  Future<void> requestSMSCode(String cellphone) async {
    String uri = 'https://www.ieat.store/phone/send-code/';
    try {
      print(cellphone);
      final response = await dio.post(
        uri,
        data: json.encode({'phone_number': cellphone}),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept' : 'application/json'
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response.statusCode == 200) {
        print('SMSCode receive successfully: ${response.data}');
        setState(() {
          showCodeInput = true;
          phoneErrorMessage = '';
        });
      } else if (response.statusCode == 400) {
        print(
            'Failed to request SMSCode: ${response.statusCode}, ${response.data}');
        setState(() {
          phoneErrorMessage = '번호를 입력해주세요.';
        });
      } else {
        print(
            'Failed to request SMSCode: ${response.statusCode}, ${response.data}');
        setState(() {
          phoneErrorMessage = '번호가 잘못입력되었습니다.';
        });
      }
    } catch (e) {
      // 오류 처리
      print('Error: $e');
      setState(() {
        phoneErrorMessage = '번호가 잘못입력되었습니다.';
      });
    }
  }

  Future<void> sendSMSCode(String cellphone, String code) async {
    String uri = 'https://www.ieat.store/phone/verify-code/';
    try {
      final response = await dio.post(
        uri,
        data: json.encode({'phone_number': cellphone, 'code': code}),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      NvgToNxtPage(context, CreateID_3_signinfo(phoneNumber: cellphone));
      // if (response.statusCode == 200) {
      //   print('SMSCode send successfully: ${response.data}');
      //   setState(() {
      //     verificationErrorMessage = '';
      //     //NvgToNxtPage(context, CreateID_2_Agree(phoneNumber: cellphone));
      //   });
      // } else {
      //   setState(() {
      //     verificationErrorMessage = '인증번호가 잘못입력되었습니다.';
      //   });
      //   print(
      //       'Failed to verify SMSCode: ${response.statusCode}, ${response.data}');
      // }
    } catch (e) {
      // 오류 처리
      // print('Error: $e');
      // setState(() {
      //   verificationErrorMessage = '인증번호가 잘못입력되었습니다.';
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: Container(
                width: 25,
                height: 25,
                child: IconButton(
                    onPressed: () {
                      bottomShow(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.chevron_left)),
              ),
            ),
            scrolledUnderElevation: 0,
            //스크롤 내렸을 때 appbar색상 변경되는 거
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "새로운 ID 생성",
              style: Text17BoldBlack,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text('휴대폰 번호를 인증해주세요.', style: TextTitle),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Container(
                        width: getWidthRatioFromScreenSize(context, 0.7),
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                          child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: ' ex) 010-1234-5678')),
                        ),
                      ),
                      Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 0),
                          side: BorderSide(width: 1, color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: Size(
                            getWidthRatioFromScreenSize(context, 0.2),
                            58,
                          ),
                        ).copyWith(
                          overlayColor: MaterialStateProperty.all(Colors.transparent), // overlayColor 설정
                        ),
                        onPressed: () {
                          requestSMSCode(_phoneController.text);
                        },
                        child: Text(
                          '요청',
                          style: Text17BoldBlack,
                        ),
                      )
                      ,
                    ],
                  ),
                  phoneErrorMessage.isNotEmpty
                      ? Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                    child: Text(phoneErrorMessage,
                        textAlign: TextAlign.left, style: redAlertText),
                  )
                      : SizedBox(),
                  SizedBox(
                    height: 30,
                  ),
                  if (showCodeInput) ...[
                    Container(
                      width: getWidthRatioFromScreenSize(context, 1),
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                        child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '  인증번호를 입력해주세요.')),
                      ),
                    ),
                    Text(verificationErrorMessage,
                        textAlign: TextAlign.left, style: redAlertText),
                    SizedBox(
                      height: 210,
                    ),
                    Center(
                      child: OutlinedButton(
                          child: Text(
                            '다음',
                            style: OutlinedButtonTextSty_1,
                          ),
                          style: OutBtnSty,
                          onPressed: () {
                            sendSMSCode(
                                _phoneController.text, _codeController.text);
                          }),
                    )
                  ]
                ],
              ),
            ),
          )),
    );
  }
}

class CreateID_2_Agree extends StatefulWidget {
  final String phoneNumber;

  const CreateID_2_Agree({super.key, required this.phoneNumber});

  @override
  State<CreateID_2_Agree> createState() => _CreateID_2_Agree();
}

class _CreateID_2_Agree extends State<CreateID_2_Agree> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                    '이용약관에 대한 동의가 필요해요.',
                    style: TextTitle,
                  ),
                  Text(
                    '전체 동의',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                      '------------------------------------------------------------------------------------------------------------'),
                  SizedBox(
                    height: 200,
                  ),
                  Center(
                    child: OutlinedButton(
                        child: Text(
                          '다음',
                          style: OutlinedButtonTextSty_1,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                              getWidthRatioFromScreenSize(context, 0.42),
                              vertical: 27),
                          side: BorderSide(width: 1, color: Colors.black),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                        ),
                        onPressed: () {
                          print(widget.phoneNumber);
                          NvgToNxtPage(
                              context,
                              CreateID_3_signinfo(
                                  phoneNumber: widget.phoneNumber));
                        }),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

class CreateID_3_signinfo extends StatefulWidget {
  final String phoneNumber;

  const CreateID_3_signinfo({super.key, required this.phoneNumber});

  @override
  State<CreateID_3_signinfo> createState() => _CreateID_3_signinfoState();
}

class _CreateID_3_signinfoState extends State<CreateID_3_signinfo> {
  final _uCreKey = GlobalKey<FormState>();
  Map<String, dynamic> _uInfolist = {
    "name": "string",
    "username": "string",
    "nickname": "string",
    "cellphone": "string",
    "password1": "string",
    "password2": "string",
    "gender": true,
    "email": "string",
    "birth": "2024-07-25"
  };

  final TextEditingController _idCtr = TextEditingController();
  final TextEditingController _nnmCtr = TextEditingController();
  final TextEditingController _emailCtr = TextEditingController();
  final TextEditingController _pwdCtr = TextEditingController();
  final TextEditingController _pwdReCtr = TextEditingController();

  String usernameErrorMessage = '';
  String nicknameErrorMessage = '';
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String cellphoneErrorMessage = '';
  String generalErrorMessage = '';
  String? _fcmToken;
// FCM 토큰 발급받기
  Future<void> _getFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 사용자로부터 알림 권한 요청 (iOS에서는 필수)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // FCM 토큰 발급
        String? token = await messaging.getToken();
        setState(() {
          _fcmToken = token;
        });
        print("FCM 토큰: $_fcmToken");

        await _createID();
        await _sendFCMTokenToServer();
      } else {
        print("알림 권한이 없습니다.");
      }
    } catch (e) {
      await simpleAlert("예기치 못한 오류가 발생하였습니다.\n (오류코드 : 8001)");
      print("FCM 토큰을 발급받는 중 오류가 발생했습니다(8001): $e");
    }
  }
  Future<void> _sendFCMTokenToServer() async {

    try {
      final headers = {"Content-Type": "application/json", 'accept' : 'application/json'};

      // 쿼리 파라미터 설정
      final uri = Uri.https(
        "$url",  // 호스트 URL을 여기에 입력
        "/user/register/fcm-token",  // 엔드포인트 입력
        {"_fcm_token  ": _fcmToken, "_user_name ": _idCtr.text},  // 쿼리 파라미터로 넘길 값
      );

      final response = await http.post(uri, headers: headers);
      print("_sendFCMTokenToServer : ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Profile Create successfully");
        Get.defaultDialog(
          content: Column(
            children: [
              Text(
                "회원가입이 완료되었습니다.",
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
      } else {
        final responseBody = json.decode(response.body);
        print("Failed to createFCMToken: ${response.statusCode}, ${response.body}");
      }
    } catch (e) { //8002
      print("Error: $e");
      setState(() {
        generalErrorMessage = '예기치 못한 오류가 발생하였습니다. 잠시 후 다시 이용해주세요.';
      });
    }
  }
  Future<void> _createID() async {
    final halfUrl = '$url/user/create'; // 서버 URL을 실제 URL로 변경하세요
    final headers = {"Content-Type": "application/json", 'accept' : 'application/json'};

    if (_uCreKey.currentState!.validate() && _pwdCtr.text == _pwdReCtr.text) {
      String _nm = _idCtr.text;
      String _nnm = _nnmCtr.text;
      String _pwd = _pwdCtr.text;
      String _pwdRe = _pwdReCtr.text;
      String _cnum = widget.phoneNumber;
      String _email = _emailCtr.text;

      final body = json.encode({
        "name": _nm,
        "username": "${_idCtr.text}",
        "nickname": _nnm,
        "cellphone": _cnum,
        "password1": _pwd,
        "password2": _pwdRe,
        "email": _email,
        "gender": true,
        "birth": "2024-01-01"
      });
      try {
        final response = await http.post(Uri.parse(halfUrl), headers: headers, body: body);
        print("_createID : ${response.statusCode}");
        if (response.statusCode == 200) {
          print("Profile Create successfully");
          Get.defaultDialog(
            content: Column(
              children: [
                Text(
                  "회원가입이 완료되었습니다.",
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
        } else {
          final responseBody = json.decode(response.body);
          setState(() {
            usernameErrorMessage = '';
            nicknameErrorMessage = '';
            emailErrorMessage = '';
            passwordErrorMessage = '';
            cellphoneErrorMessage = '';
            generalErrorMessage = '';

            switch (responseBody['detail']['error_code']) {
              case 2:
                nicknameErrorMessage = '이미 사용중인 닉네임입니다.';
                break;
              case 3:
                emailErrorMessage = '이미 사용중인 이메일입니다';
                break;
              case 4:
                cellphoneErrorMessage = '이미 가입된 상태입니다.';
                break;
              default:
                generalErrorMessage = '알 수 없는 오류가 발생했습니다.';
                break;
            }
          });
          print(
              "Failed to Create profile: ${response.statusCode}, ${response.body}");
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          generalErrorMessage = '회원가입 중 오류가 발생했습니다.(오류코드 : 8002)';
        });
      }
    } else if (_pwdCtr.text != _pwdReCtr.text) {
      setState(() {
        passwordErrorMessage = '비밀번호가 일치하지 않습니다.';
      });
    }
  }

  Future<void> getusername_GET() async {
    print('getusername_GET');
    String uri =
        'http://223.130.143.86/user/users/username/${_idCtr.text}'; // 서버 URL을 실제 URL로 변경하세요.
    try {
      final response = await dio.get(
        uri,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 404) {
        setState(() {
          usernameErrorMessage = '사용 가능한 아이디입니다.';
        });
      } else {
        setState(() {
          usernameErrorMessage = '이미 사용 중인 아이디입니다.';
        });
      }
    } catch (e) {
      print('getusernameGET Error: $e');
      setState(() {
        usernameErrorMessage = '아이디 중복 확인 중 오류가 발생했습니다.';
      });
    }
  }


  Future<void> _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _token = token!;
    });
  }

  String _token = '';

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  void dispose() {
    _idCtr.dispose();
    _nnmCtr.dispose();
    _emailCtr.dispose();
    _pwdCtr.dispose();
    _pwdReCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
          appBar: AppBar(),
          body: Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Form(
                      key: _uCreKey,
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('가입정보를 입력해주세요.', style: TextTitle),
                              SizedBox(
                                height: 20,
                              ),
                              Text('아이디'),
                              Container(
                                  width: double.maxFinite,
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: getWidthRatioFromScreenSize(
                                            context, 0.65),
                                        height: 50,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        child: Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(13, 0, 0, 0),
                                          child: TextFormField(
                                              controller: _idCtr,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: ' 사용하실 아이디'),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return '아이디를 입력해주세요';
                                                }
                                                // 정규 표현식으로 아이디 유효성 검사
                                                String pattern =
                                                    r'^[a-zA-Z0-9@_-]+$';
                                                RegExp regex = RegExp(pattern);
                                                if (!regex.hasMatch(value)) {
                                                  return '아이디는 대소문자, 숫자, @, _, - 만 사용 가능합니다.';
                                                }
                                                return null;
                                              }),
                                        ),
                                      ),
                                      Spacer(),
                                      OutlinedButton(
                                          onPressed: getusername_GET,
                                          child: Text(
                                            '중복확인',
                                            style: Text17BoldBlack,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 13, vertical: 0),
                                              side: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                              minimumSize: Size(
                                                  getWidthRatioFromScreenSize(
                                                      context, 0.25),
                                                  58))),
                                    ],
                                  )),
                              usernameErrorMessage == '' ? SizedBox(height: 5,)
                                  :Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Text(usernameErrorMessage,
                                    textAlign: TextAlign.left,
                                    style: redAlertText),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text('닉네임'),
                              Container(
                                  width: double.maxFinite,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                    child: TextFormField(
                                        controller: _nnmCtr,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: ' ex. 복숭아엎드려납작'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '닉네임을 입력해주세요';
                                          }
                                          return null;
                                        }),
                                  )),
                              nicknameErrorMessage == '' ? SizedBox(height: 5,)
                                  :Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Text(nicknameErrorMessage,
                                    textAlign: TextAlign.left,
                                    style: redAlertText),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text('이메일'),
                              Container(
                                  width: double.maxFinite,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                    child: TextFormField(
                                        keyboardType: TextInputType.emailAddress,
                                        controller: _emailCtr,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: ' ex. example@domain.com'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '이메일을 입력해주세요';
                                          }
                                          // 이메일 형식 유효성 검사
                                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                              .hasMatch(value)) {
                                            return '이메일 형식을 맞춰주세요';
                                          }
                                          return null;
                                        }),
                                  )),
                              emailErrorMessage == '' ? SizedBox(height: 5,)
                                  :Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Text(emailErrorMessage,
                                    textAlign: TextAlign.left,
                                    style: redAlertText),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text('비밀번호'),
                              Container(
                                  width: double.maxFinite,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                    child: TextFormField(
                                        obscureText: true,
                                        controller: _pwdCtr,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: ' 영문,숫자,특수문자 혼합 10자 이상'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '비밀번호를 입력해주세요';
                                          }
                                          // 정규 표현식으로 비밀번호 유효성 검사
                                          String pattern =
                                              r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~]).{10,}$';
                                          RegExp regex = RegExp(pattern);
                                          if (!regex.hasMatch(value)) {
                                            return '비밀번호는 영문, 숫자, 특수문자를 포함하여 10자 이상이어야 합니다.';
                                          }
                                          return null;
                                        }),
                                  )),
                              passwordErrorMessage == '' ? SizedBox(height: 5,)
                                  :Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Text(passwordErrorMessage,
                                    textAlign: TextAlign.left,
                                    style: redAlertText),
                              ),
                              Container(
                                width: double.maxFinite,
                                height: 50,
                                decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                  child: TextFormField(
                                      obscureText: true,
                                      controller: _pwdReCtr,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: ' 비밀번호 재입력'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '비밀번호를 입력해주세요';
                                        }
                                        return null;
                                      }),
                                ),
                              ),
                              generalErrorMessage == '' ? SizedBox(height: 5,)
                                  :Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Text(generalErrorMessage,
                                    textAlign: TextAlign.left,
                                    style: redAlertText),
                              ),
                              cellphoneErrorMessage == '' ? SizedBox(height: 30,)
                                  :Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Text(cellphoneErrorMessage,
                                    textAlign: TextAlign.left,
                                    style: redAlertText),
                              ),
                              Center(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      print('회원가입 함수 호출');
                                      await _createID();
                                    },
                                    child: Text(
                                      '가입하기',
                                      style: Text17BoldBlack,
                                    ),
                                    style: OutBtnSty,
                                  ))
                            ]),
                      ))))),
    );
  }
}

