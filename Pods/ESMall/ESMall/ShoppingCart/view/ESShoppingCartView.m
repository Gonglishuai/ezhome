//
//  ESShoppingCartView.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/30.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartView.h"
#import "ESShoppingCartNormalCell.h"
#import "ESShoppingCartDeleteCell.h"
#import "ESShoppingCartBrandHeaderView.h"
#import "ESShoppingCartInvalidHeaderView.h"
#import "ESDiyRefreshHeader.h"
#import "Masonry.h"

@interface ESShoppingCartView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ESShoppingCartBottomView *bottomView;

@end

@implementation ESShoppingCartView

- (instancetype)initWithTableBaseVC:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        [self initTableViewWithBaseVC:vc];
        [self initBottomView];
        [self setUpConstraints];
    }
    return self;
}

- (void)setDelegate:(id<ESShoppingCartViewDelegate>)delegate
{
    if (delegate)
    {
        _delegate = delegate;
        self.bottomView.delegate = (id)delegate;
    }
}

- (void)initTableViewWithBaseVC:(UIViewController *)vc
{
    UITableView *tableView = nil;
    if (vc
        && [vc isKindOfClass:[UIViewController class]])
    {
        UITableViewController *tabController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        tableView = tabController.tableView;
        [vc addChildViewController:tabController];
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    self.tableView = tableView;
    [self.tableView registerNib:[UINib nibWithNibName:@"ESShoppingCartNormalCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESShoppingCartNormalCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESShoppingCartDeleteCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESShoppingCartDeleteCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESShoppingCartBrandHeaderView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESShoppingCartBrandHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESShoppingCartInvalidHeaderView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESShoppingCartInvalidHeaderView"];
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 200.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    [self addMJRefresh];
}

- (void)initBottomView {
    NSArray *views = [[ESMallAssets hostBundle] loadNibNamed:@"ESShoppingCartBottomView" owner:nil options:nil];
    self.bottomView = [views firstObject];
    [self addSubview:self.bottomView];
    [self setBottomVisible:NO];
}

- (void)setUpConstraints {
    __block UIView *b_view = self;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(b_view.mas_bottom);
        make.leading.equalTo(b_view.mas_leading);
        make.trailing.equalTo(b_view.mas_trailing);
        make.height.equalTo(@(TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT));
    }];
    
    __block ESShoppingCartBottomView *b_bottomView = self.bottomView;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_view.mas_top);
        make.leading.equalTo(b_view.mas_leading);
        make.trailing.equalTo(b_view.mas_trailing);
        make.bottom.equalTo(b_bottomView.mas_top).with.offset(-1);
    }];
}

- (void)addMJRefresh {
    
    ESDiyRefreshHeader *header = [ESDiyRefreshHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(getData)];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)getData {
    if ([self.delegate respondsToSelector:@selector(refreshLoadNewData)]) {
        [self.delegate refreshLoadNewData];
    }
}

- (void)setBottomVisible:(BOOL)visible {
    self.bottomView.hidden = !visible;
}

- (void)refreshMainView {
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

- (void)refreshSections:(NSIndexSet *)indexSet {
    @try {
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        [self refreshMainView];
    }
    
}

- (void)refreshBottomView {
    [self.bottomView updateBottomView];
}

- (void)setBottomRightBtn:(ESCartConfirmButtonType)type {
    [self.bottomView setRightBtn:type];
}

- (void)refreshItemsWithIndexPaths:(NSArray <NSIndexPath *>*)indexPaths {
    @try {
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        [self refreshMainView];
    }
}

- (void)scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)deleteSectionWithIndexSet:(NSIndexSet *)indexSet {
    @try {
        [self.tableView beginUpdates];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
        [self.tableView endUpdates];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        [self refreshMainView];
    }
}

- (void)deleteRowWithIndexPaths:(NSArray <NSIndexPath *>*)indexPaths {
    @try {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        [self refreshMainView];
    }
}

#pragma mrak - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([self.delegate respondsToSelector:@selector(isEditingWithSection:)]) {
        if ([self.delegate isEditingWithSection:indexPath.section]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ESShoppingCartDeleteCell"];
            ESShoppingCartDeleteCell *deleteCell = (ESShoppingCartDeleteCell *)cell;
            deleteCell.tableView = tableView;
            deleteCell.delegate = (id)self.delegate;
            [deleteCell updateDeleteCellWithSection:indexPath.section andIndex:indexPath.row];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ESShoppingCartNormalCell"];
            ESShoppingCartNormalCell *normalCell = (ESShoppingCartNormalCell *)cell;
            normalCell.tableView = tableView;
            normalCell.delegate = (id)self.delegate;
            [normalCell updateNormalCellWithSection:indexPath.section andIndex:indexPath.row];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ESShoppingCartDeleteCell class]]) {
        return NO;
    }
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[ESShoppingCartNormalCell class]]) {
            ESShoppingCartNormalCell *normalCell = (ESShoppingCartNormalCell *)cell;
            [normalCell deleteCellWithSection:indexPath.section andIndex:indexPath.row];
        }
    }];
    deleteAction.backgroundColor = [UIColor stec_deleteRowActionBackColor];
    return @[deleteAction];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(getSectionNums)]) {
        NSInteger sectionNums = [self.delegate getSectionNums];
        return sectionNums;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getItemNumsWithSection:)]) {
        NSInteger itemNums = [self.delegate getItemNumsWithSection:section];
        return itemNums;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getSectionType:)]) {
        ESCommodityType type = [self.delegate getSectionType:section];
        if (type == ESCommodityTypeValid) {
            ESShoppingCartBrandHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESShoppingCartBrandHeaderView"];
            view.delegate = (id)self.delegate;
            [view updateHeaderView:section];
            return view;
        }else if(type == ESCommodityTypeInvalid || type == ESCommodityTypeNonsupport) {
            ESShoppingCartInvalidHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESShoppingCartInvalidHeaderView"];
            NSString *title = @"";
            if (type == ESCommodityTypeInvalid) {
                title = @"失效商品";
            }else if (type == ESCommodityTypeNonsupport) {
                title = @"非当前城市的商品不支持购买";
            }
            [view setInvalidTitle:title];
            view.delegate = (id)self.delegate;
            [view updateHeaderView:section];
            return view;
        }

    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getSectionType:)]) {
        return 55.5;
    }
    return 0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
//    view.backgroundColor = [UIColor stec_viewBackgroundColor];
//    return view;
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ESShoppingCartNormalCell class]]) {
        if ([self.delegate respondsToSelector:@selector(tapItemWithSection:andIndex:)]) {
            [self.delegate tapItemWithSection:indexPath.section andIndex:indexPath.row];
        }
    }
}

@end
