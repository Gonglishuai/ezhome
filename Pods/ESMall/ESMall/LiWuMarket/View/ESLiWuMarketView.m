//
//  ESLiWuMarketView.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLiWuMarketView.h"
#import "ESLiWuLoopCell.h"
#import "ESLiWuCategoryCell.h"
#import "ESLiWuProductCell.h"
#import "HeaderCollectionReusableView.h"
#import "ESNoMoreReusableView.h"
#import "GrayFooterCollectionReusableView.h"
#import "Masonry.h"

@interface ESLiWuMarketView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id<ESLiWuMarketViewDelegate> delegate;
@end

@implementation ESLiWuMarketView

- (instancetype)initWithDelegate:(id<ESLiWuMarketViewDelegate>)delegate {
    self = [super init];
    if (self) {
        [self initTableViewWithDelegate:delegate];
    }
    return self;
}

- (void)initTableViewWithDelegate:(id<ESLiWuMarketViewDelegate>)delegate {
    self.delegate = delegate;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[ESLiWuLoopCell class] forCellWithReuseIdentifier:@"ESLiWuLoopCell"];
    [self.collectionView registerClass:[ESLiWuCategoryCell class] forCellWithReuseIdentifier:@"ESLiWuCategoryCell"];
    [self.collectionView registerClass:[ESLiWuProductCell class] forCellWithReuseIdentifier:@"ESLiWuProductCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ESNoMoreReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ESNoMoreReusableView"];
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
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)refreshMainView {
    [self.collectionView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {//轮播
        return 1;
    }else {
        if ([self.delegate respondsToSelector:@selector(getItemsNumsWithSection:)]) {
            return [self.delegate getItemsNumsWithSection:section];
        }
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ESLiWuLoopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ESLiWuLoopCell" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell updateCell];
        return cell;
    }else if (indexPath.section == 1) {
        ESLiWuCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ESLiWuCategoryCell" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell updateCell:indexPath.item];
        return cell;
    }else {
        ESLiWuProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ESLiWuProductCell" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell updateCell:indexPath.item];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        if ([self.delegate respondsToSelector:@selector(selectItemWithSection:andIndex:)]) {
            [self.delegate selectItemWithSection:indexPath.section andIndex:indexPath.item];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CGFloat width = self.frame.size.width;
        CGFloat height = width * 125.0f / 375.0f;
        return CGSizeMake(width, height);
    }else if (indexPath.section == 1) {
        CGFloat width = (self.frame.size.width - 6 * 20) / 5;
        CGFloat height = 65.0f;
        return CGSizeMake(width, height);
    }else {
        CGFloat width = (self.frame.size.width - 15 * 2 - 10) / 2;
        CGFloat height = width + 80.0f;
        return CGSizeMake(width, height);
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if (section == 0) {
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    } else if (section == 1) {
        return UIEdgeInsetsMake(20, 15, 15, 20);
    } else {
        return UIEdgeInsetsMake(15, 15, 15, 15);
    }
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if (section == 1) {
        return 20;
    }else {
        return 10;
    }
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if (section == 1) {
        return 15.0f;
    }else {
        return 18.0f;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView" forIndexPath:indexPath];
        
        if (indexPath.section == 2) {
            header.backgroundColor = [UIColor whiteColor];
            [header setTitle:@"热卖商品" subTitle:@"HOT GOODS"];
        }else {
            header.backgroundColor = [UIColor stec_viewBackgroundColor];
        }
        
        return header;
    } else {
        if (indexPath.section == 2) {
            ESNoMoreReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ESNoMoreReusableView" forIndexPath:indexPath];
            return footer;
        } else{
            GrayFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
            footer.backgroundColor = [UIColor stec_viewBackgroundColor];
            return footer;
        }
        
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat width = self.frame.size.width;
    if (section == 2) {
        CGSize size= CGSizeMake(width, 0.18 * width);
        return size;
    } else {
        CGSize size= CGSizeMake(width, 0.001);
        return size;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGFloat width = self.frame.size.width;
    if (section == 2) {
        CGSize size= CGSizeMake(width, 60);
        return size;
    } else {
        CGSize size= CGSizeMake(width, 10);
        return size;
    }
    
}
@end
