//
//  ESBrandRecommendDetailViewController.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESBrandRecommendDetailViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD+NJ.h"
#import "ESRecommendAPI.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESLabelHeaderFooterView.h"
#import "ESMallAssets.h"
#import "ESShareView.h"
#import "ESRecommendDetailTopTableViewCell.h"
#import "ESBrandRecommendTableViewCell.h"
#import "ESProductDetailViewController.h"
#import "EZHome-Swift.h"
#import "ESRecommendViewController.h"

#import "ESRecViewController.h"
#import "CoStringManager.h"

@interface ESBrandRecommendDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *datasSourse;
@property (nonatomic,strong)NSMutableDictionary *datasDic;
@property (copy, nonatomic) NSString *myRecommendId;

@property (nonatomic,strong)    UIButton *bottomBtn;
///是否为签约设计师
@property (nonatomic,copy)    NSString *isContract;

@end

@implementation ESBrandRecommendDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"品牌清单";
    self.rightButton.hidden = YES;
    
    _datasSourse = [NSMutableArray array];
    _datasDic = [NSMutableDictionary dictionary];
    
    
    [self createScreenButton];
    
    [self setTableView];

    
    
    [self getData];
}


- (void)setRecommendId:(NSString *)recommendId{
    _myRecommendId = recommendId;
}

- (void)createScreenButton {
    
    
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(SCREEN_WIDTH - 87, NAVBAR_HEIGHT-44, 44, 44);
    [shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setImage:[UIImage imageNamed:@"nav_share"] forState:UIControlStateNormal] ;
    [self.navgationImageview addSubview:shareButton];
    
    
    if ([SHAppGlobal AppGlobal_GetIsConsumerMode]) {
        shareButton.frame = CGRectMake(SCREEN_WIDTH-47, NAVBAR_HEIGHT-44,44,44);
    }else {
        UIButton *screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        screenButton.frame = CGRectMake(SCREEN_WIDTH-47, NAVBAR_HEIGHT-44,44,44);
        [screenButton setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
        [screenButton addTarget:self action:@selector(screenClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navgationImageview addSubview:screenButton];
    }
    
    
    
    
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)shareButtonClick {
    SHLog(@"分享");
    ESCaseShareModel *sharedModel = [self packageSharedInfor];
    if (sharedModel != nil) {
        [ESShareView showShareViewWithShareTitle:sharedModel.shareTitle shareContent:sharedModel.shareContent shareImg:sharedModel.shareImg shareUrl:sharedModel.shareUrl shareStyle:ShareStyleTextAndImage Result:^(PlatformType type, BOOL isSuccess) {
        }];

        NSString *isBindDecoration = [NSString stringWithFormat:@"%@", _datasDic[@"isBindDecoration"] ? _datasDic[@"isBindDecoration"] : @""];


        if ([isBindDecoration isEqualToString:@"1"]) {
            [self showShareToast];
        }
    }else {
        [self showAleartWithTitle:@"获取分享信息失败"];
    }
    
//    if (_datasDic.allKeys.count>0) {
//        NSString *shareTitle = [NSString stringWithFormat:@"%@", _datasDic[@"shareAppTitle"] ? _datasDic[@"shareAppTitle"] : @""];
//        NSString *shareContent = [NSString stringWithFormat:@"%@", _datasDic[@"shareAppContent"] ? _datasDic[@"shareAppContent"] : @""];
//        NSString *shareUrl = [NSString stringWithFormat:@"%@", _datasDic[@"shareAppUrl"]?_datasDic[@"shareAppUrl"]:@""];
//        NSString *imageUrl = @"";
//        if (_datasSourse.count>0) {
//            NSDictionary *info = [NSDictionary dictionaryWithDictionary:_datasSourse[0]];
//            imageUrl = [NSString stringWithFormat:@"%@", info[@"brandLogo"] ? info[@"brandLogo"] : @""];
//        }
//        
//        [ESShareView showShareViewWithShareTitle:shareTitle shareContent:shareContent shareImg:imageUrl shareUrl:shareUrl shareStyle:ShareStyleTextAndImage Result:^(PlatformType type, BOOL isSuccess) {
//        }];
//        
//        NSString *isBindDecoration = [NSString stringWithFormat:@"%@", _datasDic[@"isBindDecoration"] ? _datasDic[@"isBindDecoration"] : @""];
//        
//        
//        if ([isBindDecoration isEqualToString:@"1"]) {
//            [self showShareToast];
//        }
//        
//    } else {
//        [self showAleartWithTitle:@"获取分享信息失败"];
//    }
}

- (void)screenClick {
    SHLog(@"编辑删除");
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ESCreateBrandListViewController *createBrandListViewCon = [[ESCreateBrandListViewController alloc] initWithBrandId:_myRecommendId];
        createBrandListViewCon.fixBrandList = YES;
        [self.navigationController pushViewController:createBrandListViewCon animated:YES];
    }];
    [alerVC addAction:changeAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteRequest];
    }];
    [alerVC addAction:deleteAction];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alerVC addAction:cancel];
    
    [self presentViewController:alerVC animated:YES completion:nil];
}

- (void)refresh {
    [self getData];
}

- (void)nextpage {
    [self getData];
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESRecommendDetailTopTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ESRecommendDetailTopTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESBrandRecommendTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ESBrandRecommendTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 120.0f;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
    WS(weakSelf)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
}
#pragma mark ---- 是否创建推荐分享按钮
- (void)createBottomBtn {
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        if ([self.isContract isEqualToString:@"1"]) {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, SCREEN_HEIGHT - NAVBAR_HEIGHT - TABBAR_HEIGHT - BOTTOM_SAFEAREA_HEIGHT);
            [self.view addSubview:self.bottomBtn];
        }
    }else {
        
    }
}
- (void)getData {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESRecommendAPI getBrandRecommendDetailWithRecommendId:_myRecommendId Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.datasSourse removeAllObjects];
        weakSelf.datasDic = [NSMutableDictionary dictionaryWithDictionary:dict];
        self.isContract = [NSString stringWithFormat:@"%@", _datasDic[@"isContract"] ? _datasDic[@"isContract"] : @""];
        
        [self createBottomBtn];
        
        NSArray *list = dict[@"itemList"] ? dict[@"itemList"] : [NSArray array];
        if ([list isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in list) {
                [weakSelf.datasSourse addObject:dic];
            }
        }
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        SHLog(@"%@", error);
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_net" frame:weakSelf.tableView.bounds Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.tableView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:@"请求失败"];
        }
    }];
    
}

- (void)deleteRequest {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESRecommendAPI deleteBrandRecommendDetailWithRecommendId:_myRecommendId Success:^(NSDictionary *dict) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Brand_Recommend_Change object:nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showSuccess:@"删除成功"];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:@"删除失败"];
    }];
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1+_datasSourse.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return 0.001;
    } else if (1 == section ) {
        return 45;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (1 == section) {
        ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
        NSString *num = [NSString stringWithFormat:@"共%ld个品牌", self.datasSourse.count];
        [header setTitle:@"品牌清单" titleColor:[UIColor stec_titleTextColor] subTitle:num subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor stec_viewBackgroundColor]];
        return header;
    } else {
        ESGrayTableViewHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
        if (0 == section) {
            [header setBackViewColor:[UIColor whiteColor]];
        } else {
            [header setBackViewColor:[UIColor stec_viewBackgroundColor]];
        }
        
        return header;
    }
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [header setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ESRecommendDetailTopTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecommendDetailTopTableViewCell" forIndexPath:indexPath];
        [cell setbrandInfo:_datasDic];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        ESBrandRecommendTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESBrandRecommendTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ((indexPath.section-1) < _datasSourse.count) {
            NSDictionary *info = [_datasSourse objectAtIndex:indexPath.section-1];
            [cell setInfo:info productBlock:^(NSString *productId) {
                ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc]
                                                                       initWithProductId:productId type:ESProductDetailTypeSpu designerId:nil];
                productDetailViewCon.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:productDetailViewCon animated:YES];
            }];
        }
        return cell;
    }
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAleartWithTitle:(NSString *)title{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
    
}

- (void)showShareToast {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"分享后会随机给客户生成优惠券哦~";
    hud.margin = 30.f;
    hud.bezelView.backgroundColor = [UIColor whiteColor];
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    [hud hideAnimated:YES afterDelay:4];
    
}

#pragma mark --- Private Method
//底部按钮点击事件 --> 推荐给用户
- (void)bottomAction {
    
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    
    ESCaseShareModel *sharedModel = [self packageSharedInfor];
    
    ESRecViewController *recVC = [[ESRecViewController alloc] init];
    recVC.sharedModel = sharedModel;
    recVC.sourceType = @30;
    recVC.baseId = [numFormatter numberFromString:self.myRecommendId];
    [self.navigationController pushViewController:recVC animated:YES];
}
#pragma mark --- 组装分享数据
- (ESCaseShareModel *)packageSharedInfor {

    if (_datasDic.allKeys.count>0) {
        ESCaseShareModel *sharedModel = [[ESCaseShareModel alloc] init];
        sharedModel.shareTitle = [NSString stringWithFormat:@"%@", _datasDic[@"shareAppTitle"] ? _datasDic[@"shareAppTitle"] : @""];
        sharedModel.shareContent = [NSString stringWithFormat:@"%@", _datasDic[@"shareAppContent"] ? _datasDic[@"shareAppContent"] : @""];
        sharedModel.shareUrl = [NSString stringWithFormat:@"%@", _datasDic[@"shareAppUrl"]?_datasDic[@"shareAppUrl"]:@""];
        NSString *imageUrl = @"";
        if (_datasSourse.count>0) {
            NSDictionary *info = [NSDictionary dictionaryWithDictionary:_datasSourse[0]];
            imageUrl = [NSString stringWithFormat:@"%@", info[@"brandLogo"] ? info[@"brandLogo"] : @""];
        }
        if ([CoStringManager isEmptyString:imageUrl]) {
            imageUrl = @"";
        }
        sharedModel.shareImg = imageUrl;
        
        return sharedModel;
    }else {
        return nil;
    }
}

#pragma mark --- 懒加载
- (UIButton *)bottomBtn {
    if (!_bottomBtn) {
        _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomBtn addTarget:self action:@selector(bottomAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBtn setTitle:@"推荐分享" forState:UIControlStateNormal];
        [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bottomBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _bottomBtn.frame = CGRectMake(0, SCREEN_HEIGHT - TABBAR_HEIGHT - BOTTOM_SAFEAREA_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT + BOTTOM_SAFEAREA_HEIGHT);
        _bottomBtn.backgroundColor = ColorFromRGA(0x4E9BD6, 1.0);
    }
    return _bottomBtn;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

