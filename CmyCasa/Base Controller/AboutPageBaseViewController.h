//
//  AboutPageBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import <UIKit/UIKit.h>

@interface AboutPageBaseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextView *aboutCopy;
@property (weak, nonatomic) IBOutlet UILabel *aboutTitle;
@property (weak, nonatomic) IBOutlet UILabel *aboutPageTitle;
@property (weak, nonatomic) IBOutlet UILabel *termsPageTitle;
@property (nonatomic) BOOL isTermsScreen;
@property (weak, nonatomic) IBOutlet UIView *termsLayout;
@property (weak, nonatomic) IBOutlet UIWebView *termsWebview;

- (IBAction)navBackIphone:(id)sender;
- (IBAction)closeAboutPage:(id)sender;

@end
