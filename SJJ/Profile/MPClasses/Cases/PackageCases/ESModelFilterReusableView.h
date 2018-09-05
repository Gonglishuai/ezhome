
#import <UIKit/UIKit.h>

@protocol ESModelFilterReusableViewDelegate <NSObject>

- (NSString *)getFilterHeaderTitleAtSection:(NSInteger)section;

@end

@interface ESModelFilterReusableView : UICollectionReusableView

@property (nonatomic, assign) id<ESModelFilterReusableViewDelegate>headerDelegate;

- (void)updateFilterHeaderViewWithSection:(NSInteger)section;

@end
