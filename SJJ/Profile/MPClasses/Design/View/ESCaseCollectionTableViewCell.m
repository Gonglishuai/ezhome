//
//  ESCaseCollectionTableViewCell.m
//  Consumer
//
//  Created by jiang on 2017/8/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseCollectionTableViewCell.h"
#import "ESCaseProductCollectionViewCell.h"
#import "ESCaseProductModel.h"
#import <Masonry.h>
@interface ESCaseCollectionTableViewCell()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(strong, nonatomic) UICollectionView *collectionView;
@property(strong, nonatomic) NSMutableArray *dataArray;
@property(strong, nonatomic) void(^myBlock)(NSString *);

@end

@implementation ESCaseCollectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _dataArray = [NSMutableArray array];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,(SCREEN_WIDTH-30-20)/2.5+30+31) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"ESCaseProductCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ESCaseProductCollectionViewCell"];
    [self.contentView addSubview:_collectionView];
    WS(weakSelf)
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top);
        make.right.equalTo(weakSelf.contentView.mas_right);
        make.left.equalTo(weakSelf.contentView.mas_left);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(-1);
        
//        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
//        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
        make.height.greaterThanOrEqualTo(@((SCREEN_WIDTH-30-20)/2.5+30+31));
    }];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFavDatas:(NSArray *)datas tapBlock:(void(^)(NSString *))tapBlock {
    _dataArray = [NSMutableArray arrayWithArray:datas];
    _myBlock = tapBlock;
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESCaseProductCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESCaseProductCollectionViewCell" forIndexPath:indexPath];
    if (_dataArray.count>indexPath.row) {
        ESCaseProductModel *prodtctInfo = [_dataArray objectAtIndex:indexPath.row];
        [cell setFavDatas:prodtctInfo];
    }
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataArray.count>indexPath.row) {
        ESCaseProductModel *prodtctInfo = [_dataArray objectAtIndex:indexPath.row];
        if (_myBlock) {
            _myBlock([NSString stringWithFormat:@"%@", prodtctInfo.catentrySpuId]);
        }
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH-30-20)/2.5, (SCREEN_WIDTH-30-20)/2.5+30);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}



-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size= CGSizeMake(0.001, 0.001);
    return size;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize size= CGSizeMake(0.001, 0.001);
    return size;

}

@end
