//
//  StoreTableViewCell.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "StoreTableViewCell.h"
#import "StoreItem.h"
#import "XYLocationManager.h"
#import "LocationConverter.h"
#import <UIImageView+WebCache.h>
#import <SDWebImageDownloader.h>
#import <SDImageCache.h>
#import "UIImage+XYImage.h"

@interface StoreTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *businessHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

@implementation StoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setStore:(StoreItem *)store {
    _store = store;
    
    self.storeNameLabel.text = store.storeName;
    self.cityLabel.text = store.city;
    self.businessHoursLabel.text = !store.enabled ? @"不营业" : @"上午10:00 - 下午10:00";
    UIImage *placeholderImage = [UIImage imageNamed:[NSString stringWithFormat:@"storeImage.bundle/%@", store.storeNumber]];
    NSString *iconURLString = store.deatilItem.extraStoreInfo.imageURL.firstObject;
    if (!placeholderImage) {
        NSURL *iconURL = [NSURL URLWithString:iconURLString];
        if (iconURL) {
            [self.iconView sd_setImageWithURL:iconURL placeholderImage:[UIImage imageNamed:@"applestore"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                self.iconView.image = image;
//                [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL.lastPathComponent toDisk:YES completion:^{
//
//                }];
            }];
        }
        
    }
    else {
        self.iconView.image = placeholderImage;
    }
    
//    UIImage *image = [self.iconView.image scaleToSize:CGSizeMake(640, 480)];
//    [[SDImageCache sharedImageCache] storeImage:image forKey:[store.deatilItem.extraStoreInfo.imageURL.firstObject lastPathComponent] toDisk:YES completion:^{
//        
//    }];
    
//   double distance = [LocationConverter LantitudeLongitudeDist:[store.longitude doubleValue] other_Lat:[store.latitude doubleValue] self_Lon:[XYLocationManager sharedManager].longitude self_Lat:[XYLocationManager sharedManager].latitude];
//    self.distanceLabel.text = [NSString stringWithFormat:@"%f KM",distance/1000]; // 公里
    self.distanceLabel.text = store.deatilItem.extraStoreInfo.localizedStoreAddress;
}

- (void)layoutSubviews
    {
        for (UIControl *control in self.subviews){
            if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
                for (UIView *v in control.subviews)
                {
                    if ([v isKindOfClass: [UIImageView class]]) {
                        UIImageView *img=(UIImageView *)v;
                        if (self.selected) {
                            img.image=[UIImage imageNamed:@"xuanzhong_icon"];
                        }else
                        {
                            img.image=[UIImage imageNamed:@"weixuanzhong_icon"];
                        }
                    }
                }
            }
        }
        [super layoutSubviews];
    }
    
    
    //适配第一次图片为空的情况
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
    {
        [super setEditing:editing animated:animated];
        for (UIControl *control in self.subviews){
            if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
                for (UIView *v in control.subviews)
                {
                    if ([v isKindOfClass: [UIImageView class]]) {
                        UIImageView *img=(UIImageView *)v;
                        if (!self.selected) {
                            img.image=[UIImage imageNamed:@"weixuanzhong_icon"];
                        }
                    }
                }
            }
        }
        
    }


@end
