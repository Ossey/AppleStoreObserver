//
//  StoreItem.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreDetailItem.h"

@interface StoreItem : NSObject

@property (nonatomic, copy) NSString *storeNumber;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) StoreDetailItem *deatilItem;

- (instancetype)initWithJsonDict:(NSDictionary *)dict;
@end
