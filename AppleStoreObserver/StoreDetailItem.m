//
//  StoreDetailItem.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/11/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "StoreDetailItem.h"

@implementation StoreTranslations

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}


@end

@implementation StoreExtraStoreInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

@end

@implementation StoreDetailItem

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"translations"]) {
        self.translations = [[StoreTranslations alloc] initWithDict:value];
    }
    else if ([key isEqualToString:@"extraStoreInfo"]) {
        self.extraStoreInfo = [[StoreExtraStoreInfo alloc] initWithDict:value];
    }
    else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

@end
