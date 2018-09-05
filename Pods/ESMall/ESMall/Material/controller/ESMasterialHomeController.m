//
//  ESMasterialHomeController.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMasterialHomeController.h"
#import "LoopCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"
#import "GrayFooterCollectionReusableView.h"
#import "ESDiyRefreshHeader.h"
#import "Assistant.h"
#import "CheckMoreReusableView.h"
#import "GoodsItemCell.h"
#import "ESMasterTypeCollectionViewCell.h"
#import "ESSelectListViewController.h"
#import "ESNoMoreReusableView.h"

#import "JRLocationServices.h"

#import <CoreLocation/CoreLocation.h>
#import "ESOrderAPI.h"
#import <MBProgressHUD.h>

#import "ESMasterSearchController.h"
#import "ESRegionManager.h"

#import "ESMakeSureCustomOrderController.h"
#import "ESLiWuMarketController.h"
#import "MBProgressHUD+NJ.h"
#import <ESFoundation/UMengServices.h>
#import "ESShoppingCartController.h"
#import "ESMaterialHomeModel.h"
#import "MJRefreshGifHeader+Stec.h"

@interface ESMasterialHomeController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (strong, nonatomic) NSMutableArray *showCaseDatas;
@property (strong, nonatomic) NSMutableArray *datasSourse;
@property (strong, nonatomic) NSMutableDictionary *totalDic;
@property (strong, nonatomic) JRLocationServices *locationService;
@property (assign, nonatomic) BOOL hiddenTabbar;
@property (strong, nonatomic)SDCycleScrollView *loopView;
@property(nonatomic,strong) UISearchController *svc;

@property (strong, nonatomic) NSMutableArray *typeListArray;

@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ESMasterialHomeController

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = NO;
        [self.view addSubview:_hud];
    }
    [self.view bringSubviewToFront:_hud];
    return _hud;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WS(weakSelf)
    [self configTimer];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [userDefaults objectForKey:@"app_location_key"];
    if (status
        && [status isKindOfClass:[NSString class]]
        && [status isEqualToString:@"NO"])
    {
        [self getData];
        return;
    }
    
    CLAuthorizationStatus type = [CLLocationManager authorizationStatus];
    if (![CLLocationManager locationServicesEnabled] || type == kCLAuthorizationStatusDenied) {
        SHLog(@"做处理");
        [self showNoDataIn:self.view imgName:@"nodata_location" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT) Title:@"您需要打开定位权限,\n才可以进入商城查看哦~" buttonTitle:@"去设置" Block:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [self showLocationAlertView];
    } else {
        //        if (_locationService.locationCityInfo.cityCode == nil || [_locationService.locationCityInfo.cityCode isEqualToString:@""]) {
        [_locationService requestLocation:^(JRCityInfo *cityInfo) {
            if (cityInfo.cityCode.length>0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *oldName = [weakSelf.menuLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([oldName isEqualToString:cityInfo.locatedCityName]) {
                    } else {
                        [weakSelf removeNoDataView];
                        [self getServer];
                    }
                    weakSelf.menuLabel.text = [NSString stringWithFormat:@"       %@", cityInfo.locatedCityName ? cityInfo.locatedCityName : @""];
                    
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.menuLabel.text = [NSString stringWithFormat:@"       %@", cityInfo.locatedCityName ? cityInfo.locatedCityName : @""];
                    [weakSelf getServer];
                });
            }
        }];
        //        } else {
        //            self.menuLabel.text = [NSString stringWithFormat:@"        %@", _locationService.locationCityInfo.locatedCityName ? _locationService.locationCityInfo.locatedCityName : @""];
        //            [weakSelf getServer];
        //        }
        
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"商城";
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.menuLabel.textColor = [UIColor stec_subTitleTextColor];
    _locationService = [JRLocationServices sharedInstance];
    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
    if ([appType isEqualToString:@"MALL"]) {
        [self.rightButton setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal];
    } else {
        [self.rightButton setImage:[UIImage imageNamed:@"nav_shaop_car"] forState:UIControlStateNormal];
    }
    [self.leftButton setImage:[UIImage imageNamed:@"nav_location"] forState:UIControlStateNormal];
    _showCaseDatas = [NSMutableArray array];
    _datasSourse = [NSMutableArray array];
    _totalDic = [NSMutableDictionary dictionary];
    _typeListArray = [NSMutableArray arrayWithArray:@[@{@"title":@"", @"imgName":@"master_type_material"}, @{@"title":@"", @"imgName":@"master_type_furture"}, @{@"title":@"五金材料", @"imgName":@"master_type_other"}]];
    [self steCollectionView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //    WS(weakSelf);
    //    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    //    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
    //        [weakSelf getServer];
    //    });
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeTimer];
}

- (void)configTimer {
    if (_loopView) {
        [_loopView refreshTimer];
    }
}
- (void)removeTimer {
    if (_loopView) {
        [_loopView invalidateTimer];
    }
}

- (void)getServer {
    WS(weakSelf);
    CLAuthorizationStatus type = [CLLocationManager authorizationStatus];
    if (![CLLocationManager locationServicesEnabled] || type == kCLAuthorizationStatusDenied){
    } else {
        [ESRegionManager getRegionWithId:_locationService.locationCityInfo.cityCode withSuccess:^(ESRegionModel *region) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (region.rid == nil || [region.rid isEqualToString:@""]) {
                    [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_out_server" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"啊哦~\n您所在的城市，商城暂未开通~" buttonTitle:nil Block:nil];
                } else {
                    [weakSelf removeNoDataView];
                    [weakSelf getData];
                    
                }
            });
        }];
    }
    
}

- (void)setIsHiddenTabbar:(BOOL)isHiddenTabbar {
    _hiddenTabbar = isHiddenTabbar;
}

- (void)steCollectionView {
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    //    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //    _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    if (_hiddenTabbar) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) collectionViewLayout:_collectionViewLayout];
    } else {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT) collectionViewLayout:_collectionViewLayout];
    }
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"LoopCollectionViewCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"LoopCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"GoodsItemCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"GoodsItemCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESMasterTypeCollectionViewCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"ESMasterTypeCollectionViewCell"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CheckMoreReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CheckMoreReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESNoMoreReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ESNoMoreReusableView"];
    
    _collectionView.mj_header.backgroundColor = [UIColor stec_viewBackgroundColor];
    
    ESDiyRefreshHeader *header = [ESDiyRefreshHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(getData)];
    _collectionView.mj_header = header;
    _collectionView.mj_header.automaticallyChangeAlpha = YES;
    
//    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
//                                                                     refreshingAction:@selector(getData)];
//    header.arrowView.image = [UIImage imageNamed:@"dropdown"];
//    header.stateLabel.hidden = YES;
//    [header.stateLabel setValue:[UIFont stec_remarkTextFount]
//                         forKey:@"font"];
//    [header.stateLabel setValue:[UIColor stec_subTitleTextColor]
//                         forKey:@"textColor"];
//    header.lastUpdatedTimeLabel.hidden = YES;
//    _collectionView.mj_header = header;
//    _collectionView.mj_header.automaticallyChangeAlpha = YES;
    
    WS(weakSelf)
    _collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    //    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    //
    //    }];
    //    [footer setTitle:@"没有更多啦~" forState:MJRefreshStateNoMoreData];
    //    footer.stateLabel.textColor = [UIColor stec_subTitleTextColor];
    //    footer.backgroundColor = [UIColor stec_viewBackgroundColor];
    //    _collectionView.mj_footer = footer;
    
    [self.view addSubview:_collectionView];
}

- (void)tapOnLeftButton:(id)sender {
    SHLog(@"选择城市");
//    BOOL isrelease = [JRNetEnvConfig sharedInstance].isReleaseModel;
//    if (!isrelease) {
//        UIPasteboard*pasteboard = [UIPasteboard generalPasteboard];
//        pasteboard.string = [ESDeviceUtil getUUID];
//        [MBProgressHUD showSuccess:@"复制设备唯一标示成功"];
//    }
}

- (void)tapOnRightButton:(id)sender {
    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
    if ([appType isEqualToString:@"MALL"]) {
        ESMasterSearchController *masterSearchCon = [[ESMasterSearchController alloc] initWithCatalogId:@"1"];
        masterSearchCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:masterSearchCon animated:YES];
    } else {
        ESShoppingCartController *vc = [[ESShoppingCartController alloc] init];
        [self customPushViewController:vc animated:YES];
    }
}

- (void)getData {
    if (_locationService.locationCityInfo.cityCode == nil) {
        return;
    }
    WS(weakSelf)
    [self.hud showAnimated:YES];
    [ESOrderAPI getMasterialWithSuccess:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [weakSelf.hud hideAnimated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.showCaseDatas removeAllObjects];
        [weakSelf.datasSourse removeAllObjects];
        NSArray *showcases = dict[@"banner"] ? dict[@"banner"] : [NSArray array];
        NSArray *materialsEsports = dict[@"materialsEsports"] ? dict[@"materialsEsports"] : [NSArray array];
        weakSelf.totalDic = [NSMutableDictionary dictionaryWithDictionary:dict];
        for (NSDictionary *dic in showcases) {
            [weakSelf.showCaseDatas addObject:dic];
        }
        for (NSDictionary *dic in materialsEsports) {
            NSArray *cases = dic[@"elementList"] ? dic[@"elementList"] : [NSArray array];
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dic in cases) {
                NSDictionary *dicNew = [ESMaterialHomeModel updateHomeDic:dic];
                [array addObject:dicNew];
            }
            [weakSelf.datasSourse addObject:array];
        }
        
        [weakSelf.collectionView reloadData];
        if (weakSelf.datasSourse.count == 0 && weakSelf.showCaseDatas.count == 0) {
            [weakSelf showNoDataIn:weakSelf.collectionView imgName:@"nodata_datas" frame:_collectionView.frame Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        [_collectionView.mj_footer endRefreshingWithNoMoreData];
        
    } failure:^(NSError *error) {
        [weakSelf.hud hideAnimated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        SHLog(@"%@", error);
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.collectionView imgName:@"nodata_net" frame:weakSelf.collectionView.frame Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.collectionView.mj_header beginRefreshing];
            }];
        } else {
            [weakSelf showMessageHUD:@"请求失败"];
        }
    }];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.datasSourse.count>1) {
        return 2+self.datasSourse.count*2;
    } else {
        return 2+self.datasSourse.count+1;
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger sectionNum = 2+self.datasSourse.count+1;
    if (self.datasSourse.count>1) {
        sectionNum = 2+self.datasSourse.count*2+1;
    }
    
    if (0 == section) {
        return 1;
    } else if (1 == section) {
        return 3;
    } else if ((section+2) == sectionNum) {
        return 0;
    } else if ((section%2) == 0) {
        NSInteger factSection = (section-2)/2;
        if (self.datasSourse.count > factSection) {
            NSMutableArray *array = self.datasSourse[factSection];
            return array.count;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionNum = 2+self.datasSourse.count+1;
    if (self.datasSourse.count>1) {
        sectionNum = 2+self.datasSourse.count*2+1;
    }
    
    if (0 == indexPath.section) {
        LoopCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"LoopCollectionViewCell" forIndexPath:indexPath];
        
        NSMutableArray *imgArray = [NSMutableArray array];
        for (NSDictionary *caseDic in _showCaseDatas) {
            NSMutableDictionary *dic = caseDic[@"extend_dic"] ? caseDic[@"extend_dic"] : [NSMutableDictionary dictionary];
            NSString *imgUrl = dic[@"image"] ? dic[@"image"] : @"";
            if ([imgUrl hasPrefix:@"http"]) {
                [imgArray addObject:imgUrl];
            } else {
                [imgArray addObject:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgUrl]];
            }
            
        }
        WS(weakSelf)
        if (imgArray.count > 0) {
            [cell setDatasImgArray:imgArray loopBlock:^(NSInteger index) {
                SHLog(@"-----%ld-----", (long)index);
                
                if (imgArray.count>index) {
                    //商城首页banner埋点统计
                    [UMengServices eventWithEventId:Event_mall_home_banner attributes:@{@"index":@(index)}];
                    [Assistant jumpWithShowCaseDic:weakSelf.showCaseDatas[index] viewController:self];
                }
            }];
        }
        _loopView = cell.apView;
        return cell;
    } else if (1 == indexPath.section) {
        ESMasterTypeCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESMasterTypeCollectionViewCell" forIndexPath:indexPath];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_typeListArray[indexPath.row]];
        
        if (self.datasSourse.count > indexPath.row) {
            NSArray *materialsEsports = self.totalDic[@"materialsEsports"] ? self.totalDic[@"materialsEsports"] : [NSDictionary dictionary];
            NSDictionary *dic = materialsEsports[indexPath.row];
            NSString *mainTitle = [NSString stringWithFormat:@"%@", dic[@"mainTitle"]?dic[@"mainTitle"]:@""];
            [dict setObject:mainTitle forKey:@"title"];
        }
        
        if (_typeListArray.count>indexPath.row) {
            [cell setInfo:dict];
        }
        return cell;
    } else if ((indexPath.section+2) == sectionNum) {
        UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        return cell;
    }  else if ((indexPath.section%2) == 0) {
        NSInteger factSection = (indexPath.section-2)/2;
        if (self.datasSourse.count > factSection) {
            NSMutableArray *array = self.datasSourse[factSection];
            GoodsItemCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsItemCell" forIndexPath:indexPath];
            if (array.count > indexPath.row) {
                NSDictionary *modelDic = array[indexPath.row];
                [cell setProductInfo:modelDic[@"extend_dic"]];
            }
            
            return cell;
        } else {
            UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            return cell;
        }
    } else {
        UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        return cell;
    }
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (1 == indexPath.section) {
        
        if (indexPath.row == 2) {
            ESLiWuMarketController *vc = [[ESLiWuMarketController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        } else {
            NSString *categoryId = @"";
            NSString *mainTitle = @"列表";
            if (self.datasSourse.count > indexPath.row) {
                NSArray *materialsEsports = self.totalDic[@"materialsEsports"] ? self.totalDic[@"materialsEsports"] : [NSDictionary dictionary];
                NSDictionary *dic = materialsEsports[indexPath.row];
                categoryId = [NSString stringWithFormat:@"%@", dic[@"categoryId"]?dic[@"categoryId"]:@""];
                mainTitle = [NSString stringWithFormat:@"%@", dic[@"mainTitle"]?dic[@"mainTitle"]:@"列表"];
            }
            ESSelectListViewController *shopList = [[ESSelectListViewController alloc]init];
            shopList.hidesBottomBarWhenPushed = YES;
            [shopList setSelectCategoryId:categoryId title:mainTitle catalogId:@"1"];
            [self.navigationController pushViewController:shopList animated:YES];
            
        }
        SHLog(@"跳转列表");
    } else if ((indexPath.section%2) == 0 && indexPath.section>1) {
        NSInteger factSection = (indexPath.section-2)/2;
        [UMengServices eventWithEventId:Event_home_selected_plate(factSection+1) attributes:Event_Param_position(indexPath.item)];
        if (self.datasSourse.count > factSection) {
            NSMutableArray *array = self.datasSourse[factSection];
            if (array.count > indexPath.row) {
                NSDictionary *modelDic = array[indexPath.row];
                [Assistant jumpWithShowCaseDic:modelDic viewController:self];
            }
            
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger sectionNum = 2+self.datasSourse.count+1;
    if (self.datasSourse.count>1) {
        sectionNum = 2+self.datasSourse.count*2+1;
    }
    if (0 == indexPath.section) {
        return CGSizeMake(SCREEN_WIDTH-0.1, (125/375.0f)*(SCREEN_WIDTH-0.1));
    } else if (1 == indexPath.section) {
        return CGSizeMake((SCREEN_WIDTH-1.5)/3, (SCREEN_WIDTH-1)/3+10);
    } else if ((indexPath.section+1) == sectionNum) {
        return CGSizeMake(0.001, 0.001);
    } else if ((indexPath.section%2) == 0) {
        
        if (self.datasSourse.count > indexPath.section%2) {
            NSMutableArray *array = self.datasSourse[indexPath.section==2?0:1];
            if (array.count > indexPath.row) {
                CGFloat height = [ESMaterialHomeModel geiHeightWithIndex:indexPath.row arr:array];
                return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80.0 + height);
            }
        }
        if (320 == SCREEN_WIDTH) {
            return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80);
        } else {
            return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80);
        }
        
    } else {
        return CGSizeMake(0.001, 0.001);
    }
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    NSInteger sectionNum = 2+self.datasSourse.count+1;
    if (self.datasSourse.count>1) {
        sectionNum = 2+self.datasSourse.count*2+1;
    }
    if (0 == section) {
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    } else if (1 == section) {
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    } else if ((section+2) == sectionNum) {
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    } else if ((section%2) == 1) {
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    } else {
        return UIEdgeInsetsMake(18, 15, 14, 15);
    }
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (1 == section) {
        return 0.001;
    }
    return 10;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    //    if (2 == section) {
    return 15;
    //    }
    //    return 0.001;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView" forIndexPath:indexPath];
        
        if ((indexPath.section%2) == 0 && indexPath.section>1) {
            NSInteger factSection = (indexPath.section-2)/2;
            if (self.datasSourse.count > factSection) {
                NSArray *materialsEsports = self.totalDic[@"materialsEsports"] ? self.totalDic[@"materialsEsports"] : [NSDictionary dictionary];
                NSDictionary *dic = materialsEsports[factSection];
                NSString *mainTitle = [NSString stringWithFormat:@"%@", dic[@"mainTitle"]?dic[@"mainTitle"]:@""];
                NSString *subTitle = [NSString stringWithFormat:@"%@", dic[@"subTitle"]?dic[@"subTitle"]:@""];
                [header setTitle:mainTitle subTitle:subTitle];
            } else {
                [header setTitle:@"" subTitle:@""];
            }
        } else {
            [header setTitle:@"" subTitle:@""];
        }
        
        return header;
    } else {
        NSInteger sectionNum = 2+self.datasSourse.count+1;
        if (self.datasSourse.count>1) {
            sectionNum = 2+self.datasSourse.count*2+1;
        }
        
        if (0 == indexPath.section) {
            GrayFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
            return footer;
        } else if ((indexPath.section+2) == sectionNum && self.datasSourse.count>0) {
            ESNoMoreReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ESNoMoreReusableView" forIndexPath:indexPath];
            return footer;
        } else if ((indexPath.section%2) == 0) {
            CheckMoreReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CheckMoreReusableView" forIndexPath:indexPath];
            [footer setBlock:^{
                NSString *categoryId = @"";
                NSString *mainTitle = @"列表";
                if ((indexPath.section%2) == 0) {
                    NSInteger factSection = (indexPath.section-2)/2;
                    if (self.datasSourse.count > factSection) {
                        NSArray *materialsEsports = self.totalDic[@"materialsEsports"] ? self.totalDic[@"materialsEsports"] : [NSDictionary dictionary];
                        NSDictionary *dic = materialsEsports[factSection];
                        categoryId = [NSString stringWithFormat:@"%@", dic[@"categoryId"]?dic[@"categoryId"]:@""];
                        mainTitle = [NSString stringWithFormat:@"%@", dic[@"mainTitle"]?dic[@"mainTitle"]:@"列表"];
                    }
                }
                ESSelectListViewController *shopList = [[ESSelectListViewController alloc]init];
                shopList.hidesBottomBarWhenPushed = YES;
                [shopList setSelectCategoryId:categoryId title:mainTitle catalogId:@"1"];
                [self.navigationController pushViewController:shopList animated:YES];
            }];
            return footer;
        } else {
            GrayFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
            return footer;
        }
        
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    NSInteger sectionNum = 2+self.datasSourse.count+1;
    if (self.datasSourse.count>1) {
        sectionNum = 2+self.datasSourse.count*2+1;
    }
    
    if (0 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else if (1 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else if ((section+2) == sectionNum) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else if ((section%2) == 1) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.18*SCREEN_WIDTH);
        return size;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    NSInteger sectionNum = 2+self.datasSourse.count+1;
    if (self.datasSourse.count>1) {
        sectionNum = 2+self.datasSourse.count*2+1;
    }
    
    if (0 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else if (1 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 10);
        return size;
    } else if ((section+2) == sectionNum) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 50);
        return size;
    } else if ((section%2) == 1) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 10);
        return size;
    } else  {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 60);
        return size;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method
- (void)showMessageHUD:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}
@end
