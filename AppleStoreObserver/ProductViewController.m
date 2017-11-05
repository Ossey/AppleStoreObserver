//
//  ProductViewController.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductTableViewCell.h"
#import <AFNetworking.h>
#import "ProductItem.h"
#import "StoreItem.h"
#import "ProductAvailability.h"
#import "OSLoaclNotificationHelper.h"
#import "UIAlertView+Blocks.h"
#import "StoreViewController.h"

static NSString * const availability = @"https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhoneX/availability.json";


@interface ProductViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBInspectable UITableView *tableView;
@property (strong, nonatomic) UIView            *editingView;
@property (nonatomic, strong) NSMutableArray<ProductItem *> *productArray;
@property (nonatomic, weak) UIButton *rightBarButton;
@property (nonatomic, strong) NSTimer *observerTimer;
@property (nonatomic, strong) NSMutableArray *selectedPartNumbers;
@property (nonatomic, strong) NSURL *reserveURL;
@property (nonatomic, strong) UIButton *monitorButton;
/// 需要监测的商店
@property (nonatomic, strong) NSMutableDictionary<NSString *, StoreItem *>  *selectStores;
@property (nonatomic, assign) BOOL shouldStartMonitor;
@end

@implementation ProductViewController {
    __weak NSLayoutConstraint *_editViewBottomConstraint;
}

static NSString *const cellIdentifier = @"ProductTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _productArray = @[].mutableCopy;
    _selectedPartNumbers = @[].mutableCopy;
    self.title = @"商品列表";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ProductTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self loadProducts];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"监测" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarItemClick:)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView.allowsMultipleSelection = YES;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.editingView];
    [self makeConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self endMonitor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldStartMonitor) {
        [self startMonitor];
    }
}
    
- (void)rightBarItemClick:(UIBarButtonItem *)item{
    if ([item.title isEqualToString:@"监测"]) {
        if (self.productArray.count == 0) {
            return;
        }
        item.title = @"取消";
        [self.tableView setEditing:YES animated:YES];
        [self showEitingView:YES];
    } else {
        item.title = @"监测";
        [self.tableView setEditing:NO animated:YES];
        [self showEitingView:NO];
        [self.selectedPartNumbers removeAllObjects];
    }
    if ([[self.monitorButton titleForState:UIControlStateNormal] isEqualToString:@"停止监测"]) {
        [self p__buttonClick:self.monitorButton];
    }
}

- (void)setStore:(StoreItem *)store {
    _store = store;
    if (!self.selectStores) {
        self.selectStores = @[].mutableCopy;
    }
    if (!store) {
        return;
    }
    [self.selectStores setObject:store forKey:store.storeNumber];
    
}

- (NSMutableDictionary *)selectStores {
    if (!_selectStores) {
        _selectStores = @{}.mutableCopy;
    }
    return _selectStores;
}
    
////////////////////////////////////////////////////////////////////////
#pragma mark - event response
////////////////////////////////////////////////////////////////////////
    
- (void)p__buttonClick:(UIButton *)sender{
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"开始监测"]) {
        
        self.view.userInteractionEnabled = NO;
        NSMutableIndexSet *insets = [[NSMutableIndexSet alloc] init];
        [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [insets addIndex:obj.row];
        }];
        self.shouldStartMonitor = YES;
        [self startMonitor];

        [sender setTitle:@"停止监测" forState:UIControlStateNormal];
        /** 数据清空情况下取消监测状态*/
        if (self.productArray.count == 0) {
            self.navigationItem.rightBarButtonItem.title = @"监测";
            [self.tableView setEditing:NO animated:YES];
            [self showEitingView:NO];
        }
        self.view.userInteractionEnabled = YES;
        
    }
    else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"停止监测"]) {
        self.view.userInteractionEnabled = NO;
        self.shouldStartMonitor = NO;
        [sender setTitle:@"开始监测" forState:UIControlStateNormal];
        [self endMonitor];
        self.view.userInteractionEnabled = YES;
    }
    else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"全选"]) {
        [self.productArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self selectProduct:obj];
        }];
        [sender setTitle:@"全不选" forState:UIControlStateNormal];
    } else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"全不选"]){
        [self.tableView reloadData];
        // 遍历反选
//        [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self.tableView deselectRowAtIndexPath:obj animated:NO];
//        }];
        [self.selectedPartNumbers removeAllObjects];
        
        [sender setTitle:@"全选" forState:UIControlStateNormal];
        
    } else if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"选择商店"]) {
        UINavigationController *vc = [StoreViewController editModeStoreViewControllerWithStores:self.allStores completion:^(NSDictionary<NSString *,StoreItem *> *editStores) {
            
            if (editStores) {
                [self.selectStores addEntriesFromDictionary:editStores];
            }
        }];
        [self showDetailViewController:vc sender:self];
    }
}
    
    
- (void)showEitingView:(BOOL)isShow{
    _editViewBottomConstraint.constant = isShow ? 0.0 : 45.0;

    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)startMonitor {
    if (!_observerTimer) {
        _observerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(requestAvailabilityProduct) userInfo:nil repeats:YES];
        [_observerTimer fire];
        self.navigationItem.title = @"商品列表(监测中)";
    }
}

- (void)endMonitor {
    if (_observerTimer) {
        [_observerTimer invalidate];
        _observerTimer = nil;
        self.navigationItem.title = @"商品列表(未监测)";
    }
}

/// 请求有效的可预订的产品
- (void)requestAvailabilityProduct {
    [[AFHTTPSessionManager manager] GET:availability parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.selectStores enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, StoreItem * _Nonnull store, BOOL * _Nonnull stop) {
            NSString *storeNum = store.storeNumber;
            NSDictionary *stores = responseObject[@"stores"];
            NSDictionary *dictArray = stores[storeNum];
            [dictArray enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull partNumber, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ProductItem *item = [self getProductByPartNumber:partNumber];
                if (item) {
                    ProductAvailability *availability = [[ProductAvailability alloc] initWithPartNumber:partNumber dict:obj];
                    item.productAvailability = availability;
                    if ((availability.contract || availability.unlocked) &&
                        [self.selectedPartNumbers containsObject:partNumber]) {
                        NSString *urlString = [NSString stringWithFormat:@"https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhoneX/availability?channel=1&returnURL=&store=%@&partNumber=%@", store.storeNumber, item.partNumber];
                        NSDictionary *dict = @{@"partNumber": item.partNumber, @"storeName": store.storeName, @"description": item.description_, @"urlString": urlString};
                        [[OSLoaclNotificationHelper sharedInstance] sendLocalNotificationWithMessageDict:dict];
                    }
                }
            }];
        }];
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (ProductItem *)getProductByPartNumber:(NSString *)partNumber {
    
    NSUInteger foudIdx = [self.productArray indexOfObjectPassingTest:^BOOL(ProductItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [obj.partNumber isEqualToString:partNumber];
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    ProductItem *product = nil;
    if (foudIdx != NSNotFound) {
         product = [self.productArray objectAtIndex:foudIdx];
    }
    return product;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - load data
////////////////////////////////////////////////////////////////////////

- (void)loadProducts {
    
    NSString *productPath = [[NSBundle mainBundle] pathForResource:@"Products" ofType:@"json"];
    NSData *productData = [NSData dataWithContentsOfFile:productPath];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:productData options:NSJSONReadingMutableContainers error:&error];
    NSArray *products = jsonDict[@"products"];
    [self.productArray removeAllObjects];
    for (NSDictionary *product in products) {
        [self.productArray addObject:[[ProductItem alloc] initWithJsonDict:product]];
    }

    [self.tableView reloadData];
}



////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate, UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.productArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.product = self.productArray[indexPath.row];
    
    NSUInteger foundIndx = [self.selectedPartNumbers indexOfObjectPassingTest:^BOOL(NSString *  _Nonnull numbers, NSUInteger idx, BOOL * _Nonnull stop) {
        return [numbers isEqualToString:cell.product.partNumber];
    }];
    if (self.selectedPartNumbers.count && foundIndx != NSNotFound) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    cell.longGesOnCell = ^(ProductTableViewCell *cell, UILongPressGestureRecognizer *longGes) {
        if (tableView.isEditing) {
            UIAlertController *alertController = ({
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"请选择"
                                            message:nil
                                            preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"取消选中"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                                        }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"预定"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            ProductItem *item = [self.productArray objectAtIndex:indexPath.row];
                                                            if (!item) {
                                                                return;
                                                            }
                                                            NSString *urlString = [NSString stringWithFormat:@"https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhoneX/availability?channel=1&returnURL=&store=%@&partNumber=%@", self.store.storeNumber, item.partNumber];
                                                            NSURL *url = [NSURL URLWithString:urlString];
                                                            if (@available(iOS 10.0, *)) {
                                                                [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
                                                                    
                                                                }];
                                                            } else {
                                                                [[UIApplication sharedApplication] openURL:url];
                                                            }
                                                        }]];
                
                alert;
            });
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    };
    
    return cell;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.isEditing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        });
        
        ProductItem *item = [self.productArray objectAtIndex:indexPath.row];
        [self selectProduct:item];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [tableView deselectRowAtIndexPath:indexPath animated:YES];
        });
        ProductItem *item = [self.productArray objectAtIndex:indexPath.row];
        [self deSelectProduct:item];
    }
}
    
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

- (void)selectProduct:(ProductItem *)product {
    NSIndexSet *indexSet = [self.selectedPartNumbers indexesOfObjectsPassingTest:^BOOL(NSString *  _Nonnull numbers, NSUInteger idx, BOOL * _Nonnull stop) {
        return [numbers isEqualToString:product.partNumber];
    }];
    if (!indexSet.count) {
        [self.selectedPartNumbers addObject:product.partNumber];
    }
}

- (void)deSelectProduct:(ProductItem *)product {
    NSUInteger foundIndx = [self.selectedPartNumbers indexOfObjectPassingTest:^BOOL(NSString *  _Nonnull numbers, NSUInteger idx, BOOL * _Nonnull stop) {
        return [numbers isEqualToString:product.partNumber];
    }];
    if (self.selectedPartNumbers.count && foundIndx != NSNotFound) {
        [self.selectedPartNumbers removeObjectAtIndex:foundIndx];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (UIView *)editingView{
    if (!_editingView) {
        _editingView = [[UIView alloc] init];
        _editingView.translatesAutoresizingMaskIntoConstraints = NO;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor redColor];
        [button setTitle:@"开始监测" forState:UIControlStateNormal];
        self.monitorButton = button;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p__buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editingView addSubview:button];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [_editingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:kNilOptions metrics:nil views:@{@"button": button}]];
        [_editingView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_editingView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
         [_editingView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_editingView attribute:NSLayoutAttributeWidth multiplier:0.33 constant:0.0]];
    
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor darkGrayColor];
        [button setTitle:@"全选" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p__buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editingView addSubview:button];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [_editingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:kNilOptions metrics:nil views:@{@"button": button}]];
        [_editingView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_editingView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [_editingView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_editingView attribute:NSLayoutAttributeWidth multiplier:0.33 constant:0.0]];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor blackColor];
        [button setTitle:@"选择商店" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p__buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editingView addSubview:button];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [_editingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:kNilOptions metrics:nil views:@{@"button": button}]];
        [_editingView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_editingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [_editingView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_editingView attribute:NSLayoutAttributeWidth multiplier:0.33 constant:0.0]];
    }
    return _editingView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}
    
- (void)makeConstraints {
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:kNilOptions metrics:nil views:@{@"tableView": self.tableView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.editingView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[editingView]|" options:kNilOptions metrics:nil views:@{@"editingView": self.editingView}]];
    
    NSLayoutConstraint *editViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.editingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom  multiplier:1.0 constant:45.0];
    _editViewBottomConstraint = editViewBottomConstraint;
    [self.view addConstraint:editViewBottomConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.editingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute  multiplier:1.0 constant:45.0]];
    
}


@end
