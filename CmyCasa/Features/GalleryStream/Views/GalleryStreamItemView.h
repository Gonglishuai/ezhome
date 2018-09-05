//
//  GalleryStreamItemView.h
//  EZHome
//
//  Created by liuyufei on 4/18/18.
//

#import <UIKit/UIKit.h>

@interface GalleryStreamItemView : UICollectionViewCell

@property (nonatomic, strong) GalleryItemDO *item;
@property (nonatomic, weak) id<DesignItemDelegate> delegate;

+ (CGFloat)calcDesignDescrtiptionTextHeightForDesign:(GalleryItemDO *)item cellWidth:(CGFloat)width;

- (void)updateLikeStatus;
- (void)updateCommentsCount;

@end
