
#import <UIKit/UIKit.h>

@interface ESTouchImageView : UIImageView

@property (nonatomic, assign) NSInteger index;

- (void)updateImageViewWithUrlStr:(NSString *)urlStr;

@end
