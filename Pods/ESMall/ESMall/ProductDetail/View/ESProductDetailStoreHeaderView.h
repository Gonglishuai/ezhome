
#import <UIKit/UIKit.h>

@protocol ESProductDetailStoreHeaderViewwDelegate <NSObject>

- (void)tapHeaderPointy:(CGFloat)pointY endStatus:(BOOL)endStatus;

@end

@interface ESProductDetailStoreHeaderView : UIView

@property (nonatomic, assign) id<ESProductDetailStoreHeaderViewwDelegate>headerDelegate;

@end
