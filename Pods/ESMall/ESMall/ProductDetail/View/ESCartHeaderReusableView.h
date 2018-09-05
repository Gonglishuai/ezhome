
#import <UIKit/UIKit.h>

@protocol ESCartHeaderReusableViewDelegate <NSObject>

- (NSString *)getCartHeaderTitleAtSection:(NSInteger)section;

@end

@interface ESCartHeaderReusableView : UICollectionReusableView

@property (nonatomic, assign) id <ESCartHeaderReusableViewDelegate>headerDelegate;

- (void)updateHeaderAtSection:(NSInteger)section;

@end
