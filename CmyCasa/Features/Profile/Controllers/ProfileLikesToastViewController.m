//
//  ProfileLikesToastViewController.m
//  Homestyler
//
//  Created by Eric Dong on 5/10/18.
//

#import "ProfileLikesToastViewController.h"
#import "HSPopupViewControllerHelper.h"

static const CGFloat BG_IMAGE_INSETS_TOP_IPHONE     = 165;
static const CGFloat BG_IMAGE_INSETS_BOTTOM_IPHONE  = 92;

static const CGFloat BG_IMAGE_INSETS_TOP_IPAD       = 240;
static const CGFloat BG_IMAGE_INSETS_BOTTOM_IPAD    = 138;

@interface ProfileLikesToastViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) HSPopupViewControllerHelper *popupHelper;

@property (weak, nonatomic) IBOutlet UIView *maskBgView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation ProfileLikesToastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnBgView:)];
    tap.delegate = self;
    [self.maskBgView addGestureRecognizer:tap];

    [self setupUI];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return IS_IPAD ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}

- (void)setupUI {
    if (self.userProfile == nil) {
        self.messageLabel.text = @"";
        return;
    }

    CGFloat top = BG_IMAGE_INSETS_TOP_IPHONE;
    CGFloat bottom = BG_IMAGE_INSETS_BOTTOM_IPHONE;
    if (IS_IPAD) {
        top = BG_IMAGE_INSETS_TOP_IPAD;
        bottom = BG_IMAGE_INSETS_BOTTOM_IPAD;
    }
    UIEdgeInsets capInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
    NSString *bgImageName = nil;
    if (IS_IPAD) {
        bgImageName = self.userProfile.likes > 0 ? @"likes_popup_pad" : @"likes_popup_gray_pad";
    } else {
        bgImageName = self.userProfile.likes > 0 ? @"likes_popup" : @"likes_popup_gray";
    }
    UIImage * bgImage = [[UIImage imageNamed:bgImageName] resizableImageWithCapInsets:capInsets];
    self.bgImageView.image = bgImage;

    NSString *messageText = nil;
    NSString *messageFormat = nil;
    if ([self.userProfile isCurrentUser]) {
        if (self.userProfile.likes <= 0) {
            messageText = NSLocalizedString(@"you_liked_0_times", @"You have not received likes yet.");
        } else if (1 == self.userProfile.likes) {
            messageText = NSLocalizedString(@"you_liked_1_time", @"You received 1 like in Homestyler!");
        } else {
            messageFormat = NSLocalizedString(@"you_liked_times", @"You received %d likes in Homestyler!");
            messageText = [NSString stringWithFormat:messageFormat, self.userProfile.likes];
        }
    } else {
        NSString *userName = [self.userProfile getUserFullName];
        NSInteger argc = 1;
        if (self.userProfile.likes <= 0) {
            messageFormat = NSLocalizedString(@"user_liked_0_times", @"%@ has not received likes yet.");
        } else if (1 == self.userProfile.likes) {
            messageFormat = NSLocalizedString(@"user_liked_1_time", @"%@ received 1 like in Homestyler!");
        } else {
            messageFormat = NSLocalizedString(@"user_liked_times", @"%@ received %d likes in Homestyler!");
            argc = 2;
        }
        if (argc == 2) {
            messageText = [NSString stringWithFormat:messageFormat, userName, self.userProfile.likes];
        } else {
            messageText = [NSString stringWithFormat:messageFormat, userName];
        }
    }
    self.messageLabel.text = messageText;

    NSString *textStyle = self.userProfile.likes > 0 ? @"ProfileLikesToast_Text" : @"ProfileLikesToast_Text_NoLikes";
    [self.messageLabel setValue:textStyle forKey:@"nuiClass"];

    NSString *buttonStyle = self.userProfile.likes > 0 ? @"ProfileLikesToast_OKButton" : @"ProfileLikesToast_OKButton_NoLikes";
    [self.okButton setValue:buttonStyle forKey:@"nuiClass"];
    [self.okButton setTitle:NSLocalizedString(@"alert_action_ok", @"OK") forState:UIControlStateNormal];
}

- (HSPopupViewControllerHelper *)popupHelper {
    if (_popupHelper == nil) {
        _popupHelper = [HSPopupViewControllerHelper new];
    }
    return _popupHelper;
}

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    [self.popupHelper presentViewController:self
                     byParentViewController:parentViewController
                              maskViewBlock:^{
                                  return self.maskBgView;
                              }
                           contentViewBlock:^{
                               return self.containerView;
                           }
                                   animated:animated
                                 completion:completion];
}

- (void)dismissSelf {
    [self.popupHelper dismissViewController:self animated:YES completion:nil];
}

#pragma mark - actions

- (void)tappedOnBgView:(UITapGestureRecognizer *)sender {
    [self dismissSelf];
}

- (IBAction)okPressed:(id)sender {
    [self dismissSelf];
}

@end
