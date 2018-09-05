//
// Created by Berenson Sergei on 12/31/13.
//

#import "ProfileUserDetailsViewController_iPad.h"
#import "ControllersFactory.h"
#import "TblRecordTextFieldCell.h"
#import "TblRecordTextViewCell.h"
#import "TblRecord2TextsFieldsCell.h"
#import "TblRecordProfileImageCell.h"
#import "UserProfileBaseTableViewController.h"
#import "TblRecordToggleCell.h"
#import "UserCombosResponse.h"
#import "UserComboDO.h"
#import "TableOptionsViewController.h"
#import "UserExtendedDetails.h"
#import "TblRecordReadOnlyTextFieldCell.h"
#import "TblRecordFinishControlsCell_iPad.h"
#import "TblRecordLabelCell.h"
#import "TblRecordWebLinkCell.h"
#import "TblRecordDynamicLabelCell.h"
#import "LocationManager.h"
#import "TblRecordLocationCell.h"
#import "TblRecordReadOnlyIcon.h"
#import "TblRecordFullNameAndProfessionionCell.h"
#import "ProgressPopupViewController.h"

#define PROFILE_BACKGROUND_COLOR ([UIColor colorWithRed:234.0f/255.f green:234.0f/255.f blue:234.0f/255.f alpha:1.0f])


@interface ProfileUserDetailsViewController_iPad ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@end


@implementation ProfileUserDetailsViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view setValue:@"EditProfileview" forKeyPath:@"nuiClass"];
    [self initContentViewer];
    [self initContent];
}

-(void)initContent{
    [super initContent];
    
    [self.contentViewer refreshContent];
}

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];

    if (!animated)
        return;

    //self.view.transform = CGAffineTransformMakeScale(0.01, 0.01);

    [UIView animateWithDuration:0.5 animations:^{
        [self.bgView setAlpha:0.5];
    } completion:nil];

//    [UIView animateWithDuration:0.5
//                          delay:0.0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:0.3
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.view.transform = CGAffineTransformIdentity;
//                     } completion:^(BOOL finished) {
//                         if (completion != nil) {
//                             completion();
//                         }
//                     }];
}

- (void)dismissSelf {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:0.3 animations:^{
                           [self.containerView setAlpha:0.0];
                       } completion:^(BOOL finished) {
                           [self.bgView setAlpha:0.0];
                           [self.containerView setAlpha:1.0];
                           [self.view removeFromSuperview];
                           [self removeFromParentViewController];
                       }];
                   });
}

#pragma mark- Super class overrides
-(void)leaveProfileEditingWithSaveChanges:(UserDO *)deltaUser{
    [[ProgressPopupBaseViewController sharedInstance] startLoading:(UIViewController*)self.rootUserDelegate];
    
    [super leaveProfileEditingWithSaveChanges:deltaUser];
}

#pragma mark - ProfileUserDetailsDelegate

-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path{

    NSDictionary * dict = [self.userDetails objectAtIndex:path.row];

    switch ([[dict objectForKey:USER_DETAIL_ROW_TYPE_KEY] integerValue]) {
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
        case KUDControls:
            return @"KUDControls";
        case KUDfieldReadDynamicLabelText:
            return @"KUDfieldReadDynamicLabelText";
            break;
        case KUDfieldReadOnlyIcon:
            return @"KUDfieldReadOnlyIcon";
            break;
        case KUDfieldFullNameAndProfession:
            return @"KUDfieldFullNameAndProfession";
            break;
    }
}

-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath*)indexPath{

    NSDictionary * dict = [self.userDetails objectAtIndex:indexPath.row];

    TableRecordBaseCell * cell;

    switch ([[dict objectForKey:USER_DETAIL_ROW_TYPE_KEY] integerValue]) {
        case KUDfieldTextfield:
            cell =  [TblRecordTextFieldCell new];
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
        case KUDfieldFullNameAndProfession:
            cell = [TblRecordFullNameAndProfessionionCell new];
            break;
        default:
            cell = [TblRecordTextFieldCell new];
            break;
    }

    [cell configEditMode:self.isEditingPresentation];

    return cell;
}

- (NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path
{
    NSDictionary * dict = [self.userDetails objectAtIndex:path.row];

    NSInteger baseSize = 50;
    
    switch ([[dict objectForKey:USER_DETAIL_ROW_TYPE_KEY] integerValue]) {

        case KUDfieldTextfield:
            return 60;
            break;
        case KUDfieldLongText:
            return 120;
            break;
        case KUDfieldTextfieldWithAction:
            return baseSize;
            break;
        case KUDfieldComposite2Texts:
            return baseSize;
            break;
        case KUDfieldGenderSelection:
            return baseSize;
            break;
        case KUDfieldUserProfile:
            return 141;
        case KUDfieldWebLink:
            return baseSize;
        case KUDLocation:
            return 56;
        case KUDControls:
            return baseSize;
        case KUDfieldReadLabelText:
            return 40;
        case KUDfieldFullNameAndProfession:
            return 40;
        case KUDfieldReadOnlyIcon:
            return 30;
        case KUDfieldReadDynamicLabelText:
        {
            //get msg height
            TblRecordDynamicLabelCell * cell = [TblRecordDynamicLabelCell new];
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

- (IBAction)closePressed:(id)sender {
    [self askToLeaveWithoutSave];
}

- (IBAction)donePressed:(id)sender {
    [self askToLeaveWithSaveAction];
}

@end
