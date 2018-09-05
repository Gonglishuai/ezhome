
#import <UIKit/UIKit.h>

@protocol CoLinkPageViewDelegate <NSObject>

- (void)enterButtonDidTapped:(UIView *)view;

@end

@interface CoLinkPageView : UIView

@property (nonatomic, assign) id<CoLinkPageViewDelegate>viewDelegate;

+ (instancetype)linkPageView;

- (void)updateLinkPageViewWithImages:(NSArray *)images;

@end
