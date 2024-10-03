import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/styleutil.dart';
import 'package:ieat/util.dart';
import 'constants.dart';

class Setting_Sf extends StatefulWidget {
  const Setting_Sf({super.key});

  @override
  State<Setting_Sf> createState() => _Setting_SfState();
}

class _Setting_SfState extends State<Setting_Sf> {
  String createDays = '';
  String username = '';
  String name = '';
  String gym = '';
  String mentor_name = '';
  String textToCopy = "";

  //getCreateDay Get
  Future<void> getCreateDay() async {
    String? tk = await getTk();
    print('getCreateDay');
    try {
      final response =
      await http.get(Uri.parse('$url/user/create_day'), headers: {
        'Authorization': ' Bearer $tk',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      });
      print(response.body);
      if (response.statusCode < 500) {
        final data = json.decode(response.body);
        setState(() {
          createDays = data['days'].toString();
        });
      } else {
        print('getCreateDay Error: ${response.statusCode}');
        setState(() {
          createDays = '0';
        });
      }
    } catch (e) {
      setState(() {
        print('getCreateDay Error: $e');
        createDays = '0';
      });
    }
  }

  Future<void> getUser() async {
    String? tk = await getTk();
    print('getUser');
    try {
      final response =
      await http.get(Uri.parse('$url/user/user/setting/info'), headers: {
        'Authorization': ' Bearer $tk',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      });
      print(response.body);
      if (response.statusCode < 500) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'].toString();
          name = data['name'].toString();
          gym = data['gym'].toString();
          mentor_name = data['mentor_name'].toString();
        });
      } else {
        print('getUser Error: ${response.statusCode}');
        setState(() {});
      }
    } catch (e) {
      setState(() {
        print('getUser Error: $e');
      });
    }
  }

  @override
  void initState() {
    getCreateDay();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    bottomHide(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
            '$createDays일 째 기록 중',
            style: Text17BoldBlack,
          ),
          backgroundColor: settingBackGround,
          scrolledUnderElevation: 0,
          //스크롤 내렸을 때 appbar색상 변경되는 거
          automaticallyImplyLeading: false,
          centerTitle: true,
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
                  icon: Icon(Icons.close)),
            ),
          )),
      body: Container(
        color: settingBackGround,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Icon(
                      Icons.content_copy,
                      size: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: textToCopy));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                'ID가 복사되었습니다.',
                                style: Text15Bold,
                              )),
                        );
                      },
                      child: Text(
                        " $username",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileUpdateScaffold()));
              },
              child: Container(
                height: 110,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(15, 0, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.person, // 프사부위
                        size: 40,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              gym.isNotEmpty
                                  ?Text(
                                '$gym',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold),
                              )
                                  :SizedBox(height: 10,),
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(text: '$name', style: Text35Bold),
                                  TextSpan(
                                      text: ' 님',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ),
                              mentor_name.isNotEmpty
                                  ? Text(
                                '트레이너 $mentor_name 님에게 관리를 받는 중',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              )
                                  : Text(
                                '담당 트레이너를 등록해서 관리를 시작해보세요!',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              )
                            ],
                          ),
                        )),
                    Icon(
                      Icons.chevron_right,
                      size: 35,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFF0F0F0)),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendCommentsToDev_List()));
              },
              child: Container(
                height: 50,
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '개발자에게 의견 보내기',
                    style: Text17BoldBlack,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                logOut(context);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '로그아웃',
                    style: Text17BoldBlack,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileUpdateScaffold extends StatefulWidget {
  const ProfileUpdateScaffold({super.key});

  @override
  State<ProfileUpdateScaffold> createState() => _ProfileUpdateScaffoldState();
}

class _ProfileUpdateScaffoldState extends State<ProfileUpdateScaffold> {
  var _nickNameChk = "";
  var _trainerChk = "";
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _mentor_name = TextEditingController();

  String? _originalMentorName; // 기존 mentor_name을 저장하기 위한 변수

  @override
  void initState() {
    super.initState();
    getUser();
  }

  // getUser Get
  Future<void> getUser() async {
    print('getUser');

    String? tk = await getTk();
    try {
      final response = await http.get(Uri.parse('$url/user/get'), headers: {
        'Authorization': 'Bearer $tk',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      });
      print(response.body);
      var utf8Res = utf8.decode(response.bodyBytes);
      var data = jsonDecode(utf8Res);
      if (response.statusCode < 500) {
        setState(() {
          _name.text = data['name'];
          _nickname.text = data['nickname'];
          _mentor_name.text = data['mentor_name'];
          _originalMentorName = data['mentor_name']; // 기존 mentor_name 저장
        });
      } else {
        print('getUser Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        print('getUser Error: $e');
      });
    }
  }

  Future<void> updateProfile() async {
    print('updateProfile');
    try {
      String? mentorNameToSend;

      if (_mentor_name.text.isEmpty) {
        mentorNameToSend = null; // 빈 칸이면 null로 보냄
      } else if (_mentor_name.text == _originalMentorName) {
        mentorNameToSend = 'same'; // 기존 값과 동일하면 'same'으로 보냄
      } else {
        mentorNameToSend = _mentor_name.text; // 다르면 입력한 값을 보냄
      }

      print('mentorNameToSend: $mentorNameToSend'); // ** 이 부분을 추가하여 값 확인

      String? tk = await getTk();
      final response = await http.patch(
        Uri.parse('$url/user/update/profile'),
        headers: {
          'Authorization': 'Bearer $tk',
          'accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8', // UTF-8 설정 추가
        },
        body: utf8.encode(json.encode({
          'name': _name.text,
          'nickname': _nickname.text,
          'mentor_username': mentorNameToSend, // 수정된 부분
        })), // body를 UTF-8로 인코딩하여 전송
      );
      print(response.body);
      if (response.statusCode < 300) {
        // simpleAlert(context, "프로필이 성공적으로 업데이트되었습니다.");
      } else if (response.statusCode == 404) {
        final errorDetail = json.decode(
            utf8.decode(response.bodyBytes))['detail']; // 응답 본문을 UTF-8로 디코딩
        if (errorDetail == "Nickname is already taken") {
          setState(() {
            _nickNameChk = "닉네임이 이미 사용 중입니다.";
          });
        } else if (errorDetail == "추가 하려는 해당 사용자는 멘토가 아닙니다.") {
          setState(() {
            _trainerChk = "해당 사용자는 멘토가 아닙니다.";
          });
        } else if (errorDetail == "멘토로 본인을 추가할 순 없습니다.") {
          setState(() {
            _trainerChk = "멘토로 본인을 추가할 순 없습니다.";
          });
        } else if (errorDetail == "username이 잘못 됨.") {
          setState(() {
            _trainerChk = "트레이너 이름이 잘못되었습니다.";
          });
        } else if (errorDetail == "User not found") {
          // simpleAlert(context, "사용자를 찾을 수 없습니다.");
        }
        // simpleAlert(context, "프로필 업데이트 중 오류가 발생했습니다.");
      } else if (response.statusCode == 500) {
        // simpleAlert(context, "서버 오류가 발생했습니다.");
      } else {
        print('updateProfile Error: ${response.statusCode}');
        // simpleAlert(context, "프로필 업데이트 중 오류가 발생했습니다.");
      }
    } catch (e) {
      print('updateProfile Error: $e');
      // simpleAlert(context, "프로필 업데이트 중 오류가 발생했습니다.");
    }
  }

  void checkUpdateProfile_1(BuildContext context) {
    print('checkUpdateProfile_1');
    if (_checkNickName() && _checkTrainer()) {
      updateProfile();
    } else {
      if (!_checkNickName()) {
        setState(() {
          _nickNameChk = "닉네임은 7자 이하 한글, 소문자, 문자,_-의 특수기호만 가능합니다.";
        });
      }
      if (!_checkTrainer()) {
        setState(() {
          _trainerChk = "가입되지 않은 아이디입니다.";
        });
      }
    }
  }

  // 닉네임 체크 로직 (서버로 전송 전 간단한 클라이언트 측 검증)
  bool _checkNickName() {
    return _nickname.text.length <= 7;
  }

  // 트레이너 체크 로직 (서버로 전송 전 간단한 클라이언트 측 검증)
  bool _checkTrainer() {
    return true; // 예시로 true 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        //스크롤 내렸을 때 appbar색상 변경되는 거
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: settingBackGround,
        title: Text(
          "프로필 수정",
          style: Text17BoldBlack,
        ),
        leading: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close)),
        ),
      ),
      body: Container(
        color: settingBackGround,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Text(
                '프로필 수정',
                style: Text25BoldBlack,
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Container(
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.person, // 프사부위
                    size: 40,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              //_buildTextField("이름", _name),
              SizedBox(height: 30),
              _buildTextField("닉네임", _nickname, _nickNameChk),
              SizedBox(height: 30),
              _buildTextField("담당 트레이너 (ID 입력)", _mentor_name, _trainerChk),
              SizedBox(height: 110),
              Container(
                width: double.maxFinite,
                child: OutlinedButton(
                  style: OutBtnSty_black,
                  child: Text(
                    '저장하기',
                    style: Text17Boldwhite,
                  ),
                  onPressed: () {
                    checkUpdateProfile_1(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      [String errorText = ""]) {
    return Container(
      width: double.maxFinite,
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5, 5, 0, 10),
            height: 55,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: controller,
              obscureText: false,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          if (errorText.isNotEmpty)
            Text(
              errorText,
              textAlign: TextAlign.left,
              style: redAlertText,
            ),
        ],
      ),
    );
  }
}

//개발자에게 의견보내기 화면
class SendCommentsToDev extends StatefulWidget {
  final Map<String, String>? initialComment;
  final int? commentId; // 수정할 의견의 ID

  const SendCommentsToDev({super.key, this.initialComment, this.commentId});

  @override
  State<SendCommentsToDev> createState() => _SendCommentsToDevState();
}

class _SendCommentsToDevState extends State<SendCommentsToDev> {
  Map<String, String> _cmt = {'cmtTitle': '', 'content': ''};
  var _btnText = "등록하기";
  String _titleText = "개발팀에 의견 보내기";
  var _appBar = 0;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialComment != null) {
      // 수정할 의견이 있다면 초기화
      _cmt = widget.initialComment ?? {'cmtTitle': '', 'content': ''};
      _btnText = "수정하기";
      _titleText = "전달한 의견 수정하기";
      _appBar = 1;
      _titleController.text = _cmt['cmtTitle']!;
      _contentController.text = _cmt['content']!;
    }
  }

  Future<void> postSuggestion(String title, String content) async {
    String uri = '$url/suggest/post';

    String? tk = await getTk();
    try {
      final response = await Dio().post(
        uri,
        data: {
          'title': title,
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $tk',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response.statusCode == 200) {
        print('postSuggestion received successfully');
        setState(() {
          simpleAlert(context, "의견을 전송하였습니다.\n감사합니다.");
        });
      } else {
        print(
            'Failed to postSuggestion: ${response.statusCode}, ${response.data}');
        setState(() {
          simpleAlert(context, "의견 전송 중 오류가 발생했습니다.");
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        simpleAlert(context, "의견 전송 중 오류가 발생했습니다.");
      });
    }
  }

  Future<void> updateSuggestion(
      int suggest_id, String title, String content) async {
    String? tk = await getTk();
    String uri = '$url/suggest/update/$suggest_id';
    try {
      final response = await Dio().patch(
        uri,
        data: {
          'title': title,
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $tk',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response.statusCode == 200) {
        print('updateSuggestion received successfully');
        setState(() {
          simpleAlert(context, "의견을 수정하였습니다.\n감사합니다.");
        });
      } else {
        print(
            'Failed to updateSuggestion: ${response.statusCode}, ${response.data}');
        setState(() {
          simpleAlert(context, "의견 수정 중 오류가 발생했습니다.");
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        simpleAlert(context, "의견 수정 중 오류가 발생했습니다.");
      });
    }
  }

  void simpleAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: settingBackGround,
      ),
      body: Container(
        color: settingBackGround,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
              ),
              Text(
                '$_titleText',
                style: Text25BoldBlack,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.maxFinite,
                height: 105,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text('주제',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 55,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.maxFinite,
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text('내용',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(15)),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                          controller: _contentController,
                          textAlignVertical: TextAlignVertical.top,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_appBar == 0) {
                    // 새로운 의견 등록
                    postSuggestion(
                        _titleController.text, _contentController.text);
                  } else if (_appBar == 1 && widget.commentId != null) {
                    // 기존 의견 수정
                    updateSuggestion(widget.commentId!, _titleController.text,
                        _contentController.text);
                  }
                },
                child: Text(
                  '$_btnText',
                  style: Text17Boldwhite,
                ),
                style: OutBtnSty_black,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SendCommentsToDev_List extends StatefulWidget {
  const SendCommentsToDev_List({super.key});

  @override
  State<SendCommentsToDev_List> createState() => _SendCommentsToDev_ListState();
}

class _SendCommentsToDev_ListState extends State<SendCommentsToDev_List> {
  List<Map<String, dynamic>> cmtList = [];

  @override
  void initState() {
    super.initState();
    getSuggestionList();
  }

  //getSuggestionList Get
  Future<void> getSuggestionList() async {
    String? tk = await getTk();
    print('getSuggestionList');
    try {
      final response =
      await http.get(Uri.parse('$url/suggest/get/all_title'), headers: {
        'Authorization': 'Bearer $tk',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      });
      print(response.body);
      var utf8Res = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(utf8Res);
      if (response.statusCode == 200) {
        setState(() {
          cmtList = data.map((item) {
            return {'id': item['id'], 'cmtTitle': item['title'], 'content': ''};
          }).toList();
        });
      } else {
        print('getSuggestionList Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        print('getSuggestionList Error: $e');
      });
    }
  }

  Future<void> getSuggestionContent(int id) async {
    String? tk = await getTk();
    print('getSuggestionContent');
    try {
      final response =
      await http.get(Uri.parse('$url/suggest/get/$id/text'), headers: {
        'Authorization': 'Bearer $tk',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      });
      var utf8Res = utf8.decode(response.bodyBytes);
      final data = json.decode(utf8Res);
      if (response.statusCode < 500) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendCommentsToDev(
              initialComment: {
                'cmtTitle': data['title'],
                'content': data['content']
              },
              commentId: id, // 수정할 의견의 ID 전달
            ),
          ),
        );
      } else {
        print('getSuggestionContent Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        print('getSuggestionContent Error: $e');
      });
    }
  }

  Future<void> deleteSuggestion(int suggest_id) async {
    String? tk = await getTk();
    String uri = '$url/suggest/remove/$suggest_id';
    try {
      final response = await http.delete(
        Uri.parse(uri),
        headers: {
          'Authorization': 'Bearer $tk',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('Suggestion removed successfully');
        setState(() {
          cmtList.removeWhere((item) => item['id'] == suggest_id);
          // simpleAlert(context, "의견을 삭제하였습니다.\n감사합니다.");
        });
      } else {
        print(
            'Failed to remove Suggestion: ${response.statusCode}, ${response.body}');
        setState(() {
          // simpleAlert(context, "의견 삭제 중 오류가 발생했습니다.");
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        // simpleAlert(context, "의견 삭제 중 오류가 발생했습니다.");
      });
    }
  }

  void askAlert(BuildContext context, String message, int suggest_id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                deleteSuggestion(suggest_id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: settingBackGround,
      ),
      body: Container(
        color: settingBackGround,
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              Text(
                '전달된 의견 리스트',
                style: Text25BoldBlack,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: IconButton(
                    onPressed: () {
                      NvgToNxtPage(context, SendCommentsToDev());
                    },
                    icon: Icon(
                      Icons.add,
                      size: 30,
                    )),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          cmtList.length == 0
              ? Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("아이잇에 대해 말씀해주신 소중한 의견은"),
                    Text("버전 업그레이드 시에"),
                    Text("반영될 수 있도록 노력하겠습니다."),
                    Text("감사합니다."),
                  ],
                )
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: cmtList.length,
              itemBuilder: (c, i) {
                final _cmt = cmtList[i];
                return Container(
                    child: Slidable(
                      key: ValueKey(_cmt['id']),
                      endActionPane: ActionPane(
                        extentRatio: 0.2,
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              askAlert(context, "삭제할까요?", _cmt['id']);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '삭제',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          _cmt['cmtTitle'] ?? '',
                          style: Text15Bold,
                        ),
                        onTap: () async {
                          await getSuggestionContent(_cmt['id']);
                        },
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(20)));
              },
            ),
          )
        ]),
      ),
    );
  }
}

void logOut(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
              height: 250,
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '로그아웃할까요?',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: OutlinedButton(
                                  child: Text('아니요'),
                                  style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      minimumSize: Size(100, 55)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              flex: 5),
                          SizedBox(
                            width: 50,
                          ),
                          Flexible(
                            child: OutlinedButton(
                                child: Text('네'),
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize: Size(100, 55)),
                                onPressed: () async {
                                  // 액세스 토큰을 제거하고 로그인 화면으로 이동
                                  // await clearAccessToken();
                                  print('로그아웃 성공');
                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(context, '/login');
                                }),
                            flex: 5,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
      });
}