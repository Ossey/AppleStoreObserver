//
//  StoreViewController.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;

@interface StoreViewController : UIViewController

+ (UINavigationController *)editModeStoreViewControllerWithStores:(NSArray *)stores completion:(void (^)(NSDictionary<NSString *, StoreItem *> *editStores))completion;

@end
