
import 'package:shared_preferences/shared_preferences.dart';

const port = 8000;
const url = "https://www.ieat.store";
//const url_mi1-93 = 'http://223.130.143.86';
//const url = 'http://223.130.151.151';


int userid = 5;  //메인에서 세팅
bool isLogined = true;




Future<void> saveUserId(int userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('uid', userId);
}
Future<int?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('uid');
}
Future<void> saveNickNm(String nickname) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('nickname', nickname);
}
Future<String> getNickNm() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('nickname').toString();
}
Future<void> saveTk(String tk) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('tk', tk);
}
Future<String> getTk() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('tk').toString();
}


