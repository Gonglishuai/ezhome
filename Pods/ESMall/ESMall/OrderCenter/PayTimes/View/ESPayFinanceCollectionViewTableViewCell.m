//
//  ESPayFinanceCollectionViewTableViewCell.m
//  ESMall
//
//  Created by jiang on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESPayFinanceCollectionViewTableViewCell.h"
#import "Masonry.h"
#import "ESPayFinanceCollectionViewCell.h"

@interface ESPayFinanceCollectionViewTableViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic,strong)NSMutableArray *datasSourse;
@property(strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)NSIndexPath *financeSelectIndexPath;
@end

@implementation ESPayFinanceCollectionViewTableViewCell
{
    NSIndexPath *_indexPath;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _datasSourse = [NSMutableArray array];
    [self setCollectionView];
}



- (void)setCollectionView {
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
//    [self.contentView addSubview:_scrollView];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, 0.01) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESPayFinanceCollectionViewCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"ESPayFinanceCollectionViewCell"];
    [self.contentView addSubview:_collectionView];
    _collectionView.scrollEnabled = NO;
    WS(weakSelf)
//    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.contentView.mas_top).with.offset(0);
//        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(0);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(0);
//        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(0);
//        make.height.greaterThanOrEqualTo(@(1));
//    }];
//
//    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(weakSelf.scrollView.mas_width);
//        make.height.equalTo(weakSelf.scrollView.mas_height);
//        make.height.greaterThanOrEqualTo(@(1));
//    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).with.offset(0);
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(0);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(0);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(0);
        make.height.greaterThanOrEqualTo(@(0.5));
    }];
    
   
    
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getFinanceData)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getFinanceData];
        if (dict
            && ![dict isKindOfClass:[NSNull class]]
            && dict[@"installments"]
            && ![dict[@"installments"] isKindOfClass:[NSNull class]])
        {
             NSArray *datasArray = [NSArray array];
            @try {
                datasArray = dict[@"installments"];
            } @catch (NSException *exception) {
                SHLog(@"%@", exception.description);
            } @finally {
                [_datasSourse removeAllObjects];
                [_datasSourse addObjectsFromArray:datasArray];
            }
        }
        else {
            [_datasSourse removeAllObjects];
        }
    }
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getSelectIndexPath)])
    {
        _financeSelectIndexPath = [(id)self.cellDelegate getSelectIndexPath];
    }
    
    WS(weakSelf)
    [weakSelf.collectionView reloadData];
    [_collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.tableView) {
                    [weakSelf.tableView beginUpdates];
                    [weakSelf setCellLayout];
                    [weakSelf.tableView endUpdates];
                }
            });
        }
    }];
    
}


- (void)setCellLayout {
    WS(weakSelf)
    CGFloat h = _collectionView.contentSize.height;
    if (h == 30) {
        h = 0.5;
    }
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).with.offset(0);
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(0);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(0);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(0);
        make.height.equalTo(@(h));
    }];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasSourse.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESPayFinanceCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESPayFinanceCollectionViewCell" forIndexPath:indexPath];
    if (_datasSourse.count > indexPath.row) {
        NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
        if (_financeSelectIndexPath == indexPath) {
            [cell setFinanceInfo:dic isSelect:YES];
        } else {
            [cell setFinanceInfo:dic isSelect:NO];
        }
        
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(financeSelectedDidTapped:)])
    {
        [(id)self.cellDelegate financeSelectedDidTapped:indexPath];
        _financeSelectIndexPath = indexPath;
        [self.collectionView reloadData];
    }

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH-46)/2, 56.0);
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
    
}

@end
