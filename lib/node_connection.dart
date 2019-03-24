import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final String server = 'http://10.0.2.2:9999';
// final String server = 'http://localhost:9999';
final String server = 'http://157.230.84.99:9999';

final String createUserEndpoint = '$server/create_user';
final String getUserEndpoint = '$server/get_user';
final String getSessionEndpoint = '$server/get_session';
final String createSessionEndpoint = '$server/create_session';
final String joinSessionEndpoint = '$server/join_session';
final String createMessageEndpoint = '$server/create_message';
final String getMessagesEndpoint = '$server/get_messages';
final String deleteUserEndpoint = '$server/delete_user';

class NodeConnection {
  String serverUrl = server;

  String firstName;
  String lastName;
  String userId;
  String sessionId;
  String code;
  bool isSessionCreator;
  bool isFriendConnected;
  String friendId;
  String friendName;

  void setName(String name) {
    List<String> nameList = name.split(' ');
    if (nameList.length > 1) {
      firstName = nameList[0];
      lastName = nameList[1];
    } else {
      firstName = name;
    }
  }

  void setCode(String codeFromFriend) {
    code = codeFromFriend;
  }

  NodeConnection();

  Future<bool> createUser() async {
    if (userId != null) return true;

    Map<String, String> body = {'firstName': firstName, 'lastName': lastName};

    final Response response = await post(createUserEndpoint,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);

      userId = responseBody['userId'].toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      return true;
    }

    return false;
  }

  Future<bool> createSession() async {
    if (sessionId != null) return true;

    Map<String, String> body = {'creatorId': userId};

    final Response response = await post(createSessionEndpoint,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);

      sessionId = responseBody['sessionId'].toString();
      code = responseBody['code'].toString();
      isSessionCreator = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionId', sessionId);
      await prefs.setBool('isSessionCreator', isSessionCreator);
      await prefs.setString('code', code);

      return true;
    }

    return false;
  }

  Future<bool> checkSession() async {
    if (sessionId != null) return true;
    try {
      Response response =
          await get('$joinSessionEndpoint?code=$code&friendId=$userId');

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['approved'] == true) {
        sessionId = responseBody['data'][0]['session_id'].toString();
        setFriendId(responseBody['data'][0]['creator_id'].toString());

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('sessionId', sessionId);
        await prefs.setBool('isSessionCreator', false);
        await prefs.setString('code', code);

        return true;
      }
    } catch (err) {
      print(err);
    }
    return false;
  }

  Future<List> getInitialMessages() async {
    if (sessionId == null) return null;
    try {
      Response response =
          await get('$getMessagesEndpoint?sessionId=$sessionId');

      Map<String, dynamic> responseBody = json.decode(response.body);
      print('initial messages responsebody $responseBody');

      if (response.statusCode == 200) {
        List initialMessages = responseBody['data'];
        print('initial messages $initialMessages');
        return initialMessages;
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  Future<bool> sendMessage(String messageBody, String type) async {
    Map<String, String> body = {
      'sessionId': sessionId,
      'senderId': userId,
      'type': type,
      'body': messageBody
    };

    final Response response = await post(createMessageEndpoint,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> deleteUser() async {
    if (userId == null) return false;

    Map<String, String> body = {'userId': userId};

    final Response response = await post(deleteUserEndpoint,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('sessionId');

      return true;
    }

    return false;
  }

  Future<String> getFriendName() async {
    if (friendName != null) return friendName;
    try {
      Response response = await get('$getUserEndpoint?userId=$friendId');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print('getUser responseBody $responseBody');
        String firstName = responseBody['data'][0]['first_name'];
        String lastName = responseBody['data'][0]['last_name'];
        String fetchedFriendName = firstName;
        if (lastName != 'null' && lastName != null) {
          fetchedFriendName = firstName + ' ' + lastName;
        }
        friendName = fetchedFriendName;
        print('friendName $friendName');
        return friendName;
      }
    } catch (err) {
      print(err);
    }
    return 'Friend';
  }

  void setFriendId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('friendId', id);
    friendId = id;
  }

  String getName() {
    if (lastName != null && lastName == 'null') {
      return '$firstName $lastName';
    }
    return firstName;
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

  String getSenderName(String senderId) {
    if (senderId == userId) {
      return getName();
    } else {
      return friendName;
    }
  }

  bool getIsSessionCreator() {
    if (isSessionCreator == null) {
      return false;
    }
    return isSessionCreator;
  }

  bool getIsFriendConnected() {
    if (isFriendConnected == null) {
      return false;
    }
    return isFriendConnected;
  }

  Future<Null> getAttributesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.remove('userId');
    // await prefs.remove('sessionId');

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
    try {
      Response response = await get('$getUserEndpoint?userId=$userIdFromPrefs');

      if (response.statusCode == 200) {
        userId = userIdFromPrefs;
        firstName = json.decode(response.body)['data'][0]['first_name'];
        lastName = json.decode(response.body)['data'][0]['last_name'];
      }
    } catch (err) {
      print(err);
      await prefs.remove('userId');
    }
  }

  Future<Null> _checkIfSessionIdFromPrefsValid(
      String sessionIdFromPrefs, SharedPreferences prefs) async {
    try {
      Response response =
          await get('$getSessionEndpoint?sessionId=$sessionIdFromPrefs');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        print('responseBody $responseBody userId $userId');

        if (responseBody['data'].length > 0) {
          sessionId = sessionIdFromPrefs;
          code = prefs.getString('code');
          friendId = prefs.getString('friendId');
          if (responseBody['data'][0]['creator_id'].toString() == userId) {
            isSessionCreator = true;
            if (responseBody['data'][0]['friend_id'] != null) {
              isFriendConnected = true;
              // friendId = responseBody['data'][0]['friend_id'].toString();
            } else {
              isFriendConnected = false;
            }
          }
          
        } else {
          await prefs.remove('sessionId');
        }
      }
    } catch (err) {
      print(err);
      await prefs.remove('sessionId');
    }
  }

  String getServerUrl() {
    return serverUrl;
  }
}
