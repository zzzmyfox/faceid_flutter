import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faceid_plugin/DioUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'faceid_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _bizToken = "";
  Map _detectData;
  String _message = "";
  String _data = "";
  String _success = "";

  Future getBizToken() async {
    Map<String, dynamic> userData = {
      "memberId":"",
      "lastName":"",
      "firstName":"",
      "idcardNum":"",
    };
    FormData formData = FormData.fromMap(userData);
    Map bizToken = await DioUtil().post("http://192.168.2.19:8080/fi/getBizToken", formData);
    setState(() {
      _bizToken = bizToken['data']['biz_token'];
      print(_bizToken);
    });
  }

  Future<void> initDetect() async {
    Map result;
    try {
      result = await FaceidPlugin.faceIDDetector(bizToken: _bizToken);
    } on PlatformException {
      _bizToken = "";
    }
    if (!mounted) return;
    setState(() {
      _detectData = result;
      _message = result["message"].toString();
      if (result["code"] == 1000){
        _data = base64encode(result["data"].toString());
        print(_data);
      }
      print(result);
    });
  }

  Future verifyToken() async {
    if (_detectData["code"] == 1000) {
      Map<String, dynamic> faceData = {
        "bizToken": _bizToken,
        "data": _data,
      };
      FormData formData = FormData.fromMap(faceData);
      print(faceData);
      Map result = await DioUtil().post(
          "http://192.168.2.19:8080/fi/verify", formData);
      setState(() {
        _success = result.toString();
        print(result);
      });
    } else {
      setState(() {
        _success = "失败";
      });
    }
  }

  String base64encode(String data) {
      var content = utf8.encode(data);
      var digest = base64UrlEncode(content);
      return digest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("人脸核身"),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: FlatButton(
              child: Text("获取Token", style: TextStyle(color: Colors.white),),
              color: Colors.blue,
              onPressed: () {
                getBizToken();
              },
            ),
          ),
          Center(
            child: FlatButton(
              child: Text("开始认证", style: TextStyle(color: Colors.white),),
              color: Colors.blue,
              onPressed: () {
                initDetect();
              },
            ),
          ),
          Center(
            child: FlatButton(
              child: Text("验证数据", style: TextStyle(color: Colors.white),),
              color: Colors.blue,
              onPressed: () {
                verifyToken();
              },
            ),
          ),

          Center(
            child: Text(_bizToken)
          ),
          Center(
              child: Text(_message)
          ),
//          Center(
//              child: Text(_data)
//          ),
          Center(
              child: Text(_success)
          )
        ],
      ),
    );
  }
}

