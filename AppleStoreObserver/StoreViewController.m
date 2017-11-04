//
//  StoreViewController.m
//  AppleStoreObserver
//
//  Created by Swae on 2017/10/26.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "StoreViewController.h"
#import "StoreItem.h"
#import <AFNetworking.h>
#import "StoreTableViewCell.h"
#import "ProductViewController.h"
#import <UIScrollView+NoDataExtend.h>

static NSString * const stores = @"https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhoneX/stores.json";

@interface StoreViewController () <UITableViewDelegate, UITableViewDataSource, NoDataPlaceholderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<StoreItem *> *storeArray;
@property (nonatomic, strong) dispatch_group_t loadDetailGroup;

@end

@implementation StoreViewController

static NSString *cellIdentifier = @"StoreTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"零售店";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([StoreTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    _loadDetailGroup = dispatch_group_create();
    [self loadStores];
    [self setupNodataView];
}

- (void)loadStores {
    self.tableView.xy_loading = YES;
    [[AFHTTPSessionManager manager] GET:stores parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *storesJson = responseObject[@"stores"];
        NSMutableArray *storeArray = @[].mutableCopy;
        for (NSDictionary *store in storesJson) {
            [storeArray addObject:[[StoreItem alloc] initWithJsonDict:store]];
        }
        self.storeArray = storeArray.copy;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.tableView.xy_loading = NO;
        });
        
        // 请求store详情
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.storeArray enumerateObjectsUsingBlock:^(StoreItem * _Nonnull store, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_group_enter(_loadDetailGroup);
                [self loadStoreDetailWithStoreNumber:store.storeNumber completionHandler:^(StoreDetailItem *detailItem) {
                    dispatch_group_leave(_loadDetailGroup);
                    if ([store.storeNumber isEqualToString:detailItem.extraStoreInfo.storeNumber]) {
                        store.deatilItem = detailItem;
                    }
                }];
            }];

            dispatch_group_wait(_loadDetailGroup, DISPATCH_TIME_FOREVER);

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.tableView.xy_loading = NO;
    }];
}

- (void)loadStoreDetailWithStoreNumber:(NSString *)storeNumber completionHandler:(void (^)(StoreDetailItem *detailItem))completion {
    if (!storeNumber || !completion) {
        return;
    }
    NSString *url = @"https://mobileapp.apple.com/mnr/p/cn/retail/storeDetails";
    NSDictionary *parameters = @{@"storeNumber": storeNumber};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc] init];
    [request setValue:@"as_dc=nc; iupDeviceStatus=0; as_cn=5a2d6L+c~d7ce4821536a5e091e7afe44196f82050912a688df64702a243b730a721f5ad3; as_disa=SU29XHPX29AP447YJFT24DCTJCP22F9HHCCA49DTYPH27A2JXK2UTKFUT9AYFDTC2AJUH72D29F2H77279DPK7CAPJ2AJ7HX9KF477249UCXP2D97KHH2HYX7JHX7DYK4PPC7J4K72FJUX2XAFJCU9JAY9J7JCK4U; as_rec=S947AKKH2FDP7FCP7477F7J9UDHPJ4CUD; rdcStatus=1; iupstatus=false; dssf=1; dssid2=1bdd3d2d-aaa0-4f56-9c09-18c670acdf5b" forHTTPHeaderField:@"Cookie"];
    [request setValue:@"934b3d4ef595739bd317b3021200c427d642f9c0" forHTTPHeaderField:@"X-Mme-Device-Id"];
    [request setValue:@"ss=2.61;dim=1080x1920;m=iPhone;v=iPhone10,2;vv=4.3.1;sv=11.0.3" forHTTPHeaderField:@"X-DeviceConfiguration"];
    [request setValue:@"ASA/4.3.1 (iPhone) ss/2.61" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"NWbFWmklqKCHfWEANklJYewwmjj2tWdqjAdVW+Zdo8CRqVKghcPzReFd4KFO5QNN5eKW9f/yNqTGy3sa" forHTTPHeaderField:@"X-Apple-I-MD-M"];
    [request setValue:@"REL-4.3.1" forHTTPHeaderField:@"x-ma-pcmh"];
    [request setValue:@"AAAABQAAABDybpQLEDXO12/zgbNLLqkCAAAAAw==" forHTTPHeaderField:@"X-Apple-I-MD"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [manager setRequestSerializer:request];
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!responseObject) {
            completion(nil);
        }
        else {
            StoreDetailItem *item = [[StoreDetailItem alloc] initWithDict:responseObject];
            completion(item);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil);
    }];
    
    // HTTP请求即将重定向时调用
   [manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
       if (request) {
           return request;
       }
       return nil;
    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate, UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.storeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    StoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.store = self.storeArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoreboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProductViewController *vc = [mainStoreboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
    vc.store = self.storeArray[indexPath.row];
    [self.navigationController showViewController:vc sender:self];
}
    

- (void)setupNodataView {
    __weak typeof(self) weakSelf = self;
    
    self.tableView.noDataPlaceholderDelegate = self;
    
    self.tableView.customNoDataView = ^UIView * _Nonnull{
        if (weakSelf.tableView.xy_loading) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityView startAnimating];
            return activityView;
        }
        else {
            return nil;
        }
        
    };
    
    self.tableView.noDataTextLabelBlock = ^(UILabel * _Nonnull textLabel) {
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:27.0];
        textLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.numberOfLines = 0;
        textLabel.text = @"加载商品出错";
    };

    
    self.tableView.noDataReloadButtonBlock = ^(UIButton * _Nonnull reloadButton) {
        reloadButton.backgroundColor = [UIColor clearColor];
        reloadButton.layer.borderWidth = 0.5;
        reloadButton.layer.borderColor = [UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0].CGColor;
        reloadButton.layer.cornerRadius = 2.0;
        [reloadButton.layer setMasksToBounds:YES];
        [reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
        [reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    };
    
    
    self.tableView.noDataTextEdgeInsets = UIEdgeInsetsMake(20, 0, 20, 0);
    self.tableView.noDataButtonEdgeInsets = UIEdgeInsetsMake(20, 100, 11, 100);
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NoDataPlaceholderDelegate
////////////////////////////////////////////////////////////////////////

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button {
    [self loadStores];
}

- (BOOL)noDataPlaceholderShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}


- (CGPoint)contentOffsetForNoDataPlaceholder:(UIScrollView *)scrollView {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        return CGPointMake(0.0, 80.0);
    }
    return CGPointMake(0.0, 30.0);
}


- (void)noDataPlaceholderWillAppear:(UIScrollView *)scrollView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)noDataPlaceholderDidDisappear:(UIScrollView *)scrollView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (BOOL)noDataPlaceholderShouldFadeInOnDisplay:(UIScrollView *)scrollView {
    return YES;
}


@end
