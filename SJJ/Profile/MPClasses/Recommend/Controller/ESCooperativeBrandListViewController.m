//
//  ESCooperativeBrandListViewController.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCooperativeBrandListViewController.h"
#import "ESDiyRefreshHeader.h"
#import "ESCooperativeBrandCollectionViewCell.h"
#import "ESOrderAPI.h"
#import "MBProgressHUD+NJ.h"
#import "ESCooperativeBrandSearchViewController.h"
#import "ESRecommendAPI.h"

@interface ESCooperativeBrandListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;

@end

@implementation ESCooperativeBrandListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageNum = 0;
    _pageSize = 10;
    _datasSourse = [NSMutableArray array];
    [self setCollectionView];
    [self getData];
    self.titleLabel.text = @"合作品牌";
    
}

- (void)refresh {
    _pageNum = 0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    [_collectionView registerNib:[UINib nibWithNibName:@"ESCooperativeBrandCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ESCooperativeBrandCollectionViewCell"];
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
    [ESRecommendAPI getCooperativeBrandRecommendListWithName:@"" pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        if (weakSelf.pageNum==0) {
            [weakSelf.datasSourse removeAllObjects];
        }
        NSArray *materialsEsports = dict[@"rows"] ? dict[@"rows"] : [NSArray array];
        if ([materialsEsports isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in materialsEsports) {
                [weakSelf.datasSourse addObject:dic];
            }
        }
        
        [weakSelf.collectionView reloadData];
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_datas" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"啊哦~暂时没有搜到结果哦~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        NSInteger recordSetTotal = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"count"]] integerValue];
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
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_net" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
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

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)tapOnRightButton:(id)sender {
    ESCooperativeBrandSearchViewController *cooperativeBrandSearchViewCon = [[ESCooperativeBrandSearchViewController alloc] init];
    [self.navigationController pushViewController:cooperativeBrandSearchViewCon animated:YES];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasSourse.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESCooperativeBrandCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESCooperativeBrandCollectionViewCell" forIndexPath:indexPath];
    if (_datasSourse.count > indexPath.row) {
        NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
        [cell setInfo:dic];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 40 );
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
    
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

