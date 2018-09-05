//
//  iphoneProfessionalDetailsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/5/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfessionalDO.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
@interface ProfessionalDetailsViewController_iPhone : UIViewController<MFMailComposeViewControllerDelegate>


@property (nonatomic, strong) ProfessionalDO * professional;
@property (weak, nonatomic) IBOutlet UILabel *progStudioName;
@property (weak, nonatomic) IBOutlet UIButton *phone1;
@property (weak, nonatomic) IBOutlet UIButton *phone2;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *profAddress;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *professionsTitle;

- (IBAction)navBack:(id)sender;
- (IBAction)openWebsite:(id)sender;
- (IBAction)openEmail:(id)sender;
- (IBAction)callNumber:(id)sender;

@end
