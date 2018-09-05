//
//  iPadSavedDesignPopup.m
//  CmyCasa
//
//  Created by Dor Alon on 12/31/12.
//
//

#import "SavedDesignViewController_iPad.h"
#import "PopOverViewController.h"

#define ANIMATION_DURATION 0.3f
#define SAVE_POPUP_ORIGIN_Y -180
@interface SavedDesignViewController_iPad ()
@end

@implementation SavedDesignViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleText.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"roomTypesSegue"])
	{
		PopOverViewController* roomTypesViewController = [segue destinationViewController];
        _roomTypesPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [roomTypesViewController setDataArray:self.roomTypesArr];
        roomTypesViewController.popOverType = kPopOverRoom;
        roomTypesViewController.delegate = self;
	}
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [super textViewDidBeginEditing:textView];
 
    CGRect frm = self.view.frame;
    frm.origin.y = SAVE_POPUP_ORIGIN_Y;
    
    if (![self isAnimationDeployed]) {
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.frame = frm;
        } completion:^(BOOL finished) {
            [self setAnimationDeployed:YES];
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    
    CGRect frm = self.view.frame;
    frm.origin.y = 0;
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.frame = frm;
    } completion:^(BOOL finished) {
        [self setAnimationDeployed:NO];
    }];
}

- (IBAction)cancelPressed:(id)sender {
    if ([self.designDelegate respondsToSelector:@selector(saveDesignPopupClosedOnCancel)]) {
        [self.designDelegate performSelector:@selector(saveDesignPopupClosedOnCancel) withObject:nil];
    }
    [self.view endEditing:YES];
    
    self.errorLabel.text = @"";
    
    CGRect frm = self.view.frame;
    frm.origin.y = 0;
    self.view.frame = frm;
   
    [self setAnimationDeployed:NO];
}

- (void) setUserInteraction:(Boolean) isEnabled {
    [self.coverView setHidden:isEnabled];
    
    isEnabled ? [self.activityIndicator stopAnimating] : [self.activityIndicator startAnimating];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect frm = self.view.frame;
    frm.origin.y = SAVE_POPUP_ORIGIN_Y;
    if (![self isAnimationDeployed]) {
        
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.frame = frm;
        } completion:^(BOOL finished) {
            [self setAnimationDeployed:YES];
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    CGRect frm = self.view.frame;
    frm.origin.y = 0;
    if (![self isAnimationDeployed]) {
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.frame = frm;
        } completion:^(BOOL finished) {
            [self setAnimationDeployed:NO];
        }];
    }
}

#pragma mark - PopoverDelegate
- (void) roomTypeSelectedKey:(NSString *)key value:(NSString *)value{
    [_roomTypesPopover dismissPopoverAnimated:YES];
    _selectedRoomTypeKey = key;
    [self changeRoomTypeBtnTitle:value];
}


#pragma mark - Notification
- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect frm = self.view.frame;
    frm.origin.y = 0;
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.frame = frm;
    } completion:^(BOOL finished) {
        [self setAnimationDeployed:NO];
    }];
}

- (IBAction)isPublicAction:(UISwitch *)sender {
    BOOL isOpen = !sender.on;
    [sender setOn:!isOpen];
    if (sender.on) {
        self.lblSwitchTitle.text = NSLocalizedString(@"design_public", @"");
    }else{
        self.lblSwitchTitle.text = NSLocalizedString(@"design_private", @"");
    }
}
@end
