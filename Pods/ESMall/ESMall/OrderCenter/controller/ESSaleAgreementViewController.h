
#import "MPBaseViewController.h"

@protocol ESSaleAgreementViewControllerDelegate <NSObject>

- (void)saleAgreementAgreeButtonDidTapped;

@end

@interface ESSaleAgreementViewController : MPBaseViewController

@property (nonatomic, assign) id<ESSaleAgreementViewControllerDelegate>delegate;

@property (nonatomic, assign) BOOL hasApproved;

@end
