//
//  StoreDetailItem.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/11/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreTranslations : NSObject

@property (nonatomic, copy) NSString *cancel;
@property (nonatomic, copy) NSString *drivingDirectionsTitle;
@property (nonatomic, copy) NSString *getHelpTitle;
@property (nonatomic, copy) NSString *storeHours;

@property (nonatomic, copy) NSString *retailEventNotAvailable;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *specialHours;
@property (nonatomic, copy) NSString *yourLocationTitle;
@property (nonatomic, copy) NSString *drivingDirectionsShort;
@property (nonatomic, copy) NSString *retailNoReservationsError;
@property (nonatomic, copy) NSString *drivingDirectionsButtonTitle;
@property (nonatomic, copy) NSString *retailReservationAlreadyReservedError;

@property (nonatomic, copy) NSString *retailDayLimitExceedError;
@property (nonatomic, copy) NSString *getHelpFooter;
@property (nonatomic, copy) NSString *appleStoreTitle;
@property (nonatomic, copy) NSString *retailReservationNotValidError;
@property (nonatomic, copy) NSString *retailNoCustomerFoundError;
@property (nonatomic, copy) NSString *retailO2ONotAvailableError;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *appleStore;

@property (nonatomic, copy) NSString *call;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *retailMaxReservationLimitError;
@property (nonatomic, copy) NSString *allSpecialHours;
@property (nonatomic, copy) NSString *retailFavoriteLimitExceedError;
@property (nonatomic, copy) NSString *retailTimeNotAvaialbleError;

@property (nonatomic, copy) NSString *closed;
@property (nonatomic, copy) NSString *wsHeader;
@property (nonatomic, copy) NSString *retailServiceUnavailableError;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

@interface StoreExtraStoreInfo : NSObject

@property (nonatomic, assign) BOOL callStoreEnabled;
@property (nonatomic, copy) NSString *direction;

@property (nonatomic, copy) NSString *call;
@property (nonatomic, strong) NSArray *imageURL;
@property (nonatomic, copy) NSString *localizedStoreAddress;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *phoneNumberToDial;
@property (nonatomic, strong) NSDictionary *physicalAddress;

@property (nonatomic, copy) NSString *storeAddress;
@property (nonatomic, copy) NSString *storeLatitude;
@property (nonatomic, copy) NSString *storeLongitude;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *storeNumber;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

@interface StoreDetailItem : NSObject

@property (nonatomic, strong) StoreTranslations *translations;
@property (nonatomic, strong) StoreExtraStoreInfo *extraStoreInfo;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
