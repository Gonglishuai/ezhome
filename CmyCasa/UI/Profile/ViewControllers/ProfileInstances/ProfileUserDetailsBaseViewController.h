//
// Created by Berenson Sergei on 1/6/14.
//333


#import <Foundation/Foundation.h>
#import "TableOptionsViewController.h"
#import "ProfileInstanceBaseViewController.h"
#import "ProfileProtocols.h"

@class UserCombosResponse;

@interface ProfileUserDetailsBaseViewController : ProfileInstanceBaseViewController <ProfileUserDetailsDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, TableOptionSelectionDelegate>
@property(nonatomic,readwrite) BOOL isEditingPresentation;
@property(nonatomic,weak)id <ProfileInstanceDataDelegate,ProfileUserDetailsDelegate> rootUserDelegate;
@property(nonatomic) BOOL viewAnimationIsRunning;
@property(nonatomic,strong)NSMutableArray * userDetails;
@property(nonatomic,strong)UserDO * editModeUserDO;
//holds all changes on top of current profile details
@property(nonatomic,strong)UserDO * editModePublishDO;
//holds only changed properties
@property(nonatomic, strong) UserDO *  originalUser;
//original user info without changes, to handge change of properties detection
@property(nonatomic) BOOL changesMade;
@property(nonatomic, strong)UIPopoverController * comboPopover ;
@property(nonatomic, strong)UserCombosResponse * comboOptions;
@property(nonatomic, strong)NSMutableArray *currentComboDataList;
@property(nonatomic, strong)id currentSelectedValues;
@property(nonatomic) UserViewField currentViewedFieldOptions;

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;
-(void)dismissSelf;

-(void)updateProfileImage:(UIImage*)image;
-(BOOL)changeExists;
-(void)disregardChangesOnProfileObject;
-(void)openOptionsPopover:(UIView *)mview fieldType:(UserViewField)field;

@end
