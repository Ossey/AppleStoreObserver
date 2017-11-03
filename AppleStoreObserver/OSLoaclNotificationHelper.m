//
//  OSLoaclNotificationHelper.m
//  OSFileDownloader
//
//  Created by Swae on 2017/10/22.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "OSLoaclNotificationHelper.h"

@interface OSLoaclNotificationHelper ()

@end

@implementation OSLoaclNotificationHelper

@dynamic sharedInstance;

+ (OSLoaclNotificationHelper *)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [OSLoaclNotificationHelper new];
    });
    return _instance;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)registerLocalNotification {
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
}

/// 发送本地通知
- (void)sendLocalNotificationWithMessageDict:(NSDictionary *)messageDict {
    self.notifyDict = messageDict;
    UILocalNotification *localNotification = [UILocalNotification new];
//    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:5];
    NSString *message = [NSString stringWithFormat:@"可预定店面:%@, 产品型号:%@", messageDict[@"storeName"], messageDict[@"partNumber"]];
    // 如果不设置alertBody，则不会在通知栏显示
    localNotification.alertBody = [NSString stringWithFormat:@"有货通知:\n%@", message];
    localNotification.alertAction = @"预定";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 0;
    localNotification.repeatInterval = 0;
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    // 立即触发
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}


@end
