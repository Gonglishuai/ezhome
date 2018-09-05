
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESHomePageRecommendType)
{
    ESHomePageRecommendTypeFirst = 0,
    ESHomePageRecommendTypeSecond,
    ESHomePageRecommendTypeThird,
    ESHomePageRecommendTypeFourth
};

@protocol ESHomePageRecommendCellDelegate <NSObject>

- (NSArray *)getRecommendInformation;

- (void)recommendDidTappedWithType:(ESHomePageRecommendType)type;

@end

@interface ESHomePageRecommendCell : UICollectionViewCell

@property (nonatomic, assign) id<ESHomePageRecommendCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
