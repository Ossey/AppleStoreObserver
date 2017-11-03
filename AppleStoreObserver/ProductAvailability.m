//
//  ProductAvailability.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/27.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ProductAvailability.h"

@implementation ProductAvailability

- (instancetype)initWithPartNumber:(NSString *)partNumber dict:(NSDictionary *)dict; {
    if (self = [super init]) {
        self.partNumber = partNumber;
        BOOL contract = dict[@"availability"]? [dict[@"availability"][@"contract"] boolValue] : NO;
        BOOL unlocked = dict[@"availability"]? [dict[@"availability"][@"unlocked"] boolValue] : NO;
        self.contract = contract;
        self.unlocked = unlocked;
    }
    return self;
}

@end

