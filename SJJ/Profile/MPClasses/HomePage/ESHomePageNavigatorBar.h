
#import <UIKit/UIKit.h>

@protocol ESHomePageNavigatorBarDelegate <NSObject>

- (void)leftButtonDidTapped;

- (void)searchButtonDidTapped;

- (void)rightButtonDidTapped;

@end

@interface ESHomePageNavigatorBar : UIView

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadStatusView;

@property (nonatomic, assign) id<ESHomePageNavigatorBarDelegate>delegate;

+ (instancetype)homePageNavigatorBar;
@end
