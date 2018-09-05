//
// Created by Berenson Sergei on 1/6/14.
//


#import "TblRecordLocationCell.h"
#import "LocationManager.h"
#import "TblRecordDynamicLabelCell.h"
#import "TblRecordLabelCell.h"
#import "TblRecordFinishControlsCell_iPad.h"
#import "TblRecordReadOnlyTextFieldCell.h"
#import "UserExtendedDetails.h"
#import "UserComboDO.h"
#import "UserCombosResponse.h"
#import "TblRecordToggleCell.h"
#import "TblRecordProfileImageCell.h"
#import "TblRecord2TextsFieldsCell.h"
#import "TblRecordTextViewCell.h"
#import "TblRecordTextFieldCell.h"
#import "ControllersFactory.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "ProfileUserDetailsBaseViewController.h"
#import "NSString+Contains.h"
#import "ProgressPopupViewController.h"

@interface ProfileUserDetailsBaseViewController ()
-(void)disregardChangesOnProfileObject;
@end

@implementation ProfileUserDetailsBaseViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UserManager sharedInstance] getUserComboOptionsWithCompletionBlock:^(id serverResponse, id error) {
        
        if (error== nil){
            self.comboOptions = serverResponse;
        }else{
            self.comboOptions = [UserCombosResponse new];
        }
        
    } queue:dispatch_get_main_queue()];
    
    self.changesMade=NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshContent];
}

-(void)dealloc{
    self.rootUserDelegate = nil;
    [self.userDetails removeAllObjects];
    self.userDetails = nil;
    
    [self.currentComboDataList removeAllObjects];
    self.currentComboDataList = nil;
    
    self.editModeUserDO = nil;
    self.editModePublishDO = nil;
    self.originalUser = nil;
    self.comboOptions = nil;
    self.comboPopover = nil;
    self.currentSelectedValues = nil;
    NSLog(@"dealloc - ProfileUserDetailsBaseViewController");
}

#pragma mark -

-(void)initContent {
    self.editModePublishDO = [[UserDO alloc] init];
    self.userDetails = [NSMutableArray array];

    if(self.isLoggedInUserProfile){
        self.editModeUserDO=[[[UserManager sharedInstance] currentUser]copy];
        self.originalUser=[[[UserManager sharedInstance] currentUser]copy];

        if (self.isEditingPresentation) {
            self.userDetails = [self.editModeUserDO getUserProfileDetails:self.isEditingPresentation];
        }else{
            UserProfile * profile=[[HomeManager sharedInstance] getCurrentStoredProfileForLoggedInUser];
            if (profile) {
                UserDO * user=[profile generateUserDOFromProfile];
                self.userDetails=[user getUserProfileDetails:self.isEditingPresentation];
                
            }else{
                self.userDetails=[[[UserManager sharedInstance] currentUser]getUserProfileDetails:self.isEditingPresentation];
            }
        }
    }else{

        if (self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(getUserProfileObject)]) {
            UserProfile * profile=[self.rootUserDelegate getUserProfileObject];
            UserDO * user=[profile generateUserDOFromProfile];
            self.editModeUserDO=[user copy];
            self.originalUser=[user copy];
            self.userDetails=[user getUserProfileDetails:NO];
        }
    }

    [self.contentViewer initDisplay:self.userDetails];
}

-(void)initContentViewer{
    [super initContentViewer];
}

-(void)refreshContent{
    [self.contentViewer refreshContent];
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{

    if (isCurrentUser)
        return NSLocalizedString(@"", "");
    else
        return NSLocalizedString(@"", "");
}

#pragma mark ProfileUserDetailsDelegate
-(void)updateProfileImage:(UIImage*)image{

    [self valueChangedTo:image forField:kFieldProfileImage];
    self.userDetails=[self.editModeUserDO getUserProfileDetails:self.isEditingPresentation];
    [self.contentViewer initDisplay:self.userDetails];
    [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
}

- (void)changePasswordRequested {

    if (self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(changePasswordRequested)])
    {
        [self.rootUserDelegate changePasswordRequested];
    }
}

-(void)leaveProfileEditingWithoutChanges{

   [self initContent];
    
    if(self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(leaveProfileEditingWithoutChanges)])
    {

        [self.rootUserDelegate leaveProfileEditingWithoutChanges];
    }
}

-(void)leaveProfileEditingWithSaveChanges:(UserDO *)deltaUser{
  
    if(self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(leaveProfileEditingWithSaveChanges:)])
    {
        //TODO:
        //setup original firstname/last name if not edited
        
        if(self.editModePublishDO.firstName==Nil){
            self.editModePublishDO.firstName=self.editModeUserDO.firstName;
        }
        if(self.editModePublishDO.lastName==Nil){
            self.editModePublishDO.lastName=self.editModeUserDO.lastName;
        }
        //if description text exists, remove leading and trailing spaces
        if (self.editModePublishDO.userDescription) {
            self.editModePublishDO.userDescription = [self.editModePublishDO.userDescription stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        }
        if (self.editModePublishDO.extendedDetails.interests) {
            self.editModePublishDO.extendedDetails.interests = [self.editModePublishDO.extendedDetails.interests stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        }
        
        [self.rootUserDelegate leaveProfileEditingWithSaveChanges:self.editModePublishDO];
    }
}

- (void)askToLeaveWithoutSave {

//    [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ask_save_user_details", @"") delegate:self
//                      cancelButtonTitle:NSLocalizedString(@"Cancel_edit_profile_button_title", @"")
//                      otherButtonTitles:NSLocalizedString(@"save_profile_button_save", @""),NSLocalizedString(@"save_profile_button_cancel", @""),nil] show];

    [self disregardChangesOnProfileObject];
}

- (void)askToLeaveWithSaveAction {
    
    if (![self changeExists]) {
        [self disregardChangesOnProfileObject];
    }else{
        if(self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(askToLeaveWithSaveAction)])
        {
            [self.rootUserDelegate askToLeaveWithSaveAction];
        }
    }
}

-(void)disregardChangesOnProfileObject{

    if(self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(askToLeaveWithoutSave)])
    {
        [self initContent];

        [self.rootUserDelegate askToLeaveWithoutSave];
    }
}

-(void)changeUserProfileImageRequestedForRect:(UIView*)mview{


    if (self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(changeUserProfileImageRequestedForRect:)])
    {
        [self.rootUserDelegate changeUserProfileImageRequestedForRect:mview];
    }
}

-(void)valueChangedTo:(id)nVal forField:(UserViewField)field{

    //Combo field for fields that open with selection and called this method from free text input
    UserComboDO * valueObj = [UserComboDO new];
    valueObj.comboName = nVal;
    valueObj.comboId = @"";

    switch ((int)field){

        case kComboUnknown:break;
        case kFieldFirstName:
        {
            self.editModePublishDO.firstName=nVal;
            self.editModeUserDO.firstName=nVal;
            [self updateUserDetailsArray:kFieldFullName newValue:[NSArray arrayWithObjects:self.editModePublishDO.firstName,self.editModePublishDO.lastName, nil] ];
        }
            break;
        case kFieldProfileImage:
        {
            self.editModeUserDO.tempEditProfileImage=nVal;
            self.editModePublishDO.tempEditProfileImage=nVal;

        }
            break;
        case kFieldLastName:
        {
            self.editModePublishDO.lastName=nVal;
            self.editModeUserDO.lastName=nVal;
           [self updateUserDetailsArray:kFieldFullName newValue:[NSArray arrayWithObjects:self.editModePublishDO.firstName,self.editModePublishDO.lastName, nil] ];
        }
            break;
        case kFieldLocation:
        {
            self.editModeUserDO.extendedDetails.locationStatusChanged = YES;
            self.editModePublishDO.extendedDetails.locationStatusChanged = YES;
                self.editModePublishDO.extendedDetails.location=nVal;
                self.editModePublishDO.extendedDetails.locationVisible=([nVal length]>0)?YES:NO;
                self.editModeUserDO.extendedDetails.locationVisible=([nVal length]>0)?YES:NO;
                self.editModeUserDO.extendedDetails.location=nVal;
           
            [self updateUserDetailsArray:field newValue:nVal ];
        }
            break;
        case kFieldWebsite:
        {
            self.editModePublishDO.extendedDetails.website=nVal;
            self.editModeUserDO.extendedDetails.website=nVal;
            [self updateUserDetailsArray:field newValue:nVal ];
        }
            break;
        case kFieldInterests:
            self.editModePublishDO.extendedDetails.interests=nVal;
            self.editModeUserDO.extendedDetails.interests=nVal;
            [self updateUserDetailsArray:field newValue:nVal ];
            break;
        case kFieldGender:
            self.editModePublishDO.extendedDetails.gender=nVal;
            self.editModeUserDO.extendedDetails.gender=nVal;
            [self updateUserDetailsArray:field newValue:nVal ];
            break;
        case kFieldFullName:

            break;
        case kFieldDescription:
        {
            self.editModePublishDO.userDescription=nVal;
            self.editModeUserDO.userDescription=nVal;
            [self updateUserDetailsArray:field newValue:nVal ];
        }
            break;
        case kFieldUserTypes:
            [self updateComboValue:valueObj];
         break;
        case kFieldProfessions:
            [self updateComboValue:valueObj];
            break;
        case kFieldDesignTools:
            [self updateComboValue:valueObj];
            break;
        case kFieldFavoriteStyles:
            [self updateComboValue:valueObj];
            break;
    }
}

- (void)updateUserDetailsArray:(UserViewField)field newValue:(id)value {
//update the underlying userDetails
    for (NSMutableDictionary* d in self.userDetails) {
        if ([d objectForKey:USER_DETAIL_DATA_MODEL_FIELD] && [[d objectForKey:USER_DETAIL_DATA_MODEL_FIELD] intValue]==field) {
            [d setObject:value forKey:USER_DETAIL_ROW_TYPE_VALUE];
        }
    }
}

-(void)adjustViewForFieldInput:(CGRect)fieldRect{

    if(self.viewAnimationIsRunning)return;

    CGFloat offset = fieldRect.origin.y > 280 ? 150 : 20;

        self.viewAnimationIsRunning =YES;

    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame=self.view.frame;
        frame.origin.y=frame.origin.y-offset;//提高至整个输入框高度。输入框高度为90
        self.view.frame=frame;

    } completion:^(BOOL finished) {
        self.viewAnimationIsRunning =NO;
    }];
}

-(void)restoreViewForFieldInput{

    if(self.viewAnimationIsRunning)return;
    self.viewAnimationIsRunning =YES;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame=self.view.frame;
        frame.origin.y=0;
        self.view.frame=frame;

    } completion:^(BOOL finished) {
        self.viewAnimationIsRunning =NO;
    }];
}

- (void)openOptionsForField:(UserViewField)field withCurrentValue:(id)value openView:(UIView*)mview {


    self.currentViewedFieldOptions = field;
    self.currentSelectedValues = value;
    switch ((int)field){
        case kFieldUserTypes:
            self.currentComboDataList=self.comboOptions.userTypes;
            break;
        case kFieldProfessions:
            self.currentComboDataList=self.comboOptions.profs;
            break;
        case kFieldDesignTools:
            self.currentComboDataList=self.comboOptions.tools;
            break;
        case kFieldFavoriteStyles:
            self.currentComboDataList=self.comboOptions.styles;
            break;
        case kComboUnknown:
            break;
    }

    [self openOptionsPopover:mview fieldType:field];
}

-(void)signoutRequested{
   
    id<ProfileInstanceDataDelegate,ProfileCountersDelegate,ProfileUserDetailsDelegate> deleg=self.rootUserDelegate;
    if (deleg && [deleg respondsToSelector:@selector(signoutRequested)]) {
        [deleg signoutRequested];
    }
}

-(void)openUserWebPage:(NSString*)url{

    if (![NSString isNullOrEmpty:url]) {

        if ([url rangeOfString:@"http://"].location==NSNotFound) {
            url=[NSString stringWithFormat:@"http://%@",url];
        }
        NSURL * surl=[NSURL URLWithString:url];
        if (surl) {
            [[UIApplication sharedApplication] openURL:surl];
        }
    }
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
                }else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }
                break;
            case 2:
                [self disregardChangesOnProfileObject];
                break;
            default:
                break;
        }
    }
}

- (BOOL)changeExists {

    if(self.isEditingPresentation){
        NSUInteger hashed = [self.originalUser hash];
        NSUInteger hashed2 = [self.editModeUserDO hash];
        self.changesMade = hashed!=hashed2;
    }else{
        self.changesMade = NO;
    }

    return  self.changesMade;
}

- (void)openOptionsPopover:(UIView *)mview fieldType:(UserViewField)field {

    UINavigationController * nav=[ControllersFactory instantiateViewControllerWithIdentifier:@"TableComboNavigation" inStoryboard:kProfileStoryboard];


    TableOptionsViewController *vc=(TableOptionsViewController*)[nav topViewController];
    vc.delegate=self;
    vc.inputFieldReference=field;
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

    CGRect cell=mview.frame;
    UIView * parentView;

    if(self.rootUserDelegate && [self.rootUserDelegate respondsToSelector:@selector(getParentView)])
    {
        parentView=[self.rootUserDelegate getParentView];

        cell=  [parentView convertRect:mview.frame fromView:mview.superview];

    } else{
        parentView=mview;
    }

    self.comboPopover=[[UIPopoverController alloc]initWithContentViewController:nav];
    self.comboPopover.delegate=self;
    [self.comboPopover presentPopoverFromRect:cell inView:parentView permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}

- (void)updateComboValue:(id )valueObj {
    switch(self.currentViewedFieldOptions)   {

        case kFieldUserTypes:
        {
            UserComboDO * combo=(UserComboDO*)valueObj;
            self.editModePublishDO.extendedDetails.userType=combo;
            self.editModeUserDO.extendedDetails.userType=combo;
        }
            break;
        case kFieldProfessions:
        {
              UserComboDO * combo=(UserComboDO*)valueObj;
            self.editModePublishDO.extendedDetails.proffessions=[NSMutableArray arrayWithObject:combo];
            self.editModeUserDO.extendedDetails.proffessions=[NSMutableArray arrayWithObject:combo];
        }
            break;
        case kFieldDesignTools:
        {
            if ([valueObj isKindOfClass:[UserComboDO class]]) {
                self.editModePublishDO.extendedDetails.designingTools=[NSMutableArray arrayWithObject:valueObj];
                self.editModeUserDO.extendedDetails.designingTools=[NSMutableArray arrayWithObject:valueObj];
            }else{
            self.editModePublishDO.extendedDetails.designingTools=valueObj;
                self.editModeUserDO.extendedDetails.designingTools=valueObj;
            }
        }
            break;
        case kFieldFavoriteStyles:
        {
            if ([valueObj isKindOfClass:[UserComboDO class]]) {
                self.editModePublishDO.extendedDetails.favoriteStyles=[NSMutableArray arrayWithObject:valueObj];
                self.editModeUserDO.extendedDetails.favoriteStyles=[NSMutableArray arrayWithObject:valueObj];
                
            }else{
            self.editModePublishDO.extendedDetails.favoriteStyles=valueObj;
            self.editModeUserDO.extendedDetails.favoriteStyles=valueObj;
            }
        }
            break;
            default:
                break;
    }
}

-(BOOL)updateOrGetCurrentLocation{

    [[LocationManager sharedInstance] getLocation:^(id serverResponse, id error) {

        if (error==nil) {
            CLPlacemark * mark=[[LocationManager sharedInstance] lastAddress];
            CLLocation * location=[[LocationManager sharedInstance] lastLocation];

            [self.editModePublishDO updateLocationWithLocation:location andAddress:mark];
            [self.editModeUserDO updateLocationWithLocation:location andAddress:mark];
        }
        else {
            if ([error isKindOfClass:[NSString class]]) {
                [self showLocationErrorAlertWithMessage:((NSString*)error)];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.userDetails=[self.editModeUserDO getUserProfileDetails:self.isEditingPresentation];
            [self.contentViewer initDisplay:self.userDetails];
            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
        });
        
    }];
    
    return YES;
}

- (void)showLocationErrorAlertWithMessage:(NSString*)message {
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:Nil
                          cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn",@"") otherButtonTitles: nil] show];
    });
}

#pragma mark - TableOptionSelectionDelegate
-(void)didSelectItemsAtIndexes:(NSMutableDictionary*)indexesDict{
    
    NSMutableArray * list = [NSMutableArray array];
    for (NSString * key  in [indexesDict allKeys]) {
        [list addObject:[indexesDict objectForKey:key]];
    }
    [self updateComboValue:list];
    
    self.userDetails = [self.editModeUserDO getUserProfileDetails:self.isEditingPresentation];
    [self.contentViewer initDisplay:self.userDetails];
    [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
    
    if (IS_IPAD) {
        [self dismissViewWithoutSelection];
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index withData:(id)object {
    
    UserComboDO * valueObj=(UserComboDO*)object;
    
    [self updateComboValue:valueObj];
    
    self.userDetails = [self.editModeUserDO getUserProfileDetails:self.isEditingPresentation];
    [self.contentViewer initDisplay:self.userDetails];
    [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
    
    if (IS_IPAD) {
        [self dismissViewWithoutSelection];
    }
}

-(void)dismissViewWithoutSelection{
    [self.comboPopover  dismissPopoverAnimated:YES];
}

-(void)newRecordEntryUsedWithValue:(id)value forField:(UserViewField)field{
    
    [self valueChangedTo:value forField:field];
    self.userDetails = [self.editModeUserDO getUserProfileDetails:self.isEditingPresentation];
    [self.contentViewer initDisplay:self.userDetails];
    [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
    
    if (IS_IPAD) {
        [self dismissViewWithoutSelection];
    }
}

@end
