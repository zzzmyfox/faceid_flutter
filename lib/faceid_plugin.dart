import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FaceidPlugin {
  /// MethodChannel  flutter to native
  /// {code: 1000, message: LIVENESS_FINISH, data: []}
  static const MethodChannel _methodChannel = const MethodChannel('faceid_plugin');
  static Future<dynamic> faceIDDetector({@required String bizToken}) async {
    final result = await _methodChannel.invokeMethod('bizToken', bizToken);
    return result;
  }
}