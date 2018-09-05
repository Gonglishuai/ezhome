//
//  CoMyFocusView.m
//  Consumer
//
//  Created by Jiao on 16/7/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoMyFocusView.h"
#import "ESDiyRefreshHeader.h"
#import "CoMyFocusCell.h"

@interface CoMyFocusView ()<UITableViewDelegate,UITableViewDataSource>

@end
@implementation CoMyFocusView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createFocusTableView];
    }
    
    return self;
}

- (void)createFocusTableView {
    self.focusDesignersTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.frame)) style:UITableViewStylePlain];
    self.focusDesignersTabelView.delegate = self;
    self.focusDesignersTabelView.dataSource = self;
    self.focusDesignersTabelView.separatorStyle = UITableViewCellSelectionStyleNone;
//    self.focusDesignersTabelView.backgroundColor = [UIColor colorWithRed:239.0/255 green:241.0/255 blue:245.0/255 alpha:1];
    [self.focusDesignersTabelView registerNib:[UINib nibWithNibName:@"CoMyFocusCell" bundle:nil] forCellReuseIdentifier:@"CoMyFocusCell"];
    
    [self addSubview:self.focusDesignersTabelView];
    
//    [self addMyMarkRefresh];

}

- (void)addMyMarkRefresh {
    WS(weakSelf);
    self.focusDesignersTabelView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(focusDesignersViewRefreshLoadNewData:)]) {
            [weakSelf endFooterRefresh];
            [weakSelf.delegate focusDesignersViewRefreshLoadNewData:^{
                [weakSelf endHeaderRefresh];
            }];
        }
    }];
    
    self.focusDesignersTabelView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        if ([weakSelf.delegate respondsToSelector:@selector(focusDesignersViewRefreshLoadMoreData:)]) {
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate focusDesignersViewRefreshLoadMoreData:^{
                [weakSelf endFooterRefresh];
            }];
        }
    }];
    [self.focusDesignersTabelView.mj_header beginRefreshing];
}

/// end header refresh
- (void)endHeaderRefresh {
    [self.focusDesignersTabelView.mj_header endRefreshing];
}

/// end footer refresh
- (void)endFooterRefresh {
    [self.focusDesignersTabelView.mj_footer endRefreshing];
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.delegate respondsToSelector:@selector(getFocusDesignersCount)])
        return [self.delegate getFocusDesignersCount];
    
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CoMyFocusCell * _cell = [tableView dequeueReusableCellWithIdentifier:@"CoMyFocusCell" forIndexPath:indexPath];
//    _cell.backgroundColor = [UIColor clearColor];
    _cell.delegate = (id)self.delegate;
    [_cell updateCellForIndex:indexPath.row];
    
    return _cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]) {
        
        [self.delegate didSelectItemAtIndex:indexPath.row];
    }
}

#pragma mark- Public interface methods

-(void) refreshFocusDesignersUI
{
    [self.focusDesignersTabelView reloadData];
}


@end
