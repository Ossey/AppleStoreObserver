//
//  OSLoaclNotificationHelper.h
//  OSFileDownloader
//
//  Created by Swae on 2017/10/22.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSLoaclNotificationHelper : NSObject

@property (nonatomic, strong, class) OSLoaclNotificationHelper *sharedInstance;

/// 通知的内容
@property (nonatomic, strong) NSDictionary *notifyDict;
/// 注册本地通知
- (void)registerLocalNotification;
/// 发送本地通知
- (void)sendLocalNotificationWithMessageDict:(NSDictionary *)messageDict;

@end
