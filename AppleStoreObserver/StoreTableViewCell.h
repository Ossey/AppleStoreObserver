//
//  StoreTableViewCell.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;

@interface StoreTableViewCell : UITableViewCell

@property (nonatomic, strong) StoreItem *store;

@end
