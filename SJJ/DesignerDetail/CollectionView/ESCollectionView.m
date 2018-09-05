//
//  ESCollectionView.m
//  EZHome
//
//  Created by shiyawei on 6/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCollectionView.h"
#import "ESTagFlowLayout.h"
#import "ESTagCollectionViewCell.h"

@interface ESCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ESTagFlowLayout *flowLayout;
@property (nonatomic,strong)    NSArray *counts;
@end

static NSString * const collectionCellID = @"ESTagCollectionViewCell";

@implementation ESCollectionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}



- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    [self addSubview:self.collectionView];
}

- (void)setDatas:(NSArray *)datas counts:(NSArray *)counts {
    self.datas = datas;
    self.counts = [NSArray arrayWithArray:counts];
    [self addSubview:self.collectionView];
}

+ (CGFloat)getHeight:(NSArray *)datas {
    return 10;
}

#pragma mark - collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ESTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    cell.contentString = self.datas[indexPath.item];
    if (self.counts.count > 0 || self.counts != nil) {
        cell.contentString = [NSString stringWithFormat:@"%@(%@)",self.datas[indexPath.item],self.counts[indexPath.item]];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegate


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *subTitle = self.datas[indexPath.item];
    return CGSizeMake([self stringSizeWithFont:[UIFont systemFontOfSize:13.0] maxWidth:1000 maxHeight:30 title:subTitle].width + 30,30);
}

-(UICollectionView *)collectionView {
    if (_collectionView==nil) {
        self.flowLayout = [[ESTagFlowLayout alloc] init];
        self.flowLayout.sectionHeadersPinToVisibleBounds = YES;
        self.flowLayout.sectionInset = UIEdgeInsetsMake(12, 15, 13, 15);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ESTagCollectionViewCell class] forCellWithReuseIdentifier:collectionCellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizesSubviews = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.bounces = NO;

    }
    return _collectionView;
}

- (CGSize)stringSizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight title:(NSString *)title {
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    CGSize maxSize = CGSizeMake(maxWidth, maxHeight);
    attr[NSFontAttributeName] = font;
    return [title boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    
}

@end
