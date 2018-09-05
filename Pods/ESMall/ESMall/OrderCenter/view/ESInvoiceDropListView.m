//
//  ESInvoiceDropListView.m
//  Consumer
//
//  Created by jiang on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESInvoiceDropListView.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESInvoiceDropListCell.h"

@interface ESInvoiceDropListView ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) void(^myblock)(NSIndexPath *);
@property (strong, nonatomic) NSMutableArray *datasSource;
@end

@implementation ESInvoiceDropListView

+ (instancetype)creatWithFrame:(CGRect)frame datasSource:(NSArray *)datasSource Block:(void(^)(NSIndexPath *))block {
    ESInvoiceDropListView *dropListView = [[ESMallAssets hostBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    dropListView.frame = frame;
    dropListView.myblock = block;
    dropListView.datasSource = [NSMutableArray arrayWithArray:datasSource];
    
    
    return dropListView;
}
- (void)initTable {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESInvoiceDropListCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESInvoiceDropListCell"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    _tableView.separatorColor = [UIColor whiteColor];
    [self addSubview:_tableView];
}
- (void)setWithFrame:(CGRect)frame datasSource:(NSArray *)datasSource Block:(void(^)(NSIndexPath *))block {
    self.frame = frame;
    self.myblock = block;
    self.datasSource = [NSMutableArray arrayWithArray:datasSource];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _datasSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _datasSource[indexPath.section];
    ESInvoiceDropListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESInvoiceDropListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTitle:title titleColor:[UIColor stec_subTitleTextColor]];
    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_myblock) {
        _myblock(indexPath);
    }
    [self removeFromSuperview];
}



@end
