
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESProductHeaderType)
{
    ESProductHeaderTypeUnKnow = 0,
    ESProductHeaderTypeSeg,
    ESProductHeaderTypeLabel
};

@protocol ESProductHeaderViewDelegate <NSObject>

@end

@interface ESProductHeaderView : UIScrollView

@property (nonatomic, assign) id<ESProductHeaderViewDelegate> _Nullable headerDelegate;

- (void)updateHeaderWithSegTitles:( NSArray <NSString *> * _Nonnull )titles
                      bottomTitle:(NSString * _Nonnull)bottomTitle;

- (void)updateSelectedSegmentAtIndex:(NSInteger)index;

- (void)updateHeaderWithType:(ESProductHeaderType)headerType;

@end
