#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <MGFaceIDLiveDetect/MGFaceIDLiveDetect.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    //flutter method channel
    FlutterViewController* controller = (FlutterViewController*) self.window.rootViewController;
       FlutterMethodChannel* methodChannel = [FlutterMethodChannel methodChannelWithName:@"faceid_plugin" binaryMessenger:controller.binaryMessenger];
       [methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
           dispatch_async(dispatch_get_main_queue(), ^{
               NSString * bizToken = call.arguments;
               NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
               MGFaceIDLiveDetectError* error;
               MGFaceIDLiveDetectManager* detectManager = [[MGFaceIDLiveDetectManager alloc] initMGFaceIDLiveDetectManagerWithBizToken: bizToken
                                                                                                                            language:MGFaceIDLiveDetectLanguageCh
                                                                                                                              networkHost:@"https://api.megvii.com"
                                                                                                                                extraData:nil
                                                                                                                                    error:&error];
                  if (error || !detectManager) {
                      [dic setObject: [NSNumber numberWithInt:error.errorType] forKey:@"code"];
                      [dic setObject: error.errorMessageStr forKey:@"message"];
                      result(dic);
                  }
                  //  可选方法-当前使用默认值
                  {
                      MGFaceIDLiveDetectCustomConfigItem* customConfigItem = [[MGFaceIDLiveDetectCustomConfigItem alloc] init];
                      [detectManager setMGFaceIDLiveDetectCustomUIConfig:customConfigItem];
                      [detectManager setMGFaceIDLiveDetectPhoneVertical:MGFaceIDLiveDetectPhoneVerticalFront];

                  }
                  
                  [detectManager startMGFaceIDLiveDetectWithCurrentController:controller
                                                                     callback:^(MGFaceIDLiveDetectError *error, NSData *deltaData, NSString *bizTokenStr, NSDictionary *extraOutDataDict) {
                                                            
                                                       [dic setObject: [NSNumber numberWithInt:error.errorType] forKey:@"code"];
                                                       [dic setObject: error.errorMessageStr forKey:@"message"];
                                                       if (deltaData != nil) {
                                                            [dic setObject: deltaData forKey:@"data"];
                                                       }
                                                        result(dic);
                                                                     }];
           });
       }];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
