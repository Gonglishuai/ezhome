			/**
 * @file    MPFindDesignersViewController.m
 * @brief   the frame of MPFindDesignersViewController.
 * @author  Xue
 * @version 1.0
 * @date    2016-02-17
 */

#import "MPFindDesignersViewController.h"
#import "MPFindDesignersView.h"
#import "MPDesignerInfoModel.h"
#import "MPDesignerBaseModel.h"
#import "MPSearchCaseViewController.h"
#import "SHMemberModel.h"
#import "ESFilterController.h"
#import "CoSearchDesignerViewController.h"
#import "MPOrderEmptyView.h"
#import "MBProgressHUD.h"
#import "ESNIMManager.h"
#import <ESFoundation/UMengServices.h>
#import <ESNetworking/SHAlertView.h>
#import <Masonry.h>

@interface MPFindDesignersViewController ()<MPFindDesignersViewDelegate,ESFilterControllerDelegate,UIViewControllerTransitioningDelegate>

@end

@implementation MPFindDesignersViewController
{
    MPFindDesignersView *_findDesignersView;   //!< _listView the view for table.
    NSMutableArray *_arrayDS;                  //!< _arrayDS array for datasource.
    NSInteger _offset;                         //!< _offset offset how many.
    NSInteger _limit;                          //!< _limit limlt how many.
    BOOL _isLoadMore;                          //!< _isLoadMore load more or not.
    SHMemberModel *_model;
    UIButton *  _personalInfoBtn;
    UIButton *_searchButton;
    
    NSArray *_allTags;        //!< Record all options worth position for the back to the filter interface.
    NSArray *_selectedTag;     //!< Record all the selected values for interface back to the screening.
    
    NSString *_priceString;//价格
    NSString *_styleString;//风格
    NSString *_start_experience;//年限开始
    NSString *_end_experience;//年限结束
    
    MPOrderEmptyView *_emptyView;
    
}

- (void)searchDesignerClick:(id)sender
{
    [UMengServices eventWithEventId:Event_designer_search];
    [self customPushViewController:[[CoSearchDesignerViewController alloc] init] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    [self initData];
    
    [self getFilterTags];
    
    [self initUI];
    
    [self createScreenButton];
}

- (void)getFilterTags {
    [MPDesignerBaseModel getDesignerFilterTagsWithSuccess:^(NSArray *arr) {
        _allTags = arr;
    } andFailure:^(NSError *error) {
        
    }];
}

- (void)createScreenButton {
    UIButton *screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    screenButton.frame = CGRectMake(SCREEN_WIDTH-87, NAVBAR_HEIGHT-44,44,44);
    [screenButton setImage:[UIImage imageNamed:@"nav_screen"] forState:UIControlStateNormal];
    [screenButton addTarget:self action:@selector(screenClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navgationImageview addSubview:screenButton];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.frame = CGRectMake(SCREEN_WIDTH - 47, NAVBAR_HEIGHT-44, 44, 44);
    [_searchButton addTarget:self action:@selector(searchDesignerClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchButton setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal] ;
    
    [self.navgationImageview addSubview:_searchButton];
}

- (void)screenClick {
    
    [UMengServices eventWithEventId:Event_designer_filter];
    ESFilterController *vc = [[ESFilterController alloc] initWithSelected:_selectedTag withOriginalTags:_allTags withDelegate:self];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) setupNavigationBar
{
    [super setupNavigationBar];
    self.menuLabel.hidden = YES;
    self.leftButton.hidden = _isHiddenLeft;
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"设计师";
    
    
}
- (void)tapOnLeftButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUI {
    _findDesignersView = [[MPFindDesignersView alloc] init];
    _findDesignersView.delegate = self;
    [self.view addSubview:_findDesignersView];
    [_findDesignersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.view.mas_top).with.offset(NAVBAR_HEIGHT);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)initData {
    _arrayDS = [NSMutableArray array];
    _isLoadMore = NO;
    _limit = 10;
    _offset = 0;
    _styleString = @"";
    _start_experience = @"";
    _end_experience = @"";
    _priceString = @"-1";
    _allTags = [NSArray array];
    _selectedTag = [NSArray array];
}

- (void)requestData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *param = @{@"limit"             :@(_limit),
                            @"offset"            :@(_offset),
                            @"style_names"       :[_styleString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                            @"start_experience"  :_start_experience,
                            @"end_experience"    :_end_experience,
                            @"design_price_code" :_priceString,
                            @"nick_name"         :@""};
    
    [MPDesignerBaseModel getDataWithParameters:param success:^(NSArray *array) {
        
        if (!_isLoadMore)
            [_arrayDS removeAllObjects];
        
        [_arrayDS addObjectsFromArray:array];
        
        if (_arrayDS.count == 0) {
            if (_emptyView) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf endRefreshView:_isLoadMore];
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                });
                return;
                
            }
            _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"MPOrderEmptyView" owner:self options:nil] lastObject];
            _emptyView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            _emptyView.infoLabel.text = @"暂无结果";
            _emptyView.imageView.image = [UIImage imageNamed:@"search_case_logo"];
            [_findDesignersView addSubview:_emptyView];

        }else{
            
            if (_emptyView) {
                [_emptyView removeFromSuperview];
                _emptyView = nil;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf endRefreshView:_isLoadMore];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        });

        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf endRefreshView:_isLoadMore];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
        
        [SHAlertView showAlertForNetError];


    }];
}

#pragma mark - MPFindDesignersViewDelegate methods

- (NSInteger) getDesignerCellCount {
    return [_arrayDS count];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
    [UMengServices eventWithEventId:Event_designer_list attributes:Event_Param_position(index)];
    MPDesignerInfoModel *modelInfo = _arrayDS[index];

    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:modelInfo.jmember_id forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

- (void)findDesignersViewRefreshLoadNewData:(void (^)(void))finish {
    self.refreshForLoadNew = finish;
    _offset = 0;
    _isLoadMore = NO;
    [self requestData];
}

- (void)findDesignersViewRefreshLoadMoreData:(void (^)(void))finish {
    self.refreshForLoadMore = finish;
    _offset += _limit;
    _isLoadMore = YES;
    [self requestData];
}

#pragma mark - MPFindDesignersTableViewCellDelegate methods

- (MPDesignerInfoModel *)getDesignerLibraryModelForIndex:(NSUInteger) index
{
    MPDesignerInfoModel *model = nil;
    
    if (_arrayDS.count > 0)
        return [_arrayDS objectAtIndex:index];
    
    return model;
}

- (void)refreshView {
    [_findDesignersView refreshFindDesignersUI];
}

#pragma mark - ESFilterControllerDelegate
- (void)selectedCaseTags:(NSArray *)items {
    @try {
        _selectedTag = items;
        for (NSDictionary *dict in items) {
            if (dict && dict[@"type"]) {
                if ([dict[@"type"] isEqualToString:@"experiences"]) {
                    NSString *value = [dict objectForKey:@"value"];
                    NSString *start = @"";
                    NSString *end = @"";
                    if (value.length > 0) {
                        NSArray *values = [value componentsSeparatedByString:@"-"];
                        if (values.count > 1) {
                            start = [values objectAtIndex:0];
                            end   = [values objectAtIndex:1];
                        }
                    }
                    _start_experience = start;
                    _end_experience   = end;
                }else if ([dict[@"type"] isEqualToString:@"styles"]) {
                    _styleString = [dict objectForKey:@"name"];
                    if ([_styleString isEqualToString:@"全部"]) {
                        _styleString = @"";
                    }
                }else if ([dict[@"type"] isEqualToString:@"costs"]) {
                    _priceString = [dict objectForKey:@"value"];
                }
            }
        }
        [self requestData];
    } @catch (NSException *exception) {
        
    }
    
}
@end
