package com.zzexvip.faceid_plugin;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.megvii.meglive_sdk.listener.DetectCallback;
import com.megvii.meglive_sdk.listener.PreCallback;
import com.megvii.meglive_sdk.manager.MegLiveManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.*;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.os.Build.VERSION_CODES.M;

public class MainActivity extends FlutterActivity implements PreCallback, DetectCallback, MethodCallHandler{

  private static final String CHANNEL = "faceid_plugin";
  private static final int CAMERA_PERMISSION_REQUEST_CODE = 100;
  private static final int EXTERNAL_STORAGE_REQ_WRITE_EXTERNAL_STORAGE_CODE = 101;
  private static final String TAG = "MainActivity";
  private MegLiveManager megLiveManager;
  private String bizToken;
  private Result result;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MethodChannel methodChannel = new MethodChannel(getFlutterView(), CHANNEL);
    methodChannel.setMethodCallHandler(this);
    init();
    GeneratedPluginRegistrant.registerWith(this);
  }

  private void init() {
    megLiveManager =  MegLiveManager.getInstance();
  }

  @Override
  public void onMethodCall(@NonNull  MethodCall methodCall, @NonNull Result result) {
    this.result = result;
    if (methodCall.method.equals("bizToken")) {
      bizToken = methodCall.arguments.toString();
      requestCameraPerm();
    } else {
      result.notImplemented();
    }
  }


  @Override
  public void onPreStart() { }

  @Override
  public void onPreFinish(String token, int errorCode, String errorMessage) {
    if (errorCode == 1000) {
      megLiveManager.setVerticalDetectionType(MegLiveManager.DETECT_VERITICAL_FRONT);
      megLiveManager.startDetect(this);
    } else {
      result(errorCode, errorMessage, null);
    }
  }
  @Override
  public void onDetectFinish(String token, int errorCode, String errorMessage, String data) {
       result(errorCode, errorMessage, data);
  }

  private void beginDetect() {
    megLiveManager.preDetect(MainActivity.this, bizToken, "zh","https://api.megvii.com", MainActivity.this);
  }

  /**
   *
   * @param code
   * @param message
   * @param data
   */
  private void result(int code, String message, String data) {
    HashMap<String, Object> resultMap = new HashMap<String, Object>();
    resultMap.put("code",code);
    resultMap.put("message",message);
    resultMap.put("data",data);
    result.success(resultMap);
  }

  private void requestCameraPerm() {
    if (android.os.Build.VERSION.SDK_INT >= M) {
      if (checkSelfPermission(Manifest.permission.CAMERA)
              != PackageManager.PERMISSION_GRANTED) {
        //进行权限请求
        requestPermissions(
                new String[]{Manifest.permission.CAMERA},
                CAMERA_PERMISSION_REQUEST_CODE);
      } else {
        requestWriteExternalPerm();
      }
    } else {
      beginDetect();
    }
  }

  private void requestWriteExternalPerm() {
    if (android.os.Build.VERSION.SDK_INT >= M) {
      if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
        //进行权限请求
        requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                EXTERNAL_STORAGE_REQ_WRITE_EXTERNAL_STORAGE_CODE);
      } else {
        beginDetect();
      }
    } else {
      beginDetect();
    }
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
      if (grantResults.length < 1 || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
        //拒绝了权限申请
      } else {
        requestWriteExternalPerm();
      }
    } else if (requestCode == EXTERNAL_STORAGE_REQ_WRITE_EXTERNAL_STORAGE_CODE) {
      if (grantResults.length < 1 || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
        //拒绝了权限申请
      } else {
        beginDetect();
      }
    }
  }
}
