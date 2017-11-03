//
//  ProductTableViewCell.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "ProductItem.h"
#import "ProductAvailability.h"

@interface ProductTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *capacityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGes;
@end

@implementation ProductTableViewCell

- (void)setProduct:(ProductItem *)product {
    _product = product;
    
    self.nameLabel.text = product.description_;
    self.modelLabel.text = product.partNumber;
    self.capacityLabel.text = product.capacity;
    if (product.productAvailability.contract || product.productAvailability.unlocked) {
        self.stateLabel.text = @"有货";
    }
    else {
        self.stateLabel.text =  @"无货";
    }
    
}

- (UILongPressGestureRecognizer *)longGes {
    if (!_longGes) {
        _longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesOnSelf:)];
    }
    return _longGes;
}

- (void)longGesOnSelf:(UILongPressGestureRecognizer *)ges {
    if (self.longGesOnCell) {
        self.longGesOnCell(self, ges);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self addGestureRecognizer:self.longGes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
