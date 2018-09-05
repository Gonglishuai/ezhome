//
//  RegistrationViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import "UserRegistrationBaseViewController.h"
#import "TTTAttributedLabel.h"

@interface RegistrationViewController_iPhone : UserRegistrationBaseViewController
@property (nonatomic, assign) BOOL isOnlyEmailActive;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel * lblPrivacyStatementAndTerms;
@property (nonatomic, strong) IBOutlet UILabel * titleLbl;
- (IBAction)navBack:(id)sender;


@end
