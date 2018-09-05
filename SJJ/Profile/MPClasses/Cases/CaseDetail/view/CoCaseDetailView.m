//
//  CoCaseDetailView.m
//  Consumer
//
//  Created by Jiao on 16/7/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCaseDetailView.h"
#import "CoCaseBottomBarView.h"
#import "CoCaseDetailFooterView.h"
#import "CoCaseImageCell.h"
#import "CoCaseIntroductionCell.h"

@interface CoCaseDetailView()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@end
@implementation CoCaseDetailView
{
    CGRect _frame;
    UITableView *_myTableView;
    CoCaseBottomBarView *_bottomView;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _frame = frame;
        [self createViewWithFrame:frame];
    }
    return self;
}

- (void)createViewWithFrame:(CGRect)frame {
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.estimatedRowHeight = 1000;
    _myTableView.rowHeight = UITableViewAutomaticDimension;
    [_myTableView registerNib:[UINib nibWithNibName:@"CoCaseImageCell" bundle:nil] forCellReuseIdentifier:@"CoCaseImageCell"];
    [_myTableView registerNib:[UINib nibWithNibName:@"CoCaseIntroductionCell" bundle:nil] forCellReuseIdentifier:@"CoCaseIntroductionCell"];
    [self addSubview:_myTableView];
    _myTableView.backgroundColor = COLOR(238, 241, 244, 1);
    _bottomView = [[CoCaseBottomBarView alloc] initWithFrame:CGRectMake(0, _frame.size.height, _frame.size.width, 59)];
    [self addSubview:_bottomView];
}

- (void)showBottomView {
    if (!_bottomView.delegate) {
        _bottomView.delegate = (id)self.delegate;
    }
    [_bottomView getData];

    [UIView animateWithDuration:0.75f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bottomView.frame = CGRectMake(0, _frame.size.height - 59, _frame.size.width, 59);
    } completion:nil];
    
}

- (void)hiddenBottomView {
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bottomView.frame = CGRectMake(0, _frame.size.height + 18, _frame.size.width, 59);
    } completion:nil];
}

- (void)refreshMiddleView {
    [_myTableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        CoCaseIntroductionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoCaseIntroductionCell"];
        cell.delegate = (id)self.delegate;
        [cell updateIntroductionCellWithIndex:indexPath.row];
        return cell;
    }else {
        CoCaseImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoCaseImageCell"];
        cell.delegate = (id)self.delegate;
        [cell updateCellForSection:indexPath.section withIndex:indexPath.row];
        return cell;
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        CoCaseDetailFooterView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"CoCaseDetailFooterView" owner:self options:nil] firstObject];
        footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        footerView.delegate = (id)self.delegate;
        [footerView updateCaseDetailFooterView];
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 0.01f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else {
        if ([self.delegate respondsToSelector:@selector(getCaseImages)]) {
            return [self.delegate getCaseImages] + 1;
        }
        return 1;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hiddenBottomView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self showBottomView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self showBottomView];
}

@end
