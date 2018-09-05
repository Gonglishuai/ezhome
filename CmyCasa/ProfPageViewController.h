//
//  ProfPageViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UserLoginViewController.h"
//GAITrackedViewController
@interface ProfPageViewController : UIViewController<UserLogInDelegate,ProfessionalPageDelegate ,MFMailComposeViewControllerDelegate>
{
@private
    UserLoginViewController*  _userLoginViewController;
    NSString*                 _profId;
    NSMutableArray*           _projectViews;
    NSString*                 _webSiteUrl;
    NSString*                 _email;
}

- (void) setProfId:(NSString*) profId;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *professionLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UILabel *webSiteLabel;
@property (weak, nonatomic) IBOutlet UIButton *phone1Label;
@property (weak, nonatomic) IBOutlet UIButton *phone2Label;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *dynamicPromoView;
@property (weak, nonatomic) IBOutlet UIView *dynamicProjectsTitleView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtnLiked;

- (IBAction)likeBtnPressed:(id)sender;
- (IBAction)webSitePressed:(id)sender;
- (IBAction)emailPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)phoneNumberPressed:(id)sender;




@end
