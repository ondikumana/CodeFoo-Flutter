import 'dart:_http';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String server = 'http://localhost:9999';

final String createUserEndpoint = '$server/create_user';
final String getUserEndpoint = '$server/get_user';
final String getSessionIdEndpoint = '$server/get_session';
final String createSessionEndpoint = '$server/create_session';

class NodeConnection {
  String firstName;
  String lastName;
  String userId;
  String sessionId;
  String code;

  void setName(String name) {
    List<String> nameList = name.split(' ');
    if (nameList.length > 1) {
      firstName = nameList[0];
      lastName = nameList[1];
    } else {
      firstName = name;
    }
  }

  NodeConnection();

  Future<bool> createUser() async {
    if (userId != null) return true;

    Map<String, String> body = {'firstName': firstName, 'lastName': lastName};

    final Response response =
        await post(createUserEndpoint, body: json.encode(body));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);

      userId = responseBody['userId'].toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      return true;
    }

    return false;
  }

  Future<String> createSession() async {
    if (sessionId != null) return code;

    Map<dynamic, dynamic> body = {
      'creatorId': userId,
      'body': {'Yes': true}
    };

    print(body);

    final Response response = await post(createSessionEndpoint,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);

      sessionId = responseBody['sessionId'].toString();
      code = responseBody['code'].toString();

      print(responseBody);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionId', sessionId);

      return code;
    }

    return null;
  }

  String getName() {
    return '$firstName $lastName';
  }

  String getUserId() {
    return userId;
  }

  String getSessionId() {
    return sessionId;
  }

  String getCode() {
    return code;
  }

  Future<Null> getAttributesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString('userId');
    if (userId != null) await _checkIfUserIdFromPrefsValid(userId, prefs);

    if (userId != null) {
      String sessionId = prefs.getString('sessionId');
      if (sessionId != null)
        await _checkIfSessionIdFromPrefsValid(sessionId, prefs);
    }
  }

  Future<Null> _checkIfUserIdFromPrefsValid(
      String userIdFromPrefs, SharedPreferences prefs) async {
    Response response = await get('$getUserEndpoint?userId=$userIdFromPrefs');

    if (response.statusCode == 200) {
      userId = userIdFromPrefs;
      firstName = json.decode(response.body)['data'][0]['first_name'];
      lastName = json.decode(response.body)['data'][0]['last_name'];
    } else {
      prefs.remove('userId');
    }
  }

  Future<Null> _checkIfSessionIdFromPrefsValid(
      String sessionIdFromPrefs, SharedPreferences prefs) async {
    Response response =
        await get('$getSessionIdEndpoint?userId=$sessionIdFromPrefs');

    if (response.statusCode == 200) {
      sessionId = sessionIdFromPrefs;
      code = json.decode(response.body)['data'][0]['code'];
    } else {
      prefs.remove('sessionId');
    }
  }
}
