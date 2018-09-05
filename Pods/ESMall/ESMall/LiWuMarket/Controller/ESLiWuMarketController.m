//
//  ESLiWuMarketController.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  丽屋超市（五金涂料）

#import "ESLiWuMarketController.h"
#import "ESLiWuMarketDataManager.h"
#import "ESLiWuMarketView.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "ESSelectListViewController.h"
#import "Assistant.h"
#import "ESMasterSearchController.h"
#import <ESFoundation/UMengServices.h>

@interface ESLiWuMarketController ()<ESLiWuMarketViewDelegate>
@property (nonatomic, strong) ESLiWuMarketView *mainView;
@property (nonatomic, strong) ESLiWuHomeModel *homeModel;
@end

@implementation ESLiWuMarketController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    
    [self setUpNav];
    
    self.mainView = [[ESLiWuMarketView alloc] initWithDelegate:self];
    [self.view addSubview:self.mainView];
    __block UIView *b_view = self.view;
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_view.mas_top);
        make.leading.equalTo(b_view.mas_leading);
        make.bottom.equalTo(b_view.mas_bottom);
        make.trailing.equalTo(b_view.mas_trailing);
    }];
    
    [self getData];
}

- (void)setUpNav {
    self.title = @"五金涂料";
    
    UIButton *searchBtn = [[UIButton alloc] init];
    [searchBtn addTarget:self action:@selector(tapSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal];
    [searchBtn sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = rightItem;

}

- (void)tapSearchButton:(UIButton *)sender {
    ESMasterSearchController *masterSearchCon = [[ESMasterSearchController alloc] initWithCatalogId:@"4"];
    [self.navigationController pushViewController:masterSearchCon animated:YES];
}

- (void)getData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESLiWuMarketDataManager getLiWuHomeDataWithSuccess:^(ESLiWuHomeModel *model) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.homeModel = model;
        [weakSelf.mainView refreshMainView];
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showMessageHUD:@"网络错误, 请稍后重试!"];
    }];
}

#pragma mark - ESLiWuMarketViewDelegate
- (NSInteger)getItemsNumsWithSection:(NSInteger)section {
    if (section == 1) {//类目数
        return [ESLiWuMarketDataManager getCategoryNumsWithModel:self.homeModel];
    }else if (section == 2) {//商品数量
        return [ESLiWuMarketDataManager getProductNumsWithModel:self.homeModel];
    }
    return 0;
}

- (void)selectItemWithSection:(NSInteger)section andIndex:(NSInteger)index {
    if (section == 1) {//点击类目
        ESLiWuCategoryModel *category = [ESLiWuMarketDataManager getCategoryWithModel:self.homeModel andIndex:index];
        if (category.categoryId && category.categoryName) {
            ///类目点击埋点统计
            [UMengServices eventWithEventId:Event_liwumarket_category attributes:@{@"name":category.categoryName ? category.categoryName : @"none"}];
            ESSelectListViewController *vc = [[ESSelectListViewController alloc] init];
            [vc setSelectCategoryId:category.categoryId title:category.categoryName catalogId:@"4"];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (section == 2) {//点击热卖商品
        
        [UMengServices eventWithEventId:Event_liwumarket_hot_sale attributes:Event_Param_position((long)index)];
        ESCMSModel *product = [ESLiWuMarketDataManager getProductWithModel:self.homeModel andIndex:index];
        NSDictionary *dict = [ESCMSModel dictFromObj:product];
        if (dict) {
            [Assistant jumpWithShowCaseDic:dict viewController:self];
        }
    }
}

#pragma mark - ESLiWuLoopCellDelegate
- (NSArray <NSString *>*)getLoopImgUrls {
    return [ESLiWuMarketDataManager getLoopImageUrlsWithModel:self.homeModel];
}

- (void)selectLoopCellAtIndex:(NSInteger)index {
    [UMengServices eventWithEventId:Event_liwumarket_banner attributes:Event_Param_position((long)index)];
    
    ESCMSModel *banner = [ESLiWuMarketDataManager getBannerWithModel:self.homeModel andIndex:index];
    NSDictionary *dict = [ESCMSModel dictFromObj:banner];
    if (dict) {
        [Assistant jumpWithShowCaseDic:dict viewController:self];
    }
}

#pragma mark - ESLiWuCategoryCellDelegate
- (ESLiWuCategoryModel *)getCategory:(NSInteger)index {
    return [ESLiWuMarketDataManager getCategoryWithModel:self.homeModel andIndex:index];
}

#pragma mark - ESLiWuProductCellDelegate
- (ESCMSModel *)getProduct:(NSInteger)index {
    return [ESLiWuMarketDataManager getProductWithModel:self.homeModel andIndex:index];
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
