
#import <UIKit/UIKit.h>

@interface ESGoldAlertView : UIView

+ (void)showGoldAlertViewCallBack:(void(^)(BOOL sureStatus))callback;

@end
