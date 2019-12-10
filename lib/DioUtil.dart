import 'dart:math';

import 'package:dio/dio.dart';

class DioUtil {
  Dio dio = Dio();

  Future post(String url, FormData formData) async {
    try {
      Response response = await dio.post(url, data: formData);
     // print("${response.headers}");
      return response.data;
    } catch (e){
      print(e);
    }
  }
}