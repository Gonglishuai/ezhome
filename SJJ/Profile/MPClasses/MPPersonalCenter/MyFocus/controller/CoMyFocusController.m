//
//  CoMyFocusController.m
//  Consumer
//
//  Created by Jiao on 16/7/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoMyFocusController.h"
#import "CoMyFocusView.h"
#import "MPOrderEmptyView.h"
#import "ESCommentFocusModel.h"
#import "MBProgressHUD.h"
#import <ESNetworking/SHAlertView.h>
#import "ESCommentAPI.h"

@interface CoMyFocusController ()<CoMyFocusViewDelegate>

@end

@implementation CoMyFocusController
{
    
    NSMutableArray *_focusDesignersArray;
    
    NSInteger _offset;
    NSInteger _limit;
    BOOL _loadMore;
    MPOrderEmptyView *_emptyView;
    CoMyFocusView *_focusView;

}

- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"我的关注";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    [self createView];
    [self requestData];

}

- (void)initData {
    _focusDesignersArray = [[NSMutableArray alloc] init];
    _offset = 0;
    _limit = 100;
    _loadMore = NO;
    
}

- (void)createView {
    
    _focusView = [[CoMyFocusView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    _focusView.delegate = self;
    [self.view addSubview:_focusView];
}

- (void)requestData {
    
    [self showHUD];
    WS(weakSelf);
    [ESCommentAPI getMyFollowListWithPageNum:_offset pageSize:_limit withSuccess:^(NSDictionary *dict) {
        if (!_loadMore) {
            [_focusDesignersArray removeAllObjects];
        }
        
        NSArray *array = dict[@"followDesignerRespList"];
        if (![array isKindOfClass:[NSArray class]]) {
            array = [NSArray array];
        }
        for (NSDictionary *dic in array) {
            ESCommentFocusModel *model = [ESCommentFocusModel createModelWithDic:dic];
            [_focusDesignersArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createShowWithArray:_focusDesignersArray withType:@"您还没有关注的设计师"];
            [_focusView refreshFocusDesignersUI];
            [weakSelf endRefreshView:_loadMore];
            [weakSelf hideHUD];
        });
    } andFailure:^(NSError *error) {
        [weakSelf hideHUD];
        
        [weakSelf endRefreshView:_loadMore];
        [SHAlertView showAlertForNetError];
    }];
    
}

- (void)createShowWithArray:(NSMutableArray *)array withType:(NSString *)titleStr{
    
    if (array.count==0) {
        
        
        if (_emptyView) {
            _emptyView.infoLabel.text = titleStr;

        }else {
            
            _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"MPOrderEmptyView" owner:self options:nil] lastObject];
            
        }
       
        
        _emptyView.infoLabel.text = titleStr;
        
        _emptyView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -NAVBAR_HEIGHT);
        
        [_focusView addSubview:_emptyView];
        
    }else{
        
        if (_emptyView) {
            [_emptyView removeFromSuperview];
            _emptyView = nil;
        }
    }
    
}

- (void)showHUD {
    
    [MBProgressHUD showHUDAddedTo:_focusView animated:YES];

}

- (void)hideHUD {
    
//    [MBProgressHUD hideAllHUDsForView:_focusView animated:YES];
    [MBProgressHUD hideHUDForView:_focusView animated:YES];

}

- (void)focusDesignersViewRefreshLoadNewData:(void (^)(void))finish {

    _offset = 0;
    _loadMore =NO;
    [self requestData];
}
- (void)focusDesignersViewRefreshLoadMoreData:(void (^)(void))finish {
    self.refreshForLoadMore = finish;

    _offset = _focusDesignersArray.count;
    _loadMore = YES;
    [self requestData];
    
}
- (NSInteger)getFocusDesignersCount {
    
    return _focusDesignersArray.count;
}

- (ESCommentFocusModel *) getFocusDesignersModelForIndex:(NSUInteger) index {
    
    return [_focusDesignersArray objectAtIndex:index];
}

-(void) clickUnsubscribeDesignerForIndex:(NSUInteger) index {
    ESCommentFocusModel *model = [_focusDesignersArray objectAtIndex:index];
    
    NSString *titleStr = [NSString stringWithFormat:@"您确定取消对%@的关注吗？",model.nickName];
    [SHAlertView showAlertWithMessage:titleStr sureKey:^{
        [self selectCancelDesignerWithFocusModel:model withForIndex:index];

    } cancelKey:^{
        
    }];
}

- (void)selectCancelDesignerWithFocusModel:(ESCommentFocusModel *)model withForIndex:(NSUInteger)index {

    [self showHUD];
    WS(weakSelf);
    [ESCommentAPI deleteFollowWithFollowId:model.followId type:@"0" withSuccess:^(NSDictionary *dict) {
        [_focusDesignersArray removeObjectAtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createShowWithArray:_focusDesignersArray withType:@"您还没有关注的设计师"];
            [_focusView refreshFocusDesignersUI];
        });
        
        [weakSelf hideHUD];
        
        //重新加载数据 
        if (_focusDesignersArray.count < _limit) {
            _offset = 0;
            _loadMore = NO;
            [self requestData];
        }
    } andFailure:^(NSError *error) {
        [weakSelf hideHUD];
        [SHAlertView showAlertForNetError];
    }];

}

- (void)didSelectItemAtIndex:(NSInteger)index {
  
    ESCommentFocusModel *foceusModel =_focusDesignersArray[index];
    
//    _focusView.focusDesignersTabelView.allowsSelection = NO;
    

    NSDictionary *dict = [NSDictionary dictionaryWithObject:foceusModel.followId forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
    
//    [CoMyFocusModel createDesignerDetailWithModel:foceusModel success:^(MPDesignerInfoModel *model) {
//
//        MPDesignerInfoModel *modelInfo = model;
//        modelInfo.member_id = modelInfo.designer.acs_member_id;
//
//        MPDesignerDetailViewController *vc = [[MPDesignerDetailViewController alloc] initWithIsDesignerCenter:NO member_id:[NSString stringWithFormat:@"%@", model.member_id] designer_hs_uid:model.hs_uid isConsumerNeeds:NO];
//
//        [self.navigationController pushViewController:vc animated:YES];
//        _focusView.focusDesignersTabelView.allowsSelection = YES;
//    } failure:^(NSError *error) {
//        _focusView.focusDesignersTabelView.allowsSelection = YES;
//        [SHAlertView showAlertForNetError];
//    }];
    

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
