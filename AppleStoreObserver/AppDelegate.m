//
//  AppDelegate.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "AppDelegate.h"
#import "XYLocationManager.h"
#import "OSLoaclNotificationHelper.h"

@interface AppDelegate ()  {
    UIBackgroundTaskIdentifier _bgTask;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[XYLocationManager sharedManager] getAuthorization];
    [[XYLocationManager sharedManager] startLocation];

    /// 注册本地通知
    [[OSLoaclNotificationHelper sharedInstance] registerLocalNotification];
    
    UILocalNotification *localNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        // 当程序启动时，就有本地通知需要推送，就手动调用一次didReceiveLocalNotification
        [self application:application didReceiveLocalNotification:localNotification];
    }
    
    
    return YES;
}

/// 此方法是本地通知会触发的方法，当点击通知横幅进入app时会调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    
    // 取消所有通知
    [application cancelAllLocalNotifications];
    NSDictionary *dict = [OSLoaclNotificationHelper sharedInstance].notifyDict;
//    NSString *message = [NSString stringWithFormat:@"可预定店面:%@, 产品型号:%@, 产品描述:%@", dict[@"storeName"], dict[@"partNumber"], dict[@"description"]];
    NSString *urlString = dict[@"urlString"];
    NSURL *url = [NSURL URLWithString:urlString];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    // 点击通知后，就让图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

/// 当有电话进来或者锁屏，此时应用程会挂起，调用此方法，此方法一般做挂起前的工作，比如关闭网络，保存数据
- (void)applicationWillResignActive:(UIApplication *)application {
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    _bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        
        // 10分钟后执行这里，应该进行一些清理工作，如断开和服务器的连接等
        // stopped or ending the task outright.
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    if (_bgTask == UIBackgroundTaskInvalid) {
        NSLog(@"failed to start background task!");
    }
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        NSTimeInterval timeRemain = 0;
        do {
            [NSThread sleepForTimeInterval:5];
            if (_bgTask != UIBackgroundTaskInvalid) {
                timeRemain = [application backgroundTimeRemaining];
                NSLog(@"Time remaining: %f",timeRemain);
            }
        } while(_bgTask!= UIBackgroundTaskInvalid && timeRemain > 0);
        // 如果改为timeRemain > 5*60,表示后台运行5分钟
        // done!
        // 如果没到10分钟，也可以主动关闭后台任务，但这需要在主线程中执行，否则会出错
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_bgTask != UIBackgroundTaskInvalid) {
                // 和上面10分钟后执行的代码一样
                // if you don't call endBackgroundTask, the OS will exit your app.
                [application endBackgroundTask:_bgTask];
                _bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 如果没到10分钟又打开了app,结束后台任务
    if (_bgTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
