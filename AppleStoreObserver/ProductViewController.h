//
//  ViewController.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreItem.h"

@interface ProductViewController : UIViewController

/// 当期页面进入时的store
@property (nonatomic, strong) StoreItem *store;
/// 所有商店
@property (nonatomic, strong) NSArray *allStores;

@end

