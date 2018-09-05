//
//  ESSelectListViewController.m
//  Consumer
//
//  Created by jiang on 2017/7/10.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESSelectListViewController.h"
#import "ESDiyRefreshHeader.h"
#import "GoodsItemCell.h"
#import "ESProductDetailViewController.h"
#import "ESOrderAPI.h"
#import "MBProgressHUD+NJ.h"
#import "ESMasterSearchController.h"
#import "ESMaterialHomeModel.h"

@interface ESSelectListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;
@property (nonatomic,copy)NSString *categoryId;
@property (nonatomic,copy)NSString *navTitle;
@property (nonatomic, strong) NSString *catalogId;
@end

@implementation ESSelectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _pageNum = 0;
    _pageSize = 10;
    _datasSourse = [NSMutableArray array];
    [self setCollectionView];
    [self getData];
    self.titleLabel.text = _navTitle;
    
}

- (void)refresh {
    _pageNum = 0;
    [self getData];
}

- (void)nextpage {
    _pageNum = _pageNum+10;
    [self getData];
}

- (void)setCollectionView {
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    //    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //    _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"GoodsItemCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"GoodsItemCell"];
    WS(weakSelf)
    _collectionView.mj_header.backgroundColor = [UIColor stec_viewBackgroundColor];
    _collectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    _collectionView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
    [self.view addSubview:_collectionView];
}

- (void)getData {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getMasterialListWithCategoryId:_categoryId catalogId:self.catalogId pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
        
        SHLog(@"%@", dict);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        if (weakSelf.pageNum==0) {
            [weakSelf.datasSourse removeAllObjects];
        }
        NSArray *materialsEsports = dict[@"productList"] ? dict[@"productList"] : [NSArray array];
        if ([materialsEsports isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in materialsEsports) {
                
                NSDictionary *dicNew = [ESMaterialHomeModel updateListDic:dic];
                [weakSelf.datasSourse addObject:dicNew];
            }
        }
        
        [weakSelf.collectionView reloadData];
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.collectionView imgName:@"nodata_datas" frame:weakSelf.collectionView.bounds Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        NSInteger recordSetTotal = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"recordSetTotal"]] integerValue];
        if (weakSelf.datasSourse.count >= recordSetTotal) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        SHLog(@"%@", error);
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.collectionView imgName:@"nodata_net" frame:weakSelf.collectionView.bounds Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.collectionView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:@"请求失败"];
        }
        if (weakSelf.pageNum >= 10) {
            weakSelf.pageNum= weakSelf.pageNum - 10;
        }
    }];

}

- (void)setSelectCategoryId:(NSString *)categoryId title:(NSString *)title catalogId:(NSString *)catalogId {
    _navTitle = title;
    
    self.categoryId = categoryId;
    self.catalogId = catalogId;
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
//    [[CoTabBarControllerManager tabBarManager] setCurrentController:2];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (void)tapOnRightButton:(id)sender {
    ESMasterSearchController *masterSearchCon = [[ESMasterSearchController alloc] initWithCatalogId:self.catalogId];
    [self.navigationController pushViewController:masterSearchCon animated:YES];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasSourse.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsItemCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsItemCell" forIndexPath:indexPath];
    if (_datasSourse.count > indexPath.row) {
        NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
        [cell setProductListInfo:dic];
    }
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        
    SHLog(@"商品详情");
    NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
    NSString *goodid = [NSString stringWithFormat:@"%@", dic[@"catalogEntryId"] ? dic[@"catalogEntryId"] : @""];
    ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc]
                                                           initWithProductId:goodid type:ESProductDetailTypeSpu designerId:nil];
    productDetailViewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:productDetailViewCon animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat height = [ESMaterialHomeModel geiListHeightWithIndex:indexPath.row arr:_datasSourse];
    if (320 == SCREEN_WIDTH) {
        return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80 + height);
    } else {
        return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80 + height);
    }
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(15, 15, 15, 15);
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20;

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
