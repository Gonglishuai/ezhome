//
//  ESFilterView.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilterView.h"
#import <Masonry.h>
#import "ESFilterCell.h"
#import "ESFilterHeaderView.h"
#import "ESCollectionViewFlowLayout.h"

@interface ESFilterView()<UICollectionViewDelegate, UICollectionViewDataSource, ESCollectionViewFlowLayoutDelegate>
@property (nonatomic, weak) id <ESFilterViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ESFilterView

- (instancetype)initWithDelegate:(id <ESFilterViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self setUpCollectionView];
    }
    return self;
}

- (void)setUpCollectionView {
    ESCollectionViewFlowLayout *layout = [[ESCollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[ESFilterCell class] forCellWithReuseIdentifier:@"ESFilterCell"];
    [self.collectionView registerClass:[ESFilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ESFilterHeaderView"];
    [self addSubview:self.collectionView];
    
    __block UIView *b_self = self;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_self.mas_top);
        make.leading.equalTo(b_self.mas_leading);
        make.bottom.equalTo(b_self.mas_bottom);
        make.right.equalTo(b_self.mas_right);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.backgroundColor = [UIColor stec_viewBackgroundColor];
}

- (void)refreshMainView {
    [self.collectionView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger section = 0;
    if ([self.delegate respondsToSelector:@selector(getSectionNums)]) {
        section = [self.delegate getSectionNums];
    }
    return section;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger itemNum = 0;
    if ([self.delegate respondsToSelector:@selector(getItemNums:)]) {
        itemNum = [self.delegate getItemNums:section];
    }
    return itemNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ESFilterCell" forIndexPath:indexPath];
    cell.delegate = (id)self.delegate;
    [cell updateCell:indexPath.section andIndex:indexPath.item];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectTagItem:andIndex:)]) {
        [self.delegate selectTagItem:indexPath.section andIndex:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat width = (self.frame.size.width - 5 * 10 ) / 4;
    CGFloat height = 40.0f;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(16.0, 10.0, 16.0, 10.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 16.0f;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ESFilterHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ESFilterHeaderView" forIndexPath:indexPath];
        header.delegate = (id)self.delegate;
        [header updateHeader:indexPath.section];
        header.contentView.backgroundColor = [UIColor stec_viewBackgroundColor];
        return header;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat width = self.frame.size.width;
    CGFloat height = 40.0f;
    return CGSizeMake(width, height);
}

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSection:(NSInteger)section {
    return [UIColor whiteColor];
}
@end
