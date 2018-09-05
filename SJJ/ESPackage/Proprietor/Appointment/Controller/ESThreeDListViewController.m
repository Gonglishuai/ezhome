//
//  ESThreeDListViewController.m
//  Consumer
//
//  Created by zhang dekai on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESThreeDListViewController.h"
#import "MPHome3dview.h"
#import "MPHome3DViewCell.h"
#import "MPSearchCaseViewController.h"

#import "MP3DCaseBaseModel.h"
#import "MPSearchCaseLibraryViewController.h"
#import "MPOrderEmptyView.h"
#import "MBProgressHUD+NJ.h"
#import "MPCaseScreenViewController.h"
#import "ESCaseDetailViewController.h"
#import <ESFoundation/UMengServices.h>
#import "ESFilterController.h"
#import "ESDesignCaseAPI.h"
#import <ESNetworking/SHAlertView.h>

@interface ESThreeDListViewController ()<MPHome3DViewDelegate>
{
    MPHome3dview *consumerView;
    BOOL _isLoadMore;
    NSMutableArray <ESDesignCaseList *> *_consumerArray;
    NSInteger _offset;
    NSInteger _limit;
    MPOrderEmptyView *_emptyView;
    NSString *_facet;
}
@property (nonatomic, strong) NSArray *filterOptions; // 已筛选的条件

@end

@implementation ESThreeDListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    //加载view
    NSInteger height = SCREEN_HEIGHT - NAVBAR_HEIGHT + 1;

    consumerView = [[MPHome3dview alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, height)];
    consumerView.delegate = self;
    [self.view addSubview:consumerView];
    [self.view sendSubviewToBack:consumerView];
    
    [consumerView startMJRefreshHeader];
    
}

- (void) setupNavigationBar
{
    [super setupNavigationBar];

    self.titleLabel.text = @"3D方案";
    self.rightButton.hidden = YES;
    self.leftButton.hidden = NO;
}

- (void)initData {
    _consumerArray= [NSMutableArray array];
    _isLoadMore = NO;
    _offset = 0;
    _limit = 10;
}

//MARK: - Network
- (void)requestData {
    WS(weakSelf);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [MP3DCaseBaseModel get3DCasesListWithOffset:[NSString stringWithFormat:@"%ld",(long)_offset]
                                      withLimit:[NSString stringWithFormat:@"%ld",(long)_limit]
                                 withSearchTerm:@""
                                      withFacet:_facet
                                    withSuccess:^(NSArray<ESDesignCaseList *> *array)
     {
         if (!_isLoadMore)
             [_consumerArray removeAllObjects];
         [_consumerArray addObjectsFromArray:array];
         
         if (array.count != 0) {
             
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         }
         
         if (_consumerArray.count==0) {
             
             if (_emptyView) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf endRefreshView:_isLoadMore];
                     [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                     
                 });
                 return;
                 
             }
             _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"MPOrderEmptyView" owner:self options:nil] lastObject];
             _emptyView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT);
             _emptyView.infoLabel.text = @"暂无结果";
             _emptyView.imageView.image = [UIImage imageNamed:@"search_case_logo"];
             [consumerView.home3DCollectionView addSubview :_emptyView];
             
         } else{
             
             if (_emptyView) {
                 [_emptyView removeFromSuperview];
                 _emptyView = nil;
             }
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf endRefreshView:_isLoadMore];
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
             
         });
     } andFailure:^(NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf endRefreshView:_isLoadMore];
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         });
         [SHAlertView showAlertForNetError];
     }];
}

//MARK: - Action

- (void)refresh3DLoadNewData:(void (^)(void))finish {
    self.refreshForLoadNew = finish;
    _isLoadMore = NO;
    _offset = 0;
    
    [self requestData];
}

- (void)refresh3DLoadMoreData:(void (^)(void))finish {
    self.refreshForLoadMore = finish;
    _isLoadMore = YES;
    _offset += _limit;
    [self requestData];
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark -------MPHome3DViewDelegate, MPHome3DViewCellDelegate--------

- (ESDesignCaseList *) get3DDatamodelForIndex:(NSUInteger) index
{
    return [_consumerArray objectAtIndex:index];
}

- (void) designer3DIconClickedAtIndex:(NSUInteger) consumer
{
    [UMengServices eventWithEventId:Event_case_2D_case_avatar attributes:Event_Param_position(consumer)];
    ESDesignCaseList *caseModel = _consumerArray[consumer];
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:caseModel.designerId forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

- (void)didSelectedItemAtIndex:(NSUInteger)index {
    
    [UMengServices eventWithEventId:Event_case_3D_case_avatar attributes:Event_Param_position(index)];
    ESDesignCaseList * model = [_consumerArray objectAtIndex:index];
    UIViewController *caseDetailVC = nil;
    
    ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
    [vc setCaseId:model.assetId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
    caseDetailVC = vc;
    
    [self customPushViewController:caseDetailVC animated:YES];
}

- (NSUInteger) get3DNumberOfItemsInCollection {
    return _consumerArray.count;
}
//MARK: - 筛选
- (void)selectedCaseTags:(NSArray *)items {
    self.filterOptions = items;
    _isLoadMore = NO;
    _offset = 0;
    _limit = 10;
    _facet = [self getFacetFromFilterOptions];
    [self requestData];
}

- (NSString *)getFacetFromFilterOptions {
    if (self.filterOptions && self.filterOptions.count > 0) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *item in self.filterOptions) {
            if (item && [item objectForKey:@"type"] && ![[item objectForKey:@"type"] isEqualToString:@""]) {
                NSString *obj = [NSString stringWithFormat:@"%@:%@", [item objectForKey:@"type"], [item objectForKey:@"name"] ?: @""];
                NSString *string = [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [arr addObject:string];
            }
        }
        NSString *facet = [arr componentsJoinedByString:@","];
        return facet;
    }
    
    return @"";
}

@end
