 //
//  ProfileUserDetailsViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/6/14.
//
//

#import "ProfileUserDetailsViewController_iPhone.h"
#import "TblRecordDynamicLabelCell.h"
#import "TblRecordTextFieldCell.h"
#import "TblRecordLocationCell.h"
#import "TblRecordFinishControlsCell_iPad.h"
#import "TblRecordLabelCell.h"
#import "TblRecordWebLinkCell.h"
#import "TblRecordToggleCell.h"
#import "TblRecordProfileImageCell.h"
#import "TblRecord2TextsFieldsCell.h"
#import "TblRecordReadOnlyTextFieldCell.h"
#import "TblRecordTextViewCell.h"
#import "ControllersFactory.h"
#import "UserProfileBaseTableViewController.h"
#import "TblRecordProfileReadCell_iPhone.h"
#import "TblRecordReadOnlyIcon.h"
#import "ProgressPopupViewController.h"

#import "ConfigManager.h"

@interface ProfileUserDetailsViewController_iPhone ()

@end

@implementation ProfileUserDetailsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initContentViewer];
    [self initContent];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.isEditingPresentation) {
        [self.genericCloseButton setTitle:NSLocalizedString(@"user_profile_done_button", @"") forState:UIControlStateNormal];
        self.lblTitle.text = NSLocalizedString(@"edit_profile", @"");
    }else{
        [self.genericCloseButton setTitle:NSLocalizedString(@"user_profile_signout_lbl", @"") forState:UIControlStateNormal];
        
        if (!self.isLoggedInUserProfile) {
            self.genericCloseButton.hidden=YES;
        }else{
            self.genericCloseButton.hidden=NO;
        }

        self.lblTitle.text = @"";
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"dealloc - ProfileUserDetailsViewController_iPhone");
}

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    [parentViewController.navigationController pushViewController:self animated:animated];
    if (animated && completion != nil) {
        completion();
    }
}

- (void)dismissSelf {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.navigationController popViewControllerAnimated:YES];
                   });
}

#pragma mark -
-(void)initContentViewer{
    [super initContentViewer];
}

- (IBAction)navigateBack:(id)sender {
    [self askToLeaveWithoutSave];
//    [self.contentViewer.view removeFromSuperview];
//    [self.contentViewer removeFromParentViewController];
//    self.contentViewer.dataDelegate = nil;
//    self.contentViewer = nil;
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([[alertView message] isEqualToString:NSLocalizedString(@"ask_save_user_details", @"")]){
        
        switch (buttonIndex){
            case 0://do nothing
                break;
            case 1:
            { //check if there a need for saving
                if ([self changeExists]) {
                   [self leaveProfileEditingWithSaveChanges:nil];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }
                break;
            case 2:
            {
                [self initContent];
                dispatch_async(dispatch_get_main_queue(), ^{
                      [self.navigationController popViewControllerAnimated:YES];
                  });
            }
                break;
            default:
                break;
        }
    }
}

#pragma  mark - ProfilePageTableViewDelegate
-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path{

    NSDictionary * dict=[self.userDetails objectAtIndex:path.row];

    UserDetailFieldType fieldType = (int)[[dict objectForKey:USER_DETAIL_ROW_TYPE_KEY] integerValue];

    switch (fieldType) {
        case KUDfieldTextfield:
            return @"KUDfieldTextfield";
        case KUDfieldLongText:
            return @"KUDfieldLongText";
        case KUDfieldTextfieldWithAction:
            return @"KUDfieldTextfieldWithAction";
        case KUDfieldComposite2Texts:
            return @"KUDfieldComposite2Texts";
        case KUDfieldGenderSelection:
            return @"KUDfieldGenderSelection";
        case KUDfieldUserProfile:
            return @"KUDfieldUserProfile";
        case KUDfieldReadLabelText:
            return @"KUDfieldReadLabelText";
        default:
            return @"CellLabelIdentifier";
        case KUDfieldWebLink:
            return @"KUDfieldWebLink";
            break;
        case KUDLocation:
            return @"KUDLocation";
            break;
        case KUDfieldUserProfileIphone:
            return @"KUDfieldUserProfileIphone";
            break;
        case KUDControls:
            return @"KUDControls";
        case KUDfieldReadDynamicLabelText:
            return @"KUDfieldReadDynamicLabelText";
            break;
        case KUDfieldReadOnlyIcon:
            return @"KUDfieldReadOnlyIcon";
            break;
    }
}

-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath*)indexPath{

    NSDictionary * dict=[self.userDetails objectAtIndex:indexPath.row];

    TableRecordBaseCell * cell;
    
    switch ([[dict objectForKey:USER_DETAIL_ROW_TYPE_KEY] integerValue]) {
        case KUDfieldTextfield:
            cell =  [TblRecordTextFieldCell new];
            break;
        case KUDfieldUserProfileIphone:
            cell = [TblRecordProfileReadCell_iPhone new];
            break;
        case KUDfieldLongText:
            cell = [TblRecordTextViewCell new];
            break;
        case KUDfieldTextfieldWithAction:
            cell =  [TblRecordReadOnlyTextFieldCell new];
            break;
        case KUDfieldComposite2Texts:
            cell = [TblRecord2TextsFieldsCell new];
            break;
        case KUDfieldGenderSelection:
            cell = [TblRecordToggleCell new];
            break;
        case KUDfieldUserProfile:
            cell = [TblRecordProfileImageCell new];
            break;
        case KUDfieldWebLink:
            cell = [TblRecordWebLinkCell new];
            break;
        case KUDfieldReadLabelText:
            cell = [TblRecordLabelCell new];
            break;
        case KUDfieldReadDynamicLabelText:
            cell =  [TblRecordDynamicLabelCell new];
            break;
        case KUDControls:
            cell = [TblRecordFinishControlsCell_iPad new];
            break;
        case KUDLocation:
            cell =[TblRecordLocationCell new];
            break;
        case KUDfieldReadOnlyIcon:
            cell =[TblRecordReadOnlyIcon new];
            break;
        default:
            
            cell = [TblRecordTextFieldCell new];
            break;
    }

    [cell configEditMode:self.isEditingPresentation];

    return cell;
}

- (NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path{

    NSDictionary * dict=[self.userDetails objectAtIndex:path.row];

    switch ([[dict objectForKey:USER_DETAIL_ROW_TYPE_KEY] integerValue]) {

        case KUDfieldTextfield://done
            return 98;
            break;
        case KUDfieldLongText:
            return 133;
            break;
        case KUDfieldTextfieldWithAction: //done
            return 70;
            break;
        case KUDfieldComposite2Texts: //done
            return 123;
            break;
        case KUDfieldGenderSelection: //done
            return 95;
            break;
        case KUDfieldUserProfile: //done
            return 130;
        case KUDfieldWebLink:
            return 40;
        case KUDLocation://done
            if (![[dict objectForKey:USER_DETAIL_ROW_TYPE_VALUE] isEqualToString:@""]) {
                return 116;                
            }else{
                return 80;
            }
        case KUDControls:
            
            return 50;
        case KUDfieldReadLabelText:
            return 70;
        case KUDfieldUserProfileIphone:
            return 155;
        case KUDfieldReadOnlyIcon:
            return 40;
        case KUDfieldReadDynamicLabelText:
        {
            //get msg height
            TblRecordDynamicLabelCell * cell=   [TblRecordDynamicLabelCell new];
            [cell initCellWithData:dict];

            CGSize size = [cell getCorrentHightForContentText];

            return size.height;

        }
            break;
        default:
            return 50;

            break;
    }
}

#pragma  mark- Class Overrides

-(void)valueChangedTo:(id)nVal forField:(UserViewField)field{
    [super valueChangedTo:nVal forField:field];
}

-(void)adjustViewForField:(UITableViewCell*)cell{
    UserProfileBaseTableViewController * tableContent=(UserProfileBaseTableViewController*)self.contentViewer;
    UITableView * table=[tableContent getTableView];
    
    CGRect frame=  self.contentViewer.view.frame;
    
    frame.size.height=self.view.frame.size.height-260;
    if (@available(iOS 11.0, *)) {
        frame.size.height -= (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom);
    }
    
    [UIView animateWithDuration:0.02 delay:0.4 options:UIViewAnimationOptionAllowUserInteraction animations:^{
              self.contentViewer.view.frame=frame;
    } completion:^(BOOL finished) {
        [table scrollToRowAtIndexPath:[table indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

-(void)restoreViewForFieldInput{
    
    CGRect frame=  self.contentViewer.view.frame;
    
    frame.size.height=self.view.frame.size.height-frame.origin.y;
    
    
    [UIView animateWithDuration:0.02 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.contentViewer.view.frame=frame;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)leaveProfileEditingWithoutChanges{
    [super leaveProfileEditingWithoutChanges];
}

-(void)leaveProfileEditingWithSaveChanges:(UserDO *)deltaUser{
    [UIManager dismissKeyboard:self.view];

    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    [super leaveProfileEditingWithSaveChanges:deltaUser];
}

-(BOOL)updateOrGetCurrentLocation{
    return [super updateOrGetCurrentLocation];
}

- (void)openOptionsForField:(UserViewField)field withCurrentValue:(id)value openView:(UIView*)mview{
    [super openOptionsForField:field withCurrentValue:value openView:mview];
}

- (void)openOptionsPopover:(UIView *)mview fieldType:(UserViewField)field {
    
    TableOptionsViewController * vc = [ControllersFactory instantiateViewControllerWithIdentifier:@"TableOptionsTable" inStoryboard:kProfileStoryboard];
    
    vc.delegate = self;
    vc.inputFieldReference = field;
    
    [vc refreshTableWithNewContent:self.currentComboDataList selectedValues:self.currentSelectedValues ];
     vc.allowFreeTextInput=YES;
    
    switch (field) {
        case kFieldDesignTools:
            vc.multiChoise=YES;
            break;
        case kFieldFavoriteStyles:
            vc.multiChoise=YES;
             vc.allowFreeTextInput=NO;
            break;
        case kFieldProfessions:
            vc.multiChoise=NO;
            break;
        case kFieldUserTypes:
            vc.multiChoise=NO;
            vc.allowFreeTextInput=NO;
            break;
        default:
            vc.multiChoise=NO;
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)signoutRequested{
    
    [super signoutRequested];
}

#pragma mark- TableOptionSelectionDelegate
- (IBAction)topRightAction:(id)sender {

    if (self.isEditingPresentation){
        [self askToLeaveWithSaveAction];
    }else{
        [self signoutRequested];
    }
}

@end
