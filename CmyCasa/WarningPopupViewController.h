//
//  WarningPopupViewController.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"

@interface WarningPopupViewController : UIViewController

- (IBAction)stayPressed:(id)sender;
- (IBAction)leavePressed:(id)sender;
- (IBAction)saveDesignOnExit:(id)sender;

@property (weak, nonatomic) id <WarningPopupDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@end
