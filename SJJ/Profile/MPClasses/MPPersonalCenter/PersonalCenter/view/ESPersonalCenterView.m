//
//  ESPersonalCenterView.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/22.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESPersonalCenterView.h"
#import "ESPersonalCenterCell.h"
#import "ESPersonalHeaderView.h"
#import "ESPersonalDesignerFirstCell.h"
#import "ESPersonalActiveCell.h"
#import <Masonry.h>

@interface ESPersonalCenterView()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,ESPersonalHeaderViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ESPersonalHeaderView *headerView;
@end

@implementation ESPersonalCenterView
{
    UIButton *_headerBtn;
    UILabel *_nameLabe;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView:frame];
    }
    return self;
}

- (void)initTableView:(CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESPersonalDesignerFirstCell" bundle:nil] forCellReuseIdentifier:@"ESPersonalDesignerFirstCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESPersonalCenterCell" bundle:nil] forCellReuseIdentifier:@"ESPersonalCenterCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESPersonalActiveCell" bundle:nil] forCellReuseIdentifier:@"ESPersonalActiveCell"];
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-SCREEN_HEIGHT + 205, 0, 0, 0);
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self tableHeaderView];
    self.tableView.tableFooterView = [self tableFooterView];
    self.tableView.bounces = YES;
    
    [self addSubview:self.tableView];
}
- (void)setDelegate {
    self.headerView.delegate = (id)self.delegate;
}

- (void)refreshMainView {
    [self.tableView reloadData];
    [self.headerView updateHeaderView];
}

- (UIView *)tableHeaderView {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backView.backgroundColor = [UIColor whiteColor];
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"ESPersonalHeaderView" owner:self options:nil] firstObject];
    self.headerView.frame = CGRectMake(0, backView.frame.size.height - 205, self.frame.size.width, 205);
    [self.headerView updateHeaderView];
    [backView addSubview:self.headerView];
    return backView;
}

- (UIView *)tableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    footerView.backgroundColor = [UIColor stec_viewBackgroundColor];
    return footerView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        ESPersonalActiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESPersonalActiveCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = (id)self.delegate;
        [cell updateCellWithIndexPath:indexPath];
        return cell;
    } else {
        if ([self.delegate respondsToSelector:@selector(userIsDesigner)]) {
            BOOL isDesigner = [self.delegate userIsDesigner];
            if (isDesigner && indexPath.section == 0) {
                ESPersonalDesignerFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESPersonalDesignerFirstCell"];
                cell.delegate = (id)self.delegate;
                return cell;
            }
        }
        
        
        ESPersonalCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESPersonalCenterCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = (id)self.delegate;
        [cell updateCellWithIndexPath:indexPath];
        if ([self.delegate respondsToSelector:@selector(getItemNums:)]) {
            NSInteger num = [self.delegate getItemNums:indexPath.section];
            [cell setBottomLine:!(num >= 1 && indexPath.row + 1 == num)];
        }
        return cell;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(getSectionNums)]) {
        return [self.delegate getSectionNums];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getItemNums:)]) {
        return [self.delegate getItemNums:section];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tapItemWithIndex:andSection:)]) {
        [self.delegate tapItemWithIndex:indexPath.row andSection:indexPath.section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if ([self.delegate respondsToSelector:@selector(userIsDesigner)]) {
//        if ([self.delegate userIsDesigner] && section == 0) {
//            return 0.1f;
//        }
//    }
    if (0 == section) {
        return 0.001;
    }
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    view.backgroundColor = [UIColor stec_viewBackgroundColor];
    return view;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(tableViewDidScrollWithContentY:)])
    {
        [self.delegate tableViewDidScrollWithContentY:scrollView.contentOffset.y];
    }
}

@end
