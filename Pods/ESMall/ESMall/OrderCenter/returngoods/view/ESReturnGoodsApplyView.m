//
//  ESReturnGoodsApplyView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsApplyView.h"
#import "ESReturnApplyItemCell.h"
#import "ESClickCell.h"
#import "ESReturnApplyInputCell.h"
#import "ESReturnBrandHeaderView.h"
#import "ESReturnBrandFooterView.h"
#import "ESConnectMerchantCell.h"
#import "Masonry.h"
#import "ESReturnApplyWayCell.h"
#import "ESReturnApplyAmountInputCell.h"

@interface ESReturnGoodsApplyView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *bottomBtn;

@property (nonatomic, strong) UIView *descriptionView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation ESReturnGoodsApplyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableViewWithFrame:frame];
        [self setUpReturnGoodsDescription];
    }
    return self;
}

- (void)initTableViewWithFrame:(CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnApplyItemCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnApplyItemCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnApplyWayCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnApplyWayCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnApplyAmountInputCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnApplyAmountInputCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnApplyInputCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnApplyInputCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESClickCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESClickCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESConnectMerchantCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESConnectMerchantCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnBrandHeaderView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESReturnBrandHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnBrandFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESReturnBrandFooterView"];
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 100;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:self.tableView];
    
    self.bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height - 49, frame.size.width, 49)];
    [self.bottomBtn setBackgroundColor:[UIColor stec_blueTextColor]];
    [self.bottomBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.bottomBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
    [self.bottomBtn addTarget:self action:@selector(refundBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.bottomBtn];
}

- (void)setUpReturnGoodsDescription {
    self.descriptionView = [[UIView alloc] init];
    self.descriptionView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.descriptionLabel = [[UILabel alloc] init];
    [self.descriptionLabel setTextColor:[UIColor stec_subTitleTextColor]];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f]];
    self.descriptionLabel.numberOfLines = 0;
    [self.descriptionView addSubview:self.descriptionLabel];
    
    __block UIView *b_descriptionView = self.descriptionView;
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(b_descriptionView.mas_leading).with.offset(15);
        make.trailing.equalTo(b_descriptionView.mas_trailing).with.offset(-15);
        make.height.greaterThanOrEqualTo(@(44));
        make.top.equalTo(b_descriptionView.mas_top).with.offset(5);
        make.bottom.equalTo(b_descriptionView.mas_bottom).with.offset(-5);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tableView endEditing:YES];
}

- (void)refreshMainView {
    [self.tableView reloadData];
}

- (void)refreshMainViewWithSection:(NSInteger)section {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshMainViewAnimationWithSection:(NSInteger)section {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)refreshMainViewWithSection:(NSInteger)section andIndex:(NSInteger)index {
    @try {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

- (void)setInputFocus:(NSInteger)index {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    if ([cell isKindOfClass:[ESReturnApplyInputCell class]]) {
        ESReturnApplyInputCell *inputCell = (ESReturnApplyInputCell *)cell;
        [inputCell focusTextField];
    }
}

- (void)refundBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(refundBtnTap)]) {
        [self.delegate refundBtnTap];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(getSectionNums)]) {
        return [self.delegate getSectionNums];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getItemsNumsWithSection:)]) {
        return [self.delegate getItemsNumsWithSection:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        ESReturnApplyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnApplyItemCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = (id)self.delegate;
        [cell updateReturnApplyCellWithIndex:indexPath.row];
        return cell;
        
    }else if (indexPath.section == 1) {
        
        if (indexPath.row == 0)
        {
            ESReturnApplyWayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnApplyWayCell" forIndexPath:indexPath];
            cell.cellDelegate = (id)self.delegate;
            [cell updateCellWithIndexPath:indexPath];
            return cell;
        }
        
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(getReturnAmountStatus)])
        {
            BOOL isReturnAmount = [self.delegate getReturnAmountStatus];
            if (isReturnAmount && indexPath.row == 1)
            {
                ESReturnApplyAmountInputCell
                *cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnApplyAmountInputCell" forIndexPath:indexPath];
                cell.cellDelegate = (id)self.delegate;
                [cell updateCellWithIndexPath:indexPath];
                return cell;
            }
        }

        ESReturnApplyInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnApplyInputCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = (id)self.delegate;
        [cell updateApplyInputCell:indexPath.row];
        return cell;
        
    }else if (indexPath.section == 2) {
        ESConnectMerchantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESConnectMerchantCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = (id)self.delegate;
        [cell updateCellWithSection:indexPath.section andIndex:indexPath.row];
        return cell;
        
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        ESReturnBrandHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESReturnBrandHeaderView"];
        view.delegate = (id)self.delegate;
        [view updateBrandHeaderView];
        return view;
    }else if (section == 1) {
        if ([self.delegate respondsToSelector:@selector(getReturnGoodsDescription)]) {
            self.descriptionLabel.text = [self.delegate getReturnGoodsDescription];
        }
        return self.descriptionView;
    }

    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        ESReturnBrandFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESReturnBrandFooterView"];
        view.delegate = (id)self.delegate;
        [view updateBrandFooterView];
        return view;
    }else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor stec_viewBackgroundColor];
        
        if (section == 1) {
            view.frame = CGRectMake(0, 0, self.frame.size.width, 10);

        }else {
            view.frame = CGRectMake(0, 0, self.frame.size.width, 111);
        }
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 86;
    }else if (section == 1) {
        return 10;
    }else if (section == 2) {
        return 111;
    }
    return 0;
}
@end
