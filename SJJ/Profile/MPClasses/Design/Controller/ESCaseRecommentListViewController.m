//
//  ESCaseRecommentListViewController.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseRecommentListViewController.h"
#import "ESDiyRefreshHeader.h"
#import "ESCaseProductListCollectionCell.h"
#import "ESCaseAPI.h"
#import "MBProgressHUD+NJ.h"
#import "ESProductDetailViewController.h"

@interface ESCaseRecommentListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *caseId;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;
@end

@implementation ESCaseRecommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageNum = 1;
    _pageSize = 10;
    _datasSourse = [NSMutableArray array];
    self.navgationImageview.hidden = YES;
    [self setCollectionView];
    [self getData];
    
}

- (void)refresh {
    _pageNum = 1;
    [self getData];
}

- (void)nextpage {
    _pageNum = _pageNum+1;
    [self getData];
}

- (void)setCaseId:(NSString *)caseId categoryId:(NSString *)categoryId {
    _categoryId = categoryId;
    _caseId = caseId;
}

- (void)setCollectionView {
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESCaseProductListCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ESCaseProductListCollectionCell"];
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
    [ESCaseAPI getRecommendProductListWithCaseId:_caseId CategoryId:_categoryId pageNum:_pageNum pageSize:_pageSize andSuccess:^(NSArray *array, NSInteger commentNum) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        if (weakSelf.pageNum==0) {
            [weakSelf.datasSourse removeAllObjects];
        }
        [weakSelf.datasSourse addObjectsFromArray:array];
        
        [weakSelf.collectionView reloadData];
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.collectionView imgName:@"nodata_datas" frame:weakSelf.collectionView.frame Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        if (weakSelf.datasSourse.count >= commentNum) {
            [_collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [_collectionView.mj_footer endRefreshing];
        }
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        SHLog(@"%@", error);
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.collectionView imgName:@"nodata_net" frame:weakSelf.collectionView.frame Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.collectionView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:@"请求失败" toView:weakSelf.view];
        }
    }];
    
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasSourse.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESCaseProductListCollectionCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESCaseProductListCollectionCell" forIndexPath:indexPath];
    if (_datasSourse.count > indexPath.row) {
        ESCaseProductModel *info = [_datasSourse objectAtIndex:indexPath.row];
        [cell setDatas:info];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SHLog(@"商品详情");
    if (_datasSourse.count > indexPath.row) {
        ESCaseProductModel *info = [_datasSourse objectAtIndex:indexPath.row];
        NSString *goodid = [NSString stringWithFormat:@"%@", info.catentrySpuId ? info.catentrySpuId : @""];
        ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc]
                                                               initWithProductId:goodid type:ESProductDetailTypeSpu designerId:nil];
        productDetailViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:productDetailViewCon animated:YES];
    }

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((SCREEN_WIDTH-50)/3, (SCREEN_WIDTH-50)/3+45);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(15, 18, 15, 18);
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 6;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
    
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
