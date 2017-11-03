//
//  ProductItem.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ProductItem.h"

@implementation ProductItem

- (instancetype)initWithJsonDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        self.description_ = value;
    }
    else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

@end
