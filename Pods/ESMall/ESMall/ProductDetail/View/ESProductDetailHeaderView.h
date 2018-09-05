
#import <UIKit/UIKit.h>

@protocol ESProductDetailHeaderViewDelegate <NSObject>

- (BOOL)getShowStatusAtSection:(NSInteger)section;

- (NSString *)getHeaderTitleAtSection:(NSInteger)section;

- (void)productHeaderDidTappedAtIndex:(NSInteger)index
                               status:(BOOL)showStatus;

@end

@interface ESProductDetailHeaderView : UIView

@property (nonatomic, assign) id<ESProductDetailHeaderViewDelegate>headerDelegate;

+ (instancetype)productDetailHeaderView;

- (void)updateHeaderAtIndex:(NSInteger)index;

@end
