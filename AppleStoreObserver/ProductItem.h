//
//  ProductItem.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductAvailability;

@interface ProductItem : NSObject

@property (nonatomic, copy) NSString *partNumber;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *capacity;
@property (nonatomic, assign) double screenSize;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *installmentPrice;
@property (nonatomic, copy) NSString *installmentPeriod;
@property (nonatomic, copy) NSString *iUPPrice;
@property (nonatomic, copy) NSString *iUPInstallments;
@property (nonatomic, copy) NSString *colorSortOrder;
@property (nonatomic, copy) NSString *swatchImage;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) BOOL contractEnabled;
@property (nonatomic, assign) BOOL unlockedEnabled;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *subfamilyID;
@property (nonatomic, copy) NSString *subfamily;
@property (nonatomic, strong) ProductAvailability *productAvailability;

- (instancetype)initWithJsonDict:(NSDictionary *)dict;

@end
