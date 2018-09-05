
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ESItemAlignType)
{
    ESItemAlignTypeLeft,
    ESItemAlignTypeCenter,
    ESItemAlignTypeRight
};

@interface ESProductCartFlowLayout : UICollectionViewFlowLayout

/// 两个Cell之间的距离
@property (nonatomic, assign) CGFloat betweenOfCell;

/// cell对齐方式
@property (nonatomic, assign) ESItemAlignType cellType;

- (instancetype)initWthType:(ESItemAlignType)cellType;

@end
