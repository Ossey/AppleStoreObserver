//
//  ProductTableViewCell.h
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductItem;

@interface ProductTableViewCell : UITableViewCell

@property (nonatomic, strong) ProductItem *product;

@property (nonatomic, copy) void (^ longGesOnCell)(ProductTableViewCell *cell, UILongPressGestureRecognizer *longGes);

@end
