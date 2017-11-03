//
//  ProductAvailability.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/27.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductAvailability : NSObject

@property (nonatomic, copy) NSString *partNumber;
@property (nonatomic, assign) BOOL contract;
@property (nonatomic, assign) BOOL unlocked;

- (instancetype)initWithPartNumber:(NSString *)partNumber dict:(NSDictionary *)dict;

@end
