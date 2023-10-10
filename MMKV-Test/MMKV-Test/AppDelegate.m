//
//  AppDelegate.m
//  MMKV-Test
//
//  Created by 岳云石 on 2023/9/18.
//

#import "AppDelegate.h"
@import MMKV;
@import CocoaLumberjack;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 添加DDASLLogger，你的日志语句将被发送到Xcode控制台
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // 添加DDFileLogger，你的日志语句将写入到一个文件中，默认路径在沙盒的[fileLogger.logFileManager logsDirectory]目录下，文件名为bundleid+空格+日期.log。
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    // 刷新频率为24小时
    fileLogger.rollingFrequency = 60 * 60 * 24;
    // 最多同事包含的文件数量
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
