
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESEnterpriseAlertType)
{
    ESEnterpriseAlertTypeUnknow,
    ESEnterpriseAlertTypeSuccess,
    ESEnterpriseAlertTypeFailure
};

@interface ESEnterpriseAlertView : UIView

+ (void)showAlertWithType:(ESEnterpriseAlertType)type
                 callback:(void (^) (ESEnterpriseAlertType type))callback;

@end
