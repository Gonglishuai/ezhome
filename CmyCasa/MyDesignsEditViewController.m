//
//  MyDesignsEditViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import "MyDesignsEditViewController.h"
#import "HSPopupViewControllerHelper.h"

@interface MyDesignsEditViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) HSPopupViewControllerHelper *popupHelper;

@end

@implementation MyDesignsEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.cancelsTouchesInView = NO;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
                                  return self.coverView;
                              }
                           contentViewBlock:^{
                               return self.editDesignView;
                           }
                                   animated:animated
                                 completion:completion];
}

- (void)dismissSelf {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.popupHelper dismissViewController:self animated:YES completion:nil];
}

- (void)finishDesignDuplicateAction:(NSString *)designId withStatus:(BOOL)status sender:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        if (status == YES) {
            [self cancelPressed:nil];
            
            if (self.delegate) {
                [self.delegate designDuplicated:designId];
            }
        }else {
            [self displayNotification:YES text:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.")];
        }
        
        [sender setEnabled:YES];
        [self setUserInteraction:YES];
    });
}

-(void)deleteDesign {
    __weak typeof(self) weakSelf = self;

    [self deleteDesignInternal:^(NSString * designId, BOOL status) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf setUserInteraction:YES];
            
            if (status == YES) {
                [strongSelf dismissSelf];
                
                if (strongSelf.delegate) {
                    [strongSelf.delegate designDeleted:designId];
                }
            } else {
                [strongSelf displayNotification:YES text:NSLocalizedString(@"delete_design_error",@"Sorry, we couldn't delete your design . Please try again.")];
            }
        });
    }];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissSelf];
}

- (IBAction)savePressed:(id)sender {
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        [self cancelPressed:sender];
        return;
    }
    
    [self setUserInteraction:NO];

    //If the user changed the publish status, save the new value
    //This applies only for PUBLIC/PRIVATE design status. When the status is PUBLISHED/DELETED this is irrelevant.
    if ((self.design.publishStatus == STATUS_PRIVATE && self.designStatusSwith.isOn) ||
        (self.design.publishStatus == STATUS_PUBLIC && !self.designStatusSwith.isOn))  {

        __weak typeof(self) weakSelf = self;

        [self updateDesignStatus:self.designStatusSwith.isOn withCompletionBlock:^{
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf saveDesign];
        }];
    }
    else {
        [self saveDesign];
    }
}

- (void)saveDesign {
    __weak typeof(self) weakSelf = self;

    [self saveDesignInternal:^(DesignMetadata *metadata, BOOL status) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf setUserInteraction:YES];
            
            if (status == YES) {
                [strongSelf dismissSelf];
                if (strongSelf.delegate) {
                    [strongSelf.delegate designUpdated:metadata];
                }
            } else {
                [strongSelf displayNotification:YES text:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.")];
            }
        });
    }];
}

- (void)onKeyboardWillShow:(NSNotification *)notification {
    UIView *editorView = nil;
    CGFloat gap = 0;
    if ([self.designTitle isFirstResponder]) {
        editorView = self.designTitle;
        gap = 50;
    } else if([self.designDescription isFirstResponder]) {
        editorView = self.designDescription;
        gap = 10;
    } else {
        return;
    }

    NSDictionary *userInfoDic = notification.userInfo;
    NSTimeInterval duration = [userInfoDic[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [userInfoDic[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;

    CGRect keyboardRect = [userInfoDic[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = MIN(CGRectGetWidth(keyboardRect), CGRectGetHeight(keyboardRect));
    CGFloat ty = self.editDesignView.transform.ty;

    CGRect editorFrame = [self.view convertRect:editorView.frame fromView:editorView.superview];
    CGFloat bottomSpace = CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(editorFrame) - gap;

    if (bottomSpace < keyboardHeight) {
        CGFloat offset = ty + bottomSpace - keyboardHeight;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
                self.editDesignView.transform = CGAffineTransformMakeTranslation(0, offset);
            } completion:nil];
        });
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    if (self.editDesignView.transform.ty == 0)
        return;

    NSDictionary *userInfoDic = notification.userInfo;
    NSTimeInterval duration = [userInfoDic[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [userInfoDic[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration delay:0.0 options:options
                         animations:^{
                             self.editDesignView.transform = CGAffineTransformIdentity;
                         } completion:nil];
    });
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isFirstResponder] &&
        ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[UITextView class]])) {
        return NO;
    }
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender {
    [self.view endEditing:YES];
}

- (void)handlePan:(UIPanGestureRecognizer*)sender {
    [self.view endEditing:YES];
}

@end
