//
//  iphoneMyDesignEditViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "MyDesignEditViewController_iPhone.h"
#import "ImageFetcher.h"

#define GAP 10

@interface MyDesignEditViewController_iPhone () <UIGestureRecognizerDelegate>

@end

@implementation MyDesignEditViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *space = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
    self.designTitle.leftView = space;
    self.designTitle.leftViewMode = UITextFieldViewModeAlways;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.cancelsTouchesInView = NO;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    [parentViewController.navigationController pushViewController:self animated:animated];
    if (animated && completion != nil) {
        completion();
    }
}

- (void)dismissSelf:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissSelf:YES];
}

- (IBAction)redesignPressed:(id)sender {
    
    if (self.delegate != nil) {
        [self.delegate redesign:self.design];
    }
}

- (IBAction)savePressed:(id)sender {
    
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        [self dismissSelf:YES];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self setUserInteraction:NO];
    
    //If the user changed the publish status, save the new value
    //This applies only for PUBLIC/PRIVATE design status. When the status is PUBLISHED/DELETED this is irrelevant.
    if ((self.design.publishStatus == STATUS_PUBLIC) != self.designStatusSwith.isOn) {

        __weak typeof(self) weakSelf = self;
        [self updateDesignStatus:self.designStatusSwith.isOn withCompletionBlock:^{
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf saveDesign];
        }];
    } else {
        [self saveDesign];
    }
}

#pragma mark- Base class overrides

- (void)saveDesign {
    __weak typeof(self) weakSelf = self;

    [self saveDesignInternal:^(DesignMetadata *metadata, BOOL status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;

            [strongSelf setUserInteraction:YES];
            
            if (status == YES) {
                [strongSelf dismissSelf:YES];
                if (strongSelf.delegate) {
                    [strongSelf.delegate designUpdated:metadata];
                }
            } else {
                UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                     
                                                               message:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.")
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"")  otherButtonTitles: nil];
                [alert show];
            }
        });
    }];
}

- (void)finishDesignDuplicateAction:(NSString *)designId withStatus:(BOOL)status sender:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^ {
        if (status) {
            if (self.delegate) {
                [self.delegate designDuplicated:designId];
            }
            // TODO: show toast
        }
        else {
            UIAlertView * alert= [[UIAlertView alloc] initWithTitle:@""
                                  
                                                            message:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
            [alert show];
        }
        [sender setEnabled:YES];
        [self setUserInteraction:YES];
        
    });
}

-(void)deleteDesign{
    
    [self setUserInteraction:NO];

    __weak typeof(self) weakSelf = self;

    [self deleteDesignInternal:^(NSString * designId, BOOL status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;

            [strongSelf setUserInteraction:YES];
            if (status == YES) {
                [strongSelf dismissSelf:NO];
                if (strongSelf.delegate) {
                    [strongSelf.delegate designDeleted:designId];
                }
            }else {
                UIAlertView * alert= [[UIAlertView alloc] initWithTitle:@""
                                      
                                                                message:NSLocalizedString(@"delete_design_error",@"Sorry, we couldn't delete your design . Please try again.")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
                [alert show];
            }
        });
    }];
}

- (void)updateDesignStatusFinished:(NSString *)designId serverResponse:(id)serverResponse error:(id)error {
    BOOL failed = NO;

    if (error) {
        failed = YES;
    } else {
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(designPublishStateChanged:status:)])) {
                [self.delegate designPublishStateChanged:designId status:self.design.publishStatus];
            }
        } else {
            failed = YES;
        }
    }

    if (failed) {
        UIAlertView * alert= [[UIAlertView alloc] initWithTitle:@""

                                                        message:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design. Please try again.")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
        [alert show];
    }

    [self setUserInteraction:YES];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    float contentOffset = textField.frame.origin.y - GAP;
    [self.pageScroll setContentOffset:CGPointMake(0, contentOffset) animated:YES];
    [self.pageScroll setScrollEnabled:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.pageScroll setScrollEnabled:YES];
    [self.pageScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    float contentOffset = textView.frame.origin.y - GAP;
    [self.pageScroll setContentOffset:CGPointMake(0, contentOffset) animated:YES];
    [self.pageScroll setScrollEnabled:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.pageScroll setScrollEnabled:YES];
    [self.pageScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isFirstResponder] &&
        ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[UITextView class]])) {
        return NO;
    }
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

- (void)handlePan:(UIPanGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

@end
